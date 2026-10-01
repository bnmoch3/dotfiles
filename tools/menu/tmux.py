from .common import Command, Mode

COMMANDS = {
    "tmux list sessions": Command(["tmux", "list-sessions"]),
    "tmux arrange": Command(["tmux-arrange"], mode=Mode.INTERACTIVE),
}


def candidates():
    return COMMANDS


def resolve(name):
    return COMMANDS.get(name)
