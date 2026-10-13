#!/usr/bin/env python3
"""Cut UI sprites out of the art reference sheets (flood-fill the flat background).

Sources: assets/art/reference/wizard_turnaround_ref.png, logo_ref.jpg.
Output:  assets/art/ui/*.png (transparent, trimmed, max 768 px).
Usage:   python3 tools/art/cutout_refs.py
"""
from collections import deque
from pathlib import Path
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "assets/art/reference"
OUT = ROOT / "assets/art/ui"
MAX_SIDE = 1024
STEP = 12

CUTS = [
    ("wizard_turnaround_ref.png", (40, 30, 480, 495), "wizard_front.png", 9),
    ("wizard_turnaround_ref.png", (60, 515, 470, 932), "wizard_idle.png", 9),
    ("wizard_turnaround_ref.png", (485, 518, 905, 932), "wizard_cheer.png", 9),
    ("wizard_turnaround_ref.png", (912, 518, 1305, 932), "wizard_oops.png", 9),
    ("logo_master.jpg", None, "logo_wacky_towers.png", 14),
]


def cutout(img: Image.Image, tolerance: int) -> Image.Image:
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    border = [px[x, 0] for x in range(w)] + [px[x, h - 1] for x in range(w)]
    bg = tuple(sorted(c[i] for c in border)[len(border) // 2] for i in range(3))
    def near(c):
        return abs(c[0] - bg[0]) + abs(c[1] - bg[1]) + abs(c[2] - bg[2]) < tolerance * 3

    def smooth(a, b):
        # Stop at any local colour step: outlines and soft shading end the fill.
        return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2]) < STEP
    seen = bytearray(w * h)
    queue = deque()
    for x in range(w):
        queue.append((x, 0)); queue.append((x, h - 1))
    for y in range(h):
        queue.append((0, y)); queue.append((w - 1, y))
    mask = Image.new("L", (w, h), 255)
    mp = mask.load()
    while queue:
        x, y = queue.popleft()
        i = y * w + x
        if seen[i]:
            continue
        seen[i] = 1
        if not near(px[x, y]):
            continue
        mp[x, y] = 0
        here = px[x, y]
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx] and smooth(here, px[nx, ny]):
                queue.append((nx, ny))
    # Soften the cut edge by a pixel so sprites sit cleanly on any backdrop.
    mask = mask.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
    img.putalpha(mask)
    return img.crop(mask.getbbox())


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for src, box, name, tol in CUTS:
        img = Image.open(REF / src)
        if box:
            img = img.crop(box)
        sprite = cutout(img, tol)
        sprite.thumbnail((MAX_SIDE, MAX_SIDE), Image.LANCZOS)
        sprite.save(OUT / name)
        print(name, sprite.size)


if __name__ == "__main__":
    main()
