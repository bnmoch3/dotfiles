from .common import Command, Mode

COMMANDS = {
    "arrange": Command(["tmux-arrange"], mode=Mode.INTERACTIVE),
}


def candidates():
    return COMMANDS


def resolve(name):
    return COMMANDS.get(name)
