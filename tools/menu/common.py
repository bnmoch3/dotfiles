import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from enum import Enum


class Mode(Enum):
    OUTPUT = "output"
    INTERACTIVE = "interactive"
    DETACHED = "detached"


@dataclass(frozen=True)
class Command:
    args: list[str]
    mode: Mode = Mode.OUTPUT
    cwd: str | None = None

    def __post_init__(self):
        if not isinstance(self.mode, Mode):
            raise TypeError(f"Expected a Mode enum member, got {self.mode!r}")


def wait_to_close():
    print()
    print("─" * shutil.get_terminal_size().columns)
    try:
        input("Press Enter to close...")
    except EOFError:
        pass


def run_command(command):
    if command.cwd is not None:
        try:
            os.chdir(command.cwd)
        except OSError as exc:
            print(
                f"Failed to change directory to {command.cwd!r}: {exc}", file=sys.stderr
            )
            wait_to_close()
            return 1
    try:
        if command.mode is Mode.INTERACTIVE:
            os.execvp(command.args[0], command.args)
        elif command.mode is Mode.DETACHED:
            subprocess.Popen(
                command.args,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
                start_new_session=True,
            )
            return 0
        else:
            returncode = subprocess.run(command.args).returncode
            wait_to_close()
            return returncode
    except FileNotFoundError:
        print(f"Command not found: {command.args[0]!r}", file=sys.stderr)
    except OSError as exc:
        print(f"Failed to run {command.args[0]!r}: {exc}", file=sys.stderr)
    wait_to_close()
    return 1
