#!/usr/bin/env python3

import argparse
import os

from PIL import Image
from rich.console import Console
from rich_pixels import Pixels


def fit_to_terminal(im, cols, rows, margin_rows=0):
    max_w_px = max(1, cols)
    usable_rows = max(1, rows - max(0, margin_rows))
    max_h_px = max(2, usable_rows * 2)

    width_scale = min(1.0, max_w_px / im.width)
    height_scale = min(1.0, max_h_px / im.height)
    scale = min(width_scale, height_scale)

    new_w = max(1, int(im.width * scale))
    new_h = max(2, int(im.height * scale))

    if new_h % 2:
        new_h -= 1

    new_h = min(new_h, max_h_px - (max_h_px % 2))

    return new_w, new_h


def main():
    parser = argparse.ArgumentParser(
        description="Display an image inline in the terminal"
    )
    parser.add_argument("image", help="Path to the image file")
    parser.add_argument(
        "--margin-rows",
        type=int,
        default=0,
        help="terminal rows to reserve at the bottom",
    )
    parser.add_argument(
        "--lanczos",
        action="store_true",
        help="use high-quality downscaling",
    )
    args = parser.parse_args()

    console = Console()

    if not os.path.isfile(args.image):
        console.print(f"[red]File not found:[/red] {args.image}")
        raise SystemExit(1)

    with Image.open(args.image) as image:
        new_width, new_height = fit_to_terminal(
            image,
            console.size.width,
            console.size.height,
            args.margin_rows,
        )

        resample = Image.LANCZOS if args.lanczos else Image.NEAREST
        resized = image.resize((new_width, new_height), resample)

        pixels = Pixels.from_image(resized)

    console.print(pixels)


if __name__ == "__main__":
    main()
