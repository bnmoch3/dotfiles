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
    "shell": Command(["zsh", "-i"], interactive=True),
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
    "nightmode": Command(
        [os.path.expanduser("~/dotfiles/tools/nightmode.py")],
        interactive=True,
    ),
}


def choose():
    proc = subprocess.run(
        [
            "fzf",
            "--prompt=tmux> ",
            "--bind=ctrl-x:print-query",
            "--header=Enter: select preset | Ctrl-X: run query",
        ],
        input="\n".join(COMMANDS),
        text=True,
        capture_output=True,
    )

    if proc.returncode != 0:
        return None

    value = proc.stdout.rstrip("\n")

    if not value:
        return None

    return value


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


def run_shell_query(query):
    if not query.strip():
        return 0

    try:
        os.execvp(
            "zsh",
            ["zsh", "-ic", f"{query}; exec zsh -i"],
        )
    except FileNotFoundError:
        print("Command not found: 'zsh'", file=sys.stderr)
        wait_to_close()
        return 1
    except OSError as exc:
        print(f"Failed to launch shell: {exc}", file=sys.stderr)
        wait_to_close()
        return 1


def main():
    choice = choose()

    if choice is None:
        return 0

    command = COMMANDS.get(choice)

    if command is not None:
        return run_command(command)

    return run_shell_query(choice)


if __name__ == "__main__":
    raise SystemExit(main())
