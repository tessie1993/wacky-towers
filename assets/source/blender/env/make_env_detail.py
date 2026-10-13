"""make_env_detail.py - packs CC0 Poly Haven textures into one 256x256 RGBA detail map.

  R = cliff_side diffuse luminance  (island underside / lip rock)
  G = rock_face diffuse luminance   (stone grid tiles, props)
  B = leafy_grass diffuse luminance (island top grass)
  A = cliff_side displacement       (lava veins / strata mask)

Each channel is downsampled from the 1k source (tileable) and contrast-normalised so the
shaders can use it as a +-detail multiplier. Output: assets/models/env/env_detail.png.
Run: python3 -I assets/source/blender/env/make_env_detail.py
Sources and authors: assets/third_party/CREDITS.md.
"""
import os
from PIL import Image, ImageOps

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
PH = os.path.join(ROOT, "assets", "third_party", "polyhaven")
SIZE = 256


def chan(rel):
    im = Image.open(os.path.join(PH, rel))
    if im.mode == "I;16" or im.mode == "I":
        im = im.point(lambda v: v / 256).convert("L")
    im = im.convert("L").resize((SIZE, SIZE), Image.LANCZOS)
    return ImageOps.autocontrast(im, cutoff=1)


r = chan("cliff_side/cliff_side_diff_1k.jpg")
g = chan("rock_face/rock_face_diff_1k.jpg")
b = chan("leafy_grass/leafy_grass_diff_1k.jpg")
a = chan("cliff_side/cliff_side_disp_1k.png")
out = os.path.join(ROOT, "assets", "models", "env", "env_detail.png")
Image.merge("RGBA", (r, g, b, a)).save(out)
print("wrote", out)
