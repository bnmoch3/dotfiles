import os
from dataclasses import dataclass
from enum import Enum

from .common import Command, Mode


class DirectoryMode(Enum):
    TERMINAL = "terminal"
    RECURSIVE = "recursive"


@dataclass(frozen=True)
class Directory:
    path: str
    mode: DirectoryMode = DirectoryMode.TERMINAL


DIRECTORIES = {
    "dotfiles": "~/dotfiles",
    "downloads": "~/Downloads",
    "desktop": Directory("~/Desktop", mode=DirectoryMode.RECURSIVE),
    "projects": Directory("~/PROJECTS", mode=DirectoryMode.RECURSIVE),
    "shamiri AI": "~/Desktop/shamiri_AI",
    "papersurvey": "~/PROJECTS/shamiri/papersurvey_replacement",
}


def directory(name, children=None):
    if children is not None:
        path = children.get(name)
        return Directory(path, DirectoryMode.RECURSIVE) if path is not None else None
    value = DIRECTORIES.get(name)
    return Directory(value) if isinstance(value, str) else value


def candidates(children=None):
    if children is not None:
        return list(children)
    return [f"cd {name}" for name in DIRECTORIES]


def resolve(name, children=None):
    entry = directory(name, children)
    if entry is None:
        return None
    # cwd avoids shell interpolation and uses the shared directory error handling.
    return Command(
        ["zsh", "-i"], mode=Mode.INTERACTIVE, cwd=os.path.expanduser(entry.path)
    )


def descend(name, children=None):
    entry = directory(name, children)
    if entry is None or entry.mode is not DirectoryMode.RECURSIVE:
        return None
    try:
        with os.scandir(os.path.expanduser(entry.path)) as entries:
            return {
                child.name: child.path
                for child in sorted(entries, key=lambda child: child.name)
                if not child.name.startswith(".")
                and "\n" not in child.name
                and "\r" not in child.name
                and child.is_dir()
            }
    except (OSError, ValueError):
        # Leave the current candidates in place if the directory is unavailable.
        return None
