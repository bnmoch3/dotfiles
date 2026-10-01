import os
import shlex

from .common import Command, Mode

DIRECTORIES = {
    "dotfiles": "~/dotfiles",
    "downloads": "~/Downloads",
    "desktop": "~/Desktop",
    "projects": "~/PROJECTS",
    "shamiri AI": "~/Desktop/shamiri_AI",
    "papersurvey": "~/PROJECTS/shamiri/papersurvey_replacement",
}


def candidates():
    return DIRECTORIES


def resolve(name):
    if name not in DIRECTORIES:
        return None
    path = shlex.quote(os.path.expanduser(DIRECTORIES[name]))
    return Command(["zsh", "-ic", f"cd {path} && exec zsh -i"], mode=Mode.INTERACTIVE)
