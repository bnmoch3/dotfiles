#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys
from dataclasses import dataclass


@dataclass
class Command:
    args: list
    interactive: bool = False


COMMANDS = {
    "scratch shell": Command(["zsh", "-i"], interactive=True),
    "git status": Command(["git", "status"]),
    "tmux-arrange": Command(["tmux-arrange"], interactive=True),
    "todo": Command(
        ["nvim", "+", os.path.expanduser("~/TODO.txt")],
        interactive=True,
    ),
}


def choose():
    proc = subprocess.run(
        ["fzf", "--prompt=tmux> "],
        input="\n".join(COMMANDS),
        text=True,
        capture_output=True,
    )

    if proc.returncode != 0:
        return None

    return proc.stdout.strip()


def wait_to_close():
    width = shutil.get_terminal_size().columns
    print()
    print("─" * width)

    try:
        input("Press Enter to close...")
    except EOFError:
        pass


def run_command(command):
    if command.interactive:
        try:
            os.execvp(command.args[0], command.args)
        except FileNotFoundError:
            print(
                f"Command not found: {command.args[0]!r}",
                file=sys.stderr,
            )
            return 1
        except OSError as exc:
            print(
                f"Failed to launch {command.args[0]!r}: {exc}",
                file=sys.stderr,
            )
            return 1
    else:
        result = subprocess.run(command.args)
        wait_to_close()
        return result.returncode


def main():
    choice = choose()

    if choice is None:
        return

    command = COMMANDS.get(choice)

    if command is None:
        print(f"Unknown tmux menu command: {choice!r}", file=sys.stderr)
        return 1

    return run_command(command)


if __name__ == "__main__":
    raise SystemExit(main())
