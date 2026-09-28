#!/home/bnm/dotfiles/tools/.venv/bin/python

import os
import subprocess
import sys

TOOLS_DIR = os.path.dirname(os.path.realpath(__file__))
SUPPORTED_EXTENSIONS = {".py", ".sh"}
SELF_NAME = os.path.basename(os.path.realpath(__file__))


def discover_tools():
    tools = {}

    for filename in os.listdir(TOOLS_DIR):
        path = os.path.join(TOOLS_DIR, filename)

        if not os.path.isfile(path):
            continue

        if filename == SELF_NAME:
            continue

        name, ext = os.path.splitext(filename)

        if ext not in SUPPORTED_EXTENSIONS:
            continue

        if name in tools:
            raise RuntimeError(
                f"Duplicate tool name {name!r}: {tools[name]!r} and {path!r}"
            )

        tools[name] = path

    return dict(sorted(tools.items()))


def list_tools(tools):
    for name in tools:
        print(name)


def choose_tool(tools):
    proc = subprocess.run(
        ["fzf", "--prompt=tool> "],
        input="\n".join(tools),
        text=True,
        capture_output=True,
    )

    if proc.returncode != 0:
        return None

    choice = proc.stdout.strip()

    if not choice:
        return None

    return choice


def run_tool(path, args):
    _, ext = os.path.splitext(path)

    if ext == ".py":
        command = [sys.executable, path, *args]
    elif ext == ".sh":
        command = ["bash", path, *args]
    else:
        print(
            f"Unsupported tool type: {ext!r}",
            file=sys.stderr,
        )
        return 1

    try:
        os.execvp(command[0], command)
    except FileNotFoundError:
        print(
            f"Command not found: {command[0]!r}",
            file=sys.stderr,
        )
        return 1
    except OSError as exc:
        print(
            f"Failed to run tool: {exc}",
            file=sys.stderr,
        )
        return 1


def main():
    try:
        tools = discover_tools()
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    if len(sys.argv) == 1:
        choice = choose_tool(tools)

        if choice is None:
            return 0

        path = tools.get(choice)

        if path is None:
            print(
                f"Unknown tool: {choice!r}",
                file=sys.stderr,
            )
            return 1

        return run_tool(path, [])

    command = sys.argv[1]

    if command == "list":
        list_tools(tools)
        return 0

    path = tools.get(command)

    if path is None:
        print(
            f"Unknown tool: {command!r}",
            file=sys.stderr,
        )
        return 1

    return run_tool(path, sys.argv[2:])


if __name__ == "__main__":
    raise SystemExit(main())
