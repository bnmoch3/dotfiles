#!/usr/bin/env python3

import argparse
import secrets
import shutil
import string
import subprocess

MIN_LENGTH = 16
MAX_LENGTH = 4096
SYMBOLS = "-_=+@%^"


def masked_password(password, visible=3):
    return password[:visible] + "*" * (len(password) - visible)


def copy_to_clipboard(value):
    if shutil.which("pbcopy"):
        command = ["pbcopy"]
    elif shutil.which("xclip"):
        command = ["xclip", "-selection", "clipboard"]
    else:
        raise RuntimeError("No supported clipboard command found")

    subprocess.run(
        command,
        input=value,
        text=True,
        check=True,
    )


def generate_password(length=20, include_symbols=False):
    if length < MIN_LENGTH:
        raise ValueError(f"Password length should be at least {MIN_LENGTH} characters")

    if length > MAX_LENGTH:
        raise ValueError(f"Password length should not exceed {MAX_LENGTH} characters")

    required_groups = [
        string.ascii_lowercase,
        string.ascii_uppercase,
        string.digits,
    ]

    if include_symbols:
        required_groups.append(SYMBOLS)

    alphabet = "".join(required_groups)

    while True:
        password = "".join(secrets.choice(alphabet) for _ in range(length))

        if all(any(char in group for char in password) for group in required_groups):
            return password


def main():
    parser = argparse.ArgumentParser(
        description="Generate a cryptographically secure random password"
    )

    parser.add_argument(
        "-l",
        "--length",
        type=int,
        default=20,
        help=f"password length (minimum: {MIN_LENGTH}, default: 20)",
    )

    parser.add_argument(
        "-s",
        "--symbols",
        action="store_true",
        help="include at least one special character",
    )

    parser.add_argument(
        "-p",
        "--print",
        dest="print_password",
        action="store_true",
        help="print the full password instead of masking it",
    )

    args = parser.parse_args()

    try:
        password = generate_password(
            length=args.length,
            include_symbols=args.symbols,
        )
    except ValueError as exc:
        parser.error(str(exc))

    try:
        copy_to_clipboard(password)
    except (RuntimeError, OSError, subprocess.CalledProcessError) as exc:
        if not args.print_password:
            sys.exit(f"error: clipboard unavailable ({exc}); rerun with -p to print")
        print(f"warning: clipboard unavailable ({exc})", file=sys.stderr)

    if args.print_password:
        print(password)
    else:
        symbols = "yes" if args.symbols else "no"
        print(f"Copied: {masked_password(password)} | symbols: {symbols}")


if __name__ == "__main__":
    main()
