import argparse
import os
import shutil
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Open an image file or directory in EOG"
    )
    parser.add_argument(
        "path",
        help="image file or directory",
    )

    args = parser.parse_args()

    path = os.path.abspath(os.path.expanduser(args.path))

    if not os.path.exists(path):
        parser.error(f"path not found: {path}")

    viewer = shutil.which("eog")
    if viewer is None:
        parser.error("eog is not installed")

    try:
        subprocess.Popen(
            [viewer, path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError as exc:
        print(f"Failed to open image: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
