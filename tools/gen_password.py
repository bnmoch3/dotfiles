#!/usr/bin/env python3

import argparse
import secrets
import string

SYMBOLS = "!@#$%^&*()-_=+"


def generate_password(length=20, include_symbols=False):
    if length < 16:
        raise ValueError("Password length should be at least 16 characters")

    alphabet = string.ascii_letters + string.digits + "-"

    if include_symbols:
        alphabet += SYMBOLS

    return "".join(secrets.choice(alphabet) for _ in range(length))


def main():
    parser = argparse.ArgumentParser(description="Generate a random password")

    parser.add_argument(
        "-l",
        "--length",
        type=int,
        default=20,
        help="password length (minimum: 16, default: 20)",
    )

    parser.add_argument(
        "-s",
        "--symbols",
        action="store_true",
        help="include special characters",
    )

    args = parser.parse_args()

    try:
        password = generate_password(
            length=args.length,
            include_symbols=args.symbols,
        )
    except ValueError as exc:
        parser.error(str(exc))

    print(password)


if __name__ == "__main__":
    main()
