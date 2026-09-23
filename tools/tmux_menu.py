#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class Command:
    args: list[str]
    interactive: bool = False
    cwd: str | None = None


COMMANDS = {
    "scratch shell": Command(["zsh", "-i"], interactive=True),
    "git status": Command(["git", "status"]),
    "tmux-arrange": Command(["tmux-arrange"], interactive=True),
    "todo": Command(
        ["nvim", "+", os.path.expanduser("~/TODO.txt")],
        interactive=True,
    ),
    "chatgpt": Command(
        ["codex", "--model", "gpt-5.6-luna"],
        interactive=True,
        cwd=os.path.expanduser("~/PROJECTS/.scratch/codex"),
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


def run_process(command):
    try:
        if command.interactive:
            os.execvp(command.args[0], command.args)

        return subprocess.run(command.args).returncode

    except FileNotFoundError:
        print(
            f"Command not found: {command.args[0]!r}",
            file=sys.stderr,
        )
    except OSError as exc:
        print(
            f"Failed to run {command.args[0]!r}: {exc}",
            file=sys.stderr,
        )

    wait_to_close()
    return 1


def run_command(command):
    if command.cwd is not None:
        try:
            os.chdir(command.cwd)
        except OSError as exc:
            print(
                f"Failed to change directory to {command.cwd!r}: {exc}",
                file=sys.stderr,
            )
            wait_to_close()
            return 1

    returncode = run_process(command)

    if not command.interactive:
        wait_to_close()

    return returncode


def main():
    choice = choose()

    if choice is None:
        return 0

    command = COMMANDS.get(choice)

    if command is None:
        print(
            f"Unknown tmux menu command: {choice!r}",
            file=sys.stderr,
        )
        return 1

    return run_command(command)


if __name__ == "__main__":
    raise SystemExit(main())
