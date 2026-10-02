#!/usr/bin/env python3
"""One fzf session, with query-driven submenu candidates and filtering."""

import json
import os
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

# Support direct execution as well as the compatibility launcher.
if not __package__:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from menu import browser, cd, git, hunk, tmux
from menu.commands import COMMANDS
from menu.common import Command, Mode, run_command

SUBMENUS = {"cd": cd, "git": git, "tmux": tmux, "browser": browser, "hunk": hunk}


def namespace(query):
    parts = query.lstrip().split(maxsplit=1)
    if parts and parts[0] in SUBMENUS:
        return parts[0], parts[1] if len(parts) > 1 else ""
    return None, query


def candidates(query, children=None):
    prefix, _ = namespace(query)
    if prefix == "cd":
        return cd.candidates(children)
    if prefix:
        return SUBMENUS[prefix].candidates()
    return [*COMMANDS, *SUBMENUS]


def resolve(value, children=None):
    prefix, name = namespace(value)
    if prefix == "cd":
        return cd.resolve(name if children is not None else name.strip(), children)
    if prefix:
        return SUBMENUS[prefix].resolve(name.strip())
    return COMMANDS.get(value.strip())


def refresh_actions(helper):
    return (
        f"reload-sync({helper} --candidates {{q}})"
        f"+transform-search({helper} --search {{q}})"
    )


def read_state(state_path):
    return json.loads(state_path.read_text()) if state_path.exists() else None


def read_children(state_path):
    # None means curated aliases; even an empty mapping is a browsing level.
    state = read_state(state_path)
    return state["children"] if state is not None else None


def choose(state_path, initial_query=""):
    helper = shlex.join(
        [sys.executable, os.path.abspath(__file__), "--state", str(state_path)]
    )
    # fzf shell-quotes {q} and {}. Never embed user text in action syntax.
    refresh = refresh_actions(helper)
    proc = subprocess.run(
        [
            "fzf",
            "--prompt=tmux> ",
            "--disabled",
            "--print-query",
            f"--query={initial_query}",
            "--expect=ctrl-x",
            "--header=Enter: select | Tab: descend | Shift-Tab: back | Ctrl-X: run query",
            f"--bind=start:{refresh},change:{refresh}",
            f"--bind=enter:transform({helper} --accept {{q}} {{}})",
            f"--bind=tab:transform({helper} --tab {{q}} {{}})",
            f"--bind=btab:transform({helper} --back {{q}})",
        ],
        input="\n".join(candidates("")),
        text=True,
        capture_output=True,
    )
    # fzf returns 1 when accepting a query with no matching candidate.
    if proc.returncode not in (0, 1):
        return None
    lines = proc.stdout.splitlines()
    if not lines:
        return None
    query = lines[0]
    key = lines[1] if len(lines) > 1 else ""
    selected = lines[2] if len(lines) > 2 else ""
    # During browsing the selection, rather than the filter, identifies the path.
    if (
        key != "ctrl-x"
        and namespace(query)[0] == "cd"
        and read_children(state_path) is not None
    ):
        return f"cd {selected}" if selected else None
    if key == "ctrl-x" or resolve(query) is not None or not selected:
        return query
    prefix, _ = namespace(query)
    if prefix and selected.startswith(f"{prefix} "):
        return selected

    return f"{prefix} {selected}" if prefix else selected


def main():
    args = sys.argv[1:]
    state_path = None
    initial_query = ""
    if args[:1] == ["--state"]:
        state_path = Path(args[1])
        args = args[2:]
    # --query is launch-only; fzf helper re-execs always start with --state.
    elif args[:1] == ["--query"]:
        if len(args) < 2:
            raise SystemExit("Missing query argument for --query")
        if len(args) > 2:
            raise SystemExit("Unexpected arguments after --query")
        initial_query = args[1]
        args = []
    state = read_state(state_path) if state_path else None
    children = state["children"] if state is not None else None
    # Helpers only print data/actions; only choose() launches fzf.
    if args:
        if len(args) < 2:
            raise SystemExit(f"Missing query argument for {args[0]}")
        action, query = args[:2]
        if action == "--candidates":
            if namespace(query)[0] != "cd" and state_path:
                state_path.write_text("null")
                children = None
            print("\n".join(candidates(query, children)))
        elif action == "--search":
            print(namespace(query)[1])
        elif action == "--accept":
            selected = args[2] if len(args) > 2 else ""
            if namespace(query)[0] is None and selected in SUBMENUS:
                print(f"change-query({selected} )")
            else:
                print("accept")
        elif action in ("--tab", "--back"):
            selected = args[2] if len(args) > 2 else ""
            if state_path and namespace(query)[0] == "cd":
                changed = False
                if action == "--tab" and selected:
                    name = (
                        selected
                        if children is not None
                        else selected.removeprefix("cd ")
                    )
                    descent = cd.descend(name, children)
                    if descent is not None:
                        path, descendants = descent
                        stack = state["stack"] if state is not None else []
                        state = {
                            "stack": [*stack, path],
                            "children": descendants,
                        }
                        changed = True
                elif action == "--back" and state is not None:
                    stack = state["stack"][:-1]
                    # An unavailable parent is still a level we can back out of.
                    state = (
                        {"stack": stack, "children": cd.list_children(stack[-1]) or {}}
                        if stack
                        else None
                    )
                    changed = True
                if changed:
                    state_path.write_text(json.dumps(state))
                    helper = shlex.join(
                        [
                            sys.executable,
                            os.path.abspath(__file__),
                            "--state",
                            str(state_path),
                        ]
                    )
                    print(f"change-query(cd )+{refresh_actions(helper)}")
        else:
            raise SystemExit(f"Unknown option: {action}")
        return 0

    with tempfile.TemporaryDirectory(prefix="menu-") as session:
        state_path = Path(session) / "cd.json"
        choice = choose(state_path, initial_query)
        if choice is None or not choice.strip():
            return 0
        command = resolve(choice, read_children(state_path))
    if command is None:
        command = Command(
            ["zsh", "-ic", f"{choice}; exec zsh -i"], mode=Mode.INTERACTIVE
        )
    return run_command(command)


if __name__ == "__main__":
    raise SystemExit(main())
