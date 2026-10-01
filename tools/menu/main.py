#!/usr/bin/env python3
"""One fzf session, with query-driven submenu candidates and filtering."""

import os
import shlex
import subprocess
import sys

# Support direct execution as well as the compatibility launcher.
if not __package__:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from menu import cd, git, tmux
from menu.commands import COMMANDS
from menu.common import Command, Mode, run_command

SUBMENUS = {"cd": cd, "git": git, "tmux": tmux}


def namespace(query):
    parts = query.lstrip().split(maxsplit=1)
    if parts and parts[0] in SUBMENUS:
        return parts[0], parts[1] if len(parts) > 1 else ""
    return None, query


def candidates(query):
    prefix, _ = namespace(query)
    if prefix:
        return SUBMENUS[prefix].candidates()
    return [*COMMANDS, *SUBMENUS]


def resolve(value):
    prefix, name = namespace(value)
    if prefix:
        return SUBMENUS[prefix].resolve(name.strip())
    return COMMANDS.get(value.strip())


def choose():
    helper = shlex.join([sys.executable, os.path.abspath(__file__)])
    # fzf shell-quotes {q} and {}. Never embed user text in action syntax.
    refresh = (
        f"reload-sync({helper} --candidates {{q}})"
        f"+transform-search({helper} --search {{q}})"
    )
    proc = subprocess.run(
        [
            "fzf",
            "--prompt=tmux> ",
            "--disabled",
            "--print-query",
            "--expect=ctrl-x",
            "--header=Enter: select preset | Ctrl-X: run query",
            f"--bind=start:{refresh},change:{refresh}",
            f"--bind=enter:transform({helper} --accept {{q}} {{}})",
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
    if key == "ctrl-x" or resolve(query) is not None or not selected:
        return query
    prefix, _ = namespace(query)
    return f"{prefix} {selected}" if prefix else selected


def main():
    # Helpers only print data/actions; only choose() launches fzf.
    if len(sys.argv) > 1:
        action, query = sys.argv[1:3]
        if action == "--candidates":
            print("\n".join(candidates(query)))
        elif action == "--search":
            print(namespace(query)[1])
        elif action == "--accept":
            selected = sys.argv[3] if len(sys.argv) > 3 else ""
            if namespace(query)[0] is None and selected in SUBMENUS:
                print(f"change-query({selected} )")
            else:
                print("accept")
        else:
            raise SystemExit(f"Unknown option: {action}")
        return 0

    choice = choose()
    if choice is None or not choice.strip():
        return 0
    command = resolve(choice)
    if command is None:
        command = Command(
            ["zsh", "-ic", f"{choice}; exec zsh -i"], mode=Mode.INTERACTIVE
        )
    return run_command(command)


if __name__ == "__main__":
    raise SystemExit(main())
