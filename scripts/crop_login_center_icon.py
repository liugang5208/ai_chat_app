#!/usr/bin/env python3.9
"""
Crop the center icon from ui-images/login_background_top.png.

Usage:
  python3.9 scripts/crop_login_center_icon.py
  python3.9 scripts/crop_login_center_icon.py --bbox 180,80,388,312
  python3.9 scripts/crop_login_center_icon.py --input path/to/input.png --output path/to/output.png
"""

import argparse
from pathlib import Path

from PIL import Image


DEFAULT_INPUT = Path("ui-images/login_background_top.png")
DEFAULT_OUTPUT = Path("ui-images/login_center_icon.png")

# (left, top, right, bottom), tuned for login_background_top.png (563x434)
DEFAULT_BBOX = (180, 80, 388, 312)


def parse_bbox(raw: str) -> tuple[int, int, int, int]:
    parts = [p.strip() for p in raw.split(",")]
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("bbox must be in format: left,top,right,bottom")
    try:
        left, top, right, bottom = [int(v) for v in parts]
    except ValueError as exc:
        raise argparse.ArgumentTypeError("bbox values must be integers") from exc
    if left >= right or top >= bottom:
        raise argparse.ArgumentTypeError("bbox must satisfy left < right and top < bottom")
    return (left, top, right, bottom)


def main() -> None:
    parser = argparse.ArgumentParser(description="Crop center icon from login background image.")
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT, help=f"Input image path (default: {DEFAULT_INPUT})")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help=f"Output image path (default: {DEFAULT_OUTPUT})")
    parser.add_argument(
        "--bbox",
        type=parse_bbox,
        default=DEFAULT_BBOX,
        help="Crop box as left,top,right,bottom (default tuned for login_background_top.png)",
    )
    args = parser.parse_args()

    if not args.input.exists():
        raise FileNotFoundError(f"Input image not found: {args.input}")

    image = Image.open(args.input)
    width, height = image.size
    left, top, right, bottom = args.bbox
    if left < 0 or top < 0 or right > width or bottom > height:
        raise ValueError(f"bbox {args.bbox} is out of image bounds {(width, height)}")

    cropped = image.crop(args.bbox)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    cropped.save(args.output)

    print(f"Input:  {args.input} ({width}x{height})")
    print(f"BBox:   {args.bbox}")
    print(f"Output: {args.output} ({cropped.size[0]}x{cropped.size[1]})")


if __name__ == "__main__":
    main()
