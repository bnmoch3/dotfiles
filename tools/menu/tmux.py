import os

from .common import Command, Mode

DISPLAY_PREFIX = "tmux"

TOOLS_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TMUX_DIR = os.path.join(TOOLS_DIR, "tmux")

COMMANDS = {
    "switch session": Command(
        [os.path.join(TMUX_DIR, "switch_session.py")],
        mode=Mode.INTERACTIVE,
        display_prefix=True,
    ),
    "switch window": Command(
        [os.path.join(TMUX_DIR, "switch_window.sh")],
        mode=Mode.INTERACTIVE,
        display_prefix=True,
    ),
    "new session": Command(
        [os.path.join(TMUX_DIR, "new_session.sh")],
        mode=Mode.INTERACTIVE,
        display_prefix=True,
    ),
    "kill session": Command(
        [os.path.join(TMUX_DIR, "kill_session.sh")],
        mode=Mode.INTERACTIVE,
        display_prefix=True,
    ),
    "rename window": Command(
        [os.path.join(TMUX_DIR, "rename_window.sh")],
        mode=Mode.INTERACTIVE,
        display_prefix=True,
    ),
    "arrange windows": Command(
        [os.path.join(TMUX_DIR, "arrange_windows.py")],
        mode=Mode.INTERACTIVE,
        display_prefix=True,
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
