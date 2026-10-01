from . import hunk
from .common import Command, Mode

COMMANDS = {
    "git status": Command(["git", "status"], mode=Mode.OUTPUT),
    "git log": Command(["git", "log"], mode=Mode.INTERACTIVE),
    "git diff": Command(["git", "diff"], mode=Mode.INTERACTIVE),
}


def candidates():
    return {**COMMANDS, **hunk.COMMANDS}


def resolve(name):
    command = COMMANDS.get(name)

    if command is not None:
        return command

    return hunk.resolve(name)
