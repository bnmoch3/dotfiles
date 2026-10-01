import os

from .common import Command, Mode

COMMANDS = {
    "shell": Command(["zsh", "-i"], mode=Mode.INTERACTIVE),
    "todo": Command(
        ["nvim", "+", os.path.expanduser("~/TODO.txt")], mode=Mode.INTERACTIVE
    ),
    "chatgpt": Command(
        ["codex", "--model", "gpt-5.6-luna"],
        mode=Mode.INTERACTIVE,
        cwd=os.path.expanduser("~/PROJECTS/.scratch/codex"),
    ),
    "nightmode": Command(
        [os.path.expanduser("~/dotfiles/tools/nightmode.py")],
        mode=Mode.INTERACTIVE,
    ),
}
