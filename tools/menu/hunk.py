from .common import Command, Mode

COMMANDS = {
    "hunk diff": Command(["hunk", "diff"], mode=Mode.INTERACTIVE),
    "hunk diff staged": Command(["hunk", "diff", "--staged"], mode=Mode.INTERACTIVE),
}


def candidates():
    return COMMANDS


def resolve(name):
    return COMMANDS.get(name)
