#!/usr/bin/env python3

import os
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
NEW_SESSION_SCRIPT = os.path.join(SCRIPT_DIR, "new_session.sh")

NEW_SESSION = "__new_session__"
NEW_SESSION_DISPLAY = "+ new session"


def run(args, **kwargs):
    kwargs.setdefault("check", False)
    return subprocess.run(args, text=True, **kwargs)


def inside_tmux():
    if not os.environ.get("TMUX"):
        return False

    result = run(
        ["tmux", "display-message", "-p", "#S"],
        capture_output=True,
    )
    return result.returncode == 0


def current_session():
    if not inside_tmux():
        return ""

    result = run(
        ["tmux", "display-message", "-p", "#S"],
        capture_output=True,
        check=True,
    )
    return result.stdout.strip()


def list_sessions():
    result = run(
        ["tmux", "list-sessions", "-F", "#{session_name}"],
        capture_output=True,
    )

    if result.returncode != 0:
        return []

    return [line for line in result.stdout.splitlines() if line]


def list_windows(session):
    result = run(
        [
            "tmux",
            "list-windows",
            "-t",
            session,
            "-F",
            "#{window_name}",
        ],
        capture_output=True,
        check=True,
    )

    return result.stdout.splitlines()


def session_candidates():
    current = current_session()
    candidates = [f"{NEW_SESSION}\t{NEW_SESSION_DISPLAY}"]

    for session in list_sessions():
        windows = list_windows(session)
        marker = "*" if session == current else " "

        display = (
            f"{marker} {session:<28} {len(windows):>2} windows   {','.join(windows)}"
        )

        candidates.append(f"{session}\t{display}")

    return candidates


def choose(candidates, prompt, delimiter=None, with_nth=None):
    args = [
        "fzf",
        "--no-multi",
        f"--prompt={prompt}",
        "--height=100%",
        "--layout=reverse",
        "--border",
        "--info=inline",
        "--pointer=>",
    ]

    if delimiter is not None:
        args.append(f"--delimiter={delimiter}")

    if with_nth is not None:
        args.append(f"--with-nth={with_nth}")

    result = run(
        args,
        input="\n".join(candidates),
        capture_output=True,
    )

    if result.returncode != 0:
        return None

    return result.stdout.rstrip("\n")


def zoxide_directories():
    result = run(
        ["zoxide", "query", "--list"],
        capture_output=True,
    )

    if result.returncode != 0:
        return []

    return [path for path in result.stdout.splitlines() if os.path.isdir(path)]


def directory_candidates():
    cwd = os.getcwd()

    candidates = [cwd]

    for path in zoxide_directories():
        if path != cwd:
            candidates.append(path)

    return candidates


def choose_directory():
    return choose(
        directory_candidates(),
        "directory > ",
    )


def prompt_session_name(directory):
    default = os.path.basename(os.path.normpath(directory))

    try:
        value = input(f"session name [{default}] > ").strip()
    except EOFError:
        return None

    return value or default


def create_session():
    directory = choose_directory()

    if not directory:
        return 0

    session_name = prompt_session_name(directory)

    if not session_name:
        return 0

    result = run(
        [
            NEW_SESSION_SCRIPT,
            session_name,
            directory,
        ]
    )

    return result.returncode


def switch_session(session):
    if inside_tmux():
        return run(["tmux", "switch-client", "-t", session]).returncode

    os.execvp(
        "tmux",
        ["tmux", "attach-session", "-t", session],
    )


def main():
    selection = choose(
        session_candidates(),
        "tmux sessions > ",
        delimiter="\t",
        with_nth="2",
    )

    if not selection:
        return 0

    action = selection.split("\t", maxsplit=1)[0]

    if action == NEW_SESSION:
        return create_session()

    return switch_session(action)


if __name__ == "__main__":
    raise SystemExit(main())
