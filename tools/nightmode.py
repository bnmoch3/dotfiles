#!/usr/bin/env python3

import subprocess
import sys

TEMPERATURES = {
    "day": None,
    "warm": 3500,
    "warmer": 2500,
    "night": 1500,
}


def choose():
    proc = subprocess.run(
        ["fzf", "--prompt=color temp> "],
        input="\n".join(TEMPERATURES),
        text=True,
        capture_output=True,
    )

    if proc.returncode != 0:
        return None

    return proc.stdout.strip()


def set_temperature(choice):
    if choice not in TEMPERATURES:
        print(f"Unknown color temperature: {choice!r}", file=sys.stderr)
        return 1

    temperature = TEMPERATURES[choice]

    try:
        subprocess.run(
            ["redshift", "-x"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        if temperature is not None:
            subprocess.run(
                ["redshift", "-o", "-O", str(temperature)],
                check=True,
            )

    except FileNotFoundError:
        print("Command not found: 'redshift'", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as exc:
        print(
            f"redshift failed with exit code {exc.returncode}",
            file=sys.stderr,
        )
        return 1

    return 0


def main():
    choice = choose()

    if choice is None:
        return 0

    return set_temperature(choice)


if __name__ == "__main__":
    if sys.platform != "linux":
        print("color_temperature.py currently supports Linux only.", file=sys.stderr)
        raise SystemExit(1)
    raise SystemExit(main())
