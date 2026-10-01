from . import hunk
from .common import Command, Mode

DISPLAY_PREFIX = "git"

COMMANDS = {
    "status": Command(["git", "status"], mode=Mode.OUTPUT, display_prefix=True),
    "log": Command(["git", "log"], mode=Mode.INTERACTIVE, display_prefix=True),
    "diff": Command(["git", "diff"], mode=Mode.INTERACTIVE, display_prefix=True),
    "lazygit": Command(["lazygit"], mode=Mode.INTERACTIVE, display_prefix=False),
}


def candidates():
    result = []

    for key, command in COMMANDS.items():
        if command.display_prefix:
            result.append(f"{DISPLAY_PREFIX} {key}")
        else:
            result.append(key)

    result.extend(hunk.candidates())

    return result


def resolve(name):
    prefix = f"{DISPLAY_PREFIX} "

    name = name.removeprefix(prefix)

    command = COMMANDS.get(name)

    if command is not None:
        return command

    return hunk.resolve(name)
