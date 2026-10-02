#!/usr/bin/env python3
"""Interactively arrange the windows in the current tmux session."""

from __future__ import annotations

import os
import re
import shlex
import subprocess
import sys
import tempfile
from dataclasses import dataclass, replace
from typing import Iterable, Mapping, Sequence


HEADER = """# reorder lines to rearrange
# edit names to rename
# delete a line to remove a window
# add a line without @window_id to create a new window
# do not edit existing @window_id values

"""

WINDOW_ID_AT_END = re.compile(r"(?:^|\s)(@\d+)$")


class ArrangeError(Exception):
    """An expected error that can be shown directly to the user."""


@dataclass(frozen=True)
class WindowRow:
    name: str
    window_id: str | None = None


class Tmux:
    """Small wrapper around tmux so all command handling is consistent."""

    def __init__(
        self,
        command: Sequence[str] = ("tmux",),
        env: Mapping[str, str] | None = None,
    ) -> None:
        self.command = tuple(command)
        self.env = env

    def run(self, *args: str) -> str:
        command = [*self.command, *args]
        try:
            result = subprocess.run(
                command,
                check=False,
                capture_output=True,
                text=True,
                env=self.env,
            )
        except OSError as error:
            raise ArrangeError(f"cannot run tmux: {error}") from error

        if result.returncode != 0:
            detail = result.stderr.strip() or result.stdout.strip()
            if not detail:
                detail = f"exited with status {result.returncode}"
            command_name = args[0] if args else "command"
            raise ArrangeError(f"tmux {command_name}: {detail}")
        return result.stdout


def parse_window_line(line: str, existing_ids: set[str]) -> WindowRow:
    """Parse one non-comment editor line."""
    line = line.strip()
    if not line:
        raise ArrangeError("new window name cannot be empty")

    match = WINDOW_ID_AT_END.search(line)
    if match is None:
        return WindowRow(name=line)

    window_id = match.group(1)
    if window_id not in existing_ids:
        raise ArrangeError(f"unknown window id {window_id!r}")

    name = line[: match.start()].rstrip()
    if not name:
        raise ArrangeError(f"window name for {window_id} cannot be empty")
    return WindowRow(name=name, window_id=window_id)


def parse_edited_rows(text: str, original: Sequence[WindowRow]) -> list[WindowRow]:
    existing_ids = {row.window_id for row in original if row.window_id is not None}
    desired: list[WindowRow] = []
    seen_ids: set[str] = set()

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        row = parse_window_line(line, existing_ids)
        if row.window_id is not None:
            if row.window_id in seen_ids:
                raise ArrangeError(f"duplicate window id {row.window_id!r}")
            seen_ids.add(row.window_id)
        desired.append(row)

    if not desired:
        raise ArrangeError("cannot remove every window from the tmux session")
    return desired


def list_windows(tmux: Tmux, session_id: str) -> list[WindowRow]:
    output = tmux.run(
        "list-windows",
        "-t",
        session_id,
        "-F",
        "#{window_id}\t#{window_name}",
    )
    windows: list[WindowRow] = []
    for line in output.splitlines():
        try:
            window_id, name = line.split("\t", 1)
        except ValueError as error:
            raise ArrangeError(f"malformed tmux window record: {line!r}") from error
        if not re.fullmatch(r"@\d+", window_id):
            raise ArrangeError(f"malformed tmux window id: {window_id!r}")
        windows.append(WindowRow(name=name, window_id=window_id))

    if not windows:
        raise ArrangeError("tmux session has no windows")
    return windows


def editor_text(windows: Iterable[WindowRow]) -> str:
    lines = [f"{row.name} {row.window_id}" for row in windows]
    return HEADER + "\n".join(lines) + "\n"


def open_editor(content: str) -> str:
    path = ""
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", prefix="tmux-arrange-", suffix=".txt", delete=False
        ) as temporary_file:
            path = temporary_file.name
            temporary_file.write(content)

        editor = os.environ.get("EDITOR") or "nvim"
        try:
            command = shlex.split(editor)
        except ValueError as error:
            raise ArrangeError(f"invalid $EDITOR value: {error}") from error
        if not command:
            command = ["nvim"]

        try:
            result = subprocess.run([*command, path], check=False)
        except OSError as error:
            raise ArrangeError(f"cannot run editor {command[0]!r}: {error}") from error
        if result.returncode != 0:
            raise ArrangeError(f"editor exited with status {result.returncode}")

        with open(path, encoding="utf-8") as edited_file:
            return edited_file.read()
    except OSError as error:
        raise ArrangeError(f"temporary editor file: {error}") from error
    finally:
        if path:
            try:
                os.unlink(path)
            except FileNotFoundError:
                pass


def _next_scratch_index(tmux: Tmux, session_id: str, count: int) -> int:
    output = tmux.run("list-windows", "-t", session_id, "-F", "#{window_index}")
    try:
        indices = [int(line) for line in output.splitlines() if line]
    except ValueError as error:
        raise ArrangeError("tmux returned a non-numeric window index") from error
    return max(10000, max(indices, default=0) + count + 1)


def apply_windows(
    tmux: Tmux,
    session_id: str,
    active_window_id: str,
    original: Sequence[WindowRow],
    desired: Sequence[WindowRow],
) -> list[WindowRow]:
    """Apply a validated plan and return rows with IDs assigned to new windows."""
    if not desired:
        raise ArrangeError("cannot remove every window from the tmux session")

    original_by_id = {
        row.window_id: row for row in original if row.window_id is not None
    }
    seen_ids: set[str] = set()
    for row in desired:
        if row.window_id is None:
            if not row.name.strip():
                raise ArrangeError("new window name cannot be empty")
            continue
        if row.window_id not in original_by_id:
            raise ArrangeError(f"unknown window id {row.window_id!r}")
        if row.window_id in seen_ids:
            raise ArrangeError(f"duplicate window id {row.window_id!r}")
        if not row.name.strip():
            raise ArrangeError(f"window name for {row.window_id} cannot be empty")
        seen_ids.add(row.window_id)

    # Rename known survivors before indices start moving.
    for row in desired:
        if row.window_id is None:
            continue
        old_row = original_by_id[row.window_id]
        if row.name != old_row.name:
            tmux.run("rename-window", "-t", row.window_id, row.name)

    # Create first: deleting all original windows would otherwise destroy the session.
    resolved: list[WindowRow] = []
    for row in desired:
        if row.window_id is not None:
            resolved.append(row)
            continue
        window_id = tmux.run(
            "new-window",
            "-d",
            "-P",
            "-F",
            "#{window_id}",
            "-t",
            session_id,
            "-n",
            row.name,
        ).strip()
        if not re.fullmatch(r"@\d+", window_id):
            raise ArrangeError(f"tmux returned an invalid new window id: {window_id!r}")
        resolved.append(replace(row, window_id=window_id))

    desired_ids = {row.window_id for row in resolved}
    removed_ids = [
        row.window_id
        for row in original
        if row.window_id is not None and row.window_id not in desired_ids
    ]
    active_is_removed = active_window_id in removed_ids

    # A CLI running inside the active window would be terminated if that window
    # were killed now. Delete it only after arranging and selecting a survivor.
    for window_id in removed_ids:
        if window_id != active_window_id:
            tmux.run("kill-window", "-t", window_id)

    scratch = _next_scratch_index(tmux, session_id, len(resolved) + 1)
    if active_is_removed:
        tmux.run(
            "move-window",
            "-d",
            "-s",
            active_window_id,
            "-t",
            f"{session_id}:{scratch + len(resolved)}",
        )

    for offset, row in enumerate(resolved):
        tmux.run(
            "move-window",
            "-d",
            "-s",
            row.window_id,
            "-t",
            f"{session_id}:{scratch + offset}",
        )
    for offset, row in enumerate(resolved):
        tmux.run(
            "move-window",
            "-d",
            "-s",
            row.window_id,
            "-t",
            f"{session_id}:{offset + 1}",
        )

    selected_id = resolved[0].window_id if active_is_removed else active_window_id
    tmux.run("select-window", "-t", selected_id)
    if active_is_removed:
        tmux.run("kill-window", "-t", active_window_id)

    return resolved


def current_context(tmux: Tmux) -> tuple[str, str]:
    output = tmux.run(
        "display-message",
        "-p",
        "#{session_id}\t#{window_id}\t#{client_name}",
    ).rstrip("\n")
    fields = output.split("\t")
    if len(fields) != 3 or not fields[0] or not fields[1] or not fields[2]:
        raise ArrangeError("must be run from an attached tmux client")
    return fields[0], fields[1]


def arrange_windows(tmux: Tmux | None = None) -> None:
    tmux = tmux or Tmux()
    session_id, active_window_id = current_context(tmux)
    original = list_windows(tmux, session_id)
    edited = open_editor(editor_text(original))
    desired = parse_edited_rows(edited, original)
    apply_windows(tmux, session_id, active_window_id, original, desired)


def main() -> int:
    try:
        arrange_windows()
    except ArrangeError as error:
        print(f"tmux-arrange: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
