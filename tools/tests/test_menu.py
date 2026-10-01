"""Run with: python3 -m unittest discover -s tools/tests -v."""

import contextlib
import fcntl
import io
import json
import os
import pty
import select
import shutil
import signal
import struct
import sys
import tempfile
import termios
import time
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from menu import cd, common, main


class DirectoryTests(unittest.TestCase):
    def test_arbitrary_query_dispatch_and_cancel(self):
        with (
            patch.object(sys, "argv", ["menu"]),
            patch.object(main, "choose", return_value="printf 'arbitrary command'"),
            patch.object(main, "run_command", return_value=0) as run,
        ):
            self.assertEqual(main.main(), 0)
        self.assertEqual(
            run.call_args.args[0].args,
            ["zsh", "-ic", "printf 'arbitrary command'; exec zsh -i"],
        )
        with (
            patch.object(sys, "argv", ["menu"]),
            patch.object(main, "choose", return_value=None),
            patch.object(main, "run_command") as run,
        ):
            self.assertEqual(main.main(), 0)
            run.assert_not_called()

    def test_modes_and_shell(self):
        self.assertIs(cd.Directory("/tmp").mode, cd.DirectoryMode.TERMINAL)
        self.assertIsNone(cd.descend("shamiri AI"))
        command = main.resolve("cd shamiri AI")
        self.assertEqual(command.args, ["zsh", "-i"])
        self.assertTrue(command.cwd.endswith("/Desktop/shamiri_AI"))
        with (
            patch.object(os, "chdir") as chdir,
            patch.object(os, "execvp") as execute,
            patch.object(common, "wait_to_close"),
        ):
            common.run_command(command)
        chdir.assert_called_once_with(command.cwd)
        execute.assert_called_once_with("zsh", ["zsh", "-i"])

    def test_no_scan_until_tab_and_safe_paths(self):
        path = "/tmp/space ' quote $(touch unwanted)"
        with (
            patch.dict(cd.DIRECTORIES, {"safe": path}),
            patch.object(os, "scandir") as scan,
        ):
            cd.candidates()
            command = cd.resolve("safe")
            self.assertEqual(command.cwd, path)
            self.assertEqual(command.args, ["zsh", "-i"])
            self.assertIsNone(cd.descend("safe"))
            scan.assert_not_called()

    def test_children_and_errors(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name in ("zebra", "Alpha space", ".hidden"):
                (root / name).mkdir()
            (root / "file").touch()
            (root / "link").symlink_to(root / "Alpha space", target_is_directory=True)
            with patch.dict(
                cd.DIRECTORIES, {"test": cd.Directory(tmp, cd.DirectoryMode.RECURSIVE)}
            ):
                self.assertEqual(
                    list(cd.descend("test")), ["Alpha space", "link", "zebra"]
                )
            for bad in (str(root / "missing"), str(root / "file"), "bad\0path"):
                with (
                    self.subTest(path=bad),
                    patch.dict(
                        cd.DIRECTORIES,
                        {"bad": cd.Directory(bad, cd.DirectoryMode.RECURSIVE)},
                    ),
                ):
                    self.assertIsNone(cd.descend("bad"))
                    with (
                        patch.object(common, "wait_to_close"),
                        contextlib.redirect_stderr(io.StringIO()) as errors,
                    ):
                        self.assertEqual(common.run_command(cd.resolve("bad")), 1)
                    self.assertIn("Failed to change directory", errors.getvalue())


@unittest.skipUnless(shutil.which("fzf"), "fzf is required for real terminal tests")
class FzfTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / "Desktop" / "Projects" / "Nested space").mkdir(parents=True)
        (self.root / "Desktop" / "Screenshots").mkdir()
        (self.root / "Desktop" / "shamiri_AI").mkdir()
        (self.root / "Desktop" / ".hidden").mkdir()
        (self.root / "Desktop" / "file").touch()

    def choose(self, keys):
        result = self.root / "result.json"
        state = self.root / "state.json"
        result.unlink(missing_ok=True)
        state.unlink(missing_ok=True)
        pid, fd = pty.fork()
        if pid == 0:
            try:
                fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 120, 0, 0))
                os.environ.update(
                    HOME=str(self.root), TERM="xterm-256color", FZF_DEFAULT_OPTS=""
                )
                value = main.choose(state)
                command = (
                    main.resolve(value, main.read_children(state)) if value else None
                )
                result.write_text(
                    json.dumps(
                        {
                            "choice": value,
                            "cwd": command.cwd if command else None,
                            "args": command.args if command else None,
                        }
                    )
                )
                os._exit(0)
            except BaseException:  # noqa: BLE001 - the forked child must exit on any failure
                import traceback

                traceback.print_exc()
                os._exit(1)

        def drain(seconds):
            end = time.monotonic() + seconds
            while time.monotonic() < end:
                if select.select([fd], [], [], 0.03)[0]:
                    try:
                        os.read(fd, 65536)
                    except OSError:
                        break

        try:
            drain(0.4)
            for key in keys:
                os.write(fd, key)
                drain(1.0)
            deadline = time.monotonic() + 5
            while not result.exists() and time.monotonic() < deadline:
                drain(0.1)
            self.assertTrue(result.exists(), "fzf did not finish")
            return json.loads(result.read_text()), main.read_children(state)
        finally:
            os.kill(pid, signal.SIGTERM)
            os.waitpid(pid, 0)
            os.close(fd)

    def test_terminal_enter_and_tab(self):
        for keys in ([b"cd shamiri AI", b"\r"], [b"cd shamiri AI", b"\t", b"\r"]):
            value, state = self.choose(keys)
            self.assertEqual(value["cwd"], str(self.root / "Desktop" / "shamiri_AI"))
            self.assertIsNone(state)

    def test_recursive_enter(self):
        value, _ = self.choose([b"cd desktop", b"\r"])
        self.assertEqual(value["cwd"], str(self.root / "Desktop"))

    def test_enter_opens_submenu(self):
        value, _ = self.choose([b"gi", b"\r", b"status", b"\r"])
        self.assertEqual(value["args"], ["git", "status"])

    def test_empty_directory(self):
        value, state = self.choose([b"cd desktop", b"\t", b"Screenshots", b"\t", b"\r"])
        self.assertEqual(state, {})
        self.assertIsNone(value["choice"])

    def test_recursive_filter_and_nested_enter(self):
        value, state = self.choose(
            [b"cd desktop", b"\t", b"Projects", b"\t", b"Nested", b"\r"]
        )
        self.assertEqual(list(state), ["Nested space"])
        self.assertEqual(
            value["cwd"], str(self.root / "Desktop" / "Projects" / "Nested space")
        )

    def test_one_level_and_cancel(self):
        value, state = self.choose([b"cd desktop", b"\t", b"\x1b"])
        self.assertIsNone(value["choice"])
        self.assertEqual(list(state), ["Projects", "Screenshots", "shamiri_AI"])

    def test_other_submenus_and_query(self):
        for query in ("git status", "tmux arrange", "browser hackernews"):
            with self.subTest(query=query):
                value, _ = self.choose([query.encode(), b"\t", b"\r"])
                self.assertEqual(value["args"], main.resolve(query).args)
        value, _ = self.choose([b"printf arbitrary", b"\x18"])
        self.assertEqual(value["choice"], "printf arbitrary")

    def test_namespace_switch_and_ctrl_x_while_browsing(self):
        value, state = self.choose([b"cd desktop", b"\t", b"\x15git status", b"\r"])
        self.assertIsNone(state)
        self.assertEqual(value["args"], ["git", "status"])
        value, _ = self.choose([b"cd desktop", b"\t", b"Projects", b"\x18"])
        self.assertEqual(value["choice"], "cd Projects")


if __name__ == "__main__":
    unittest.main()
