from .common import Command, Mode

DISPLAY_PREFIX = "hunk"

COMMANDS = {
    "diff": Command(["hunk", "diff"], mode=Mode.INTERACTIVE, display_prefix=True),
    "diff --staged": Command(
        ["hunk", "diff", "--staged"], mode=Mode.INTERACTIVE, display_prefix=True
    ),
}


def candidates():
    result = []

    for key, command in COMMANDS.items():
        if command.display_prefix:
            result.append(f"{DISPLAY_PREFIX} {key}")
        else:
            result.append(key)

    return result


def resolve(name):
    prefix = f"{DISPLAY_PREFIX} "

    name = name.removeprefix(prefix)

    return COMMANDS.get(name)
