import os
import shutil
import unittest
import uuid

from tmux.arrange_windows import (
    ArrangeError,
    Tmux,
    WindowRow,
    apply_windows,
    current_context,
    parse_edited_rows,
    parse_window_line,
)

ORIGINAL = [
    WindowRow("main", "@1"),
    WindowRow("application logs", "@2"),
    WindowRow("editor", "@3"),
]


class ParseEditedRowsTests(unittest.TestCase):
    def test_parses_existing_window(self):
        self.assertEqual(
            parse_edited_rows("renamed @1\n", ORIGINAL),
            [WindowRow("renamed", "@1")],
        )

    def test_preserves_spaces_in_names(self):
        rows = parse_edited_rows(
            "my application logs @2\nnew scratch window\n", ORIGINAL
        )
        self.assertEqual(
            rows,
            [WindowRow("my application logs", "@2"), WindowRow("new scratch window")],
        )

    def test_parses_new_line_without_id(self):
        self.assertEqual(parse_edited_rows("api\n", ORIGINAL), [WindowRow("api")])

    def test_ignores_blank_and_comment_lines(self):
        text = "\n  # instructions\n\t\nmain @1\n"
        self.assertEqual(parse_edited_rows(text, ORIGINAL), [WindowRow("main", "@1")])

    def test_rejects_unknown_id(self):
        with self.assertRaisesRegex(ArrangeError, "unknown window id '@999'"):
            parse_edited_rows("mystery @999\n", ORIGINAL)

    def test_rejects_duplicate_existing_id(self):
        with self.assertRaisesRegex(ArrangeError, "duplicate window id '@1'"):
            parse_edited_rows("main @1\ncopy @1\n", ORIGINAL)

    def test_rejects_deleting_all_windows(self):
        with self.assertRaisesRegex(ArrangeError, "cannot remove every window"):
            parse_edited_rows("# nothing remains\n\n", ORIGINAL)

    def test_rejects_empty_existing_name(self):
        with self.assertRaisesRegex(ArrangeError, "window name for @1 cannot be empty"):
            parse_edited_rows("@1\n", ORIGINAL)

    def test_rejects_empty_new_window_name(self):
        with self.assertRaisesRegex(ArrangeError, "new window name cannot be empty"):
            parse_window_line("   ", {"@1"})


@unittest.skipUnless(shutil.which("tmux"), "tmux is not installed")
class TmuxIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.socket_name = f"tmux-arrange-test-{os.getpid()}-{uuid.uuid4().hex}"
        clean_env = os.environ.copy()
        clean_env.pop("TMUX", None)
        clean_env.pop("TMUX_PANE", None)
        self.tmux = Tmux(("tmux", "-L", self.socket_name), env=clean_env)
        self.tmux.run("new-session", "-d", "-s", "arrange-test", "-n", "main")
        self.tmux.run("new-window", "-d", "-t", "arrange-test", "-n", "logs")
        self.tmux.run("new-window", "-d", "-t", "arrange-test", "-n", "editor")
        self.session_id = self.tmux.run(
            "display-message", "-p", "-t", "arrange-test", "#{session_id}"
        ).strip()
        self.original = self._rows()

    def tearDown(self):
        try:
            self.tmux.run("kill-server")
        except ArrangeError:
            pass

    def _state(self):
        output = self.tmux.run(
            "list-windows",
            "-t",
            self.session_id,
            "-F",
            "#{window_index}\t#{window_name}\t#{window_id}\t#{window_active}",
        )
        return [line.split("\t") for line in output.splitlines()]

    def _rows(self):
        return [WindowRow(fields[1], fields[2]) for fields in self._state()]

    def _apply(self, desired, active_offset=0):
        active_id = self.original[active_offset].window_id
        self.tmux.run("select-window", "-t", active_id)
        return apply_windows(
            self.tmux, self.session_id, active_id, self.original, desired
        )

    def test_reorder_only_and_restore_active(self):
        self._apply(
            [self.original[2], self.original[0], self.original[1]], active_offset=1
        )
        state = self._state()
        self.assertEqual([row[1] for row in state], ["editor", "main", "logs"])
        self.assertEqual([row[0] for row in state], ["1", "2", "3"])
        self.assertEqual(
            next(row[2] for row in state if row[3] == "1"),
            self.original[1].window_id,
        )

    def test_rename_only(self):
        desired = [
            self.original[0],
            WindowRow("application logs", self.original[1].window_id),
            self.original[2],
        ]
        self._apply(desired)
        self.assertEqual(
            [row[1] for row in self._state()],
            ["main", "application logs", "editor"],
        )

    def test_delete_one_window(self):
        self._apply([self.original[0], self.original[2]])
        self.assertEqual([row[1] for row in self._state()], ["main", "editor"])

    def test_create_one_new_window(self):
        resolved = self._apply([self.original[0], WindowRow("api"), *self.original[1:]])
        self.assertIsNotNone(resolved[1].window_id)
        self.assertEqual(
            [row[1] for row in self._state()],
            ["main", "api", "logs", "editor"],
        )

    def test_create_multiple_new_windows(self):
        self._apply(
            [
                WindowRow("api"),
                self.original[0],
                WindowRow("scratch"),
                *self.original[1:],
            ]
        )
        self.assertEqual(
            [row[1] for row in self._state()],
            ["api", "main", "scratch", "logs", "editor"],
        )

    def test_combined_create_delete_rename_and_reorder(self):
        desired = [
            WindowRow("renamed editor", self.original[2].window_id),
            WindowRow("api server"),
            self.original[0],
        ]
        self._apply(desired)
        state = self._state()
        self.assertEqual(
            [row[1] for row in state], ["renamed editor", "api server", "main"]
        )
        self.assertEqual([row[0] for row in state], ["1", "2", "3"])

    def test_deleting_originally_active_window_selects_first_remaining(self):
        desired = [self.original[2], self.original[0]]
        self._apply(desired, active_offset=1)
        state = self._state()
        self.assertEqual([row[1] for row in state], ["editor", "main"])
        self.assertEqual(
            next(row[2] for row in state if row[3] == "1"),
            self.original[2].window_id,
        )

    def test_replacing_every_original_window_with_a_new_one(self):
        self._apply([WindowRow("replacement")], active_offset=1)
        state = self._state()
        self.assertEqual([(row[0], row[1]) for row in state], [("1", "replacement")])

    def test_detached_session_is_not_treated_as_a_real_client(self):
        with self.assertRaisesRegex(ArrangeError, "attached tmux client"):
            current_context(self.tmux)


if __name__ == "__main__":
    unittest.main()
