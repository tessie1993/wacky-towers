"""UI kit v2 post-step: x1 downscales, ninepatch_x1.json, and the review contact sheet.

  python3 assets/source/blender/ui/kit_post.py <repo_root>

Reads the 2x renders and margins_x2.json written by build_ui_kit.py.
"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
X2 = os.path.join(ROOT, "assets/art/ui/kit/x2")
X1 = os.path.join(ROOT, "assets/art/ui/kit/x1")
META = json.load(open(os.path.join(ROOT, "assets/source/blender/ui/margins_x2.json")))
EVID = os.path.join(ROOT, "production/qa/evidence/ui-kit-v2")
# Legacy names still used by src/ui/game_ui.gd and older wt_storybook code -> new pieces.
ALIASES = {"btn_gold_pill": "btn_gold", "btn_cream_pill": "btn_cream", "btn_wood_square": "btn_cream",
           "btn_wood_square_pressed": "btn_cream", "chip_hud_meadow": "chip_hud"}

os.makedirs(X1, exist_ok=True)
os.makedirs(EVID, exist_ok=True)
patches = {}
for name, m in META.items():
    im = Image.open(os.path.join(X2, name + ".png")).convert("RGBA")
    half = im.resize((im.width // 2, im.height // 2), Image.LANCZOS)
    half.save(os.path.join(X1, name + ".png"), optimize=True)
    patches[name] = {"file": "res://assets/art/ui/kit/x1/%s.png" % name,
                     "left": m["left"] // 2, "top": m["top"] // 2, "right": m["right"] // 2, "bottom": m["bottom"] // 2,
                     "size": [half.width, half.height]}
for alias, target in ALIASES.items():
    if target in patches:
        patches[alias] = dict(patches[target], alias_of=target)
json.dump({"scale": 1, "source_scale": 2, "patches": patches}, open(os.path.join(X1, "ninepatch_x1.json"), "w"), indent=1)


def nine(im, m, w, h):
    """Stretch like Godot StyleBoxTexture (AXIS_STRETCH_MODE_STRETCH)."""
    l, t, r, b = m
    out = Image.new("RGBA", (w, h))
    xs = [(0, l, 0, l), (l, im.width - r, l, w - r), (im.width - r, im.width, w - r, w)]
    ys = [(0, t, 0, t), (t, im.height - b, t, h - b), (im.height - b, im.height, h - b, h)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            if sx1 <= sx0 or sy1 <= sy0 or dx1 <= dx0 or dy1 <= dy0: continue
            out.alpha_composite(im.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.LANCZOS), (dx0, dy0))
    return out


def kit(name):
    p = patches[name]
    return Image.open(p["file"].replace("res://", ROOT + "/")).convert("RGBA"), (p["left"], p["top"], p["right"], p["bottom"])


def font(sz):
    for f in ("assets/fonts/fredoka/fredoka-700.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"):
        if os.path.exists(os.path.join(ROOT, f)) or os.path.exists(f):
            return ImageFont.truetype(os.path.join(ROOT, f) if os.path.exists(os.path.join(ROOT, f)) else f, sz)
    return ImageFont.load_default()


# ---- mock "Select Mode" screen built only from x1 kit pieces (1200x896, like ref 06)
mock = Image.new("RGBA", (1200, 896), (60, 44, 70, 255))
g = ImageDraw.Draw(mock)
for y in range(896):
    c = int(70 + 40 * y / 896)
    g.line([(0, y), (1200, y)], fill=(c, int(c * 0.8), c + 30, 255))
fr, fm = kit("frame_purple")
mock.alpha_composite(nine(fr, fm, 1090, 720), (55, 120))
for i, (x, y, w, h) in enumerate([(200, 235, 380, 230), (625, 235, 380, 230), (175, 510, 270, 220), (470, 510, 270, 220), (765, 510, 270, 220)]):
    ch, cm = kit(["chip_hud", "chip_hud_ice", "chip_hud_celestial", "panel_wood", "chip_hud"][i])
    mock.alpha_composite(nine(ch, cm, w, h), (x, y))
    sg, sm = kit("sign_heading")
    sgi = nine(sg, sm, w - 60, 54)
    mock.alpha_composite(sgi, (x + 30, y + h - 70))
    ImageDraw.Draw(mock).text((x + w // 2, y + h - 43), ["STORY", "CAMPAIGN", "TOURNAMENT", "ARCADE", "BIOMES"][i],
                              font=font(26), fill=(255, 244, 220, 255), anchor="mm", stroke_width=2, stroke_fill=(78, 47, 26, 255))
pl, pm = kit("plaque_title")
mock.alpha_composite(nine(pl, pm, 460, 100), (370, 72))
palette = [(240, 138, 44), (246, 226, 184), (74, 168, 232), (108, 192, 74), (180, 138, 216), (238, 106, 160)]
x = 430
for k, chh in enumerate("SELECT MODE"):
    f = font(46)
    if chh != " ":
        ImageDraw.Draw(mock).text((x, 122), chh, font=f, fill=palette[k % 6] + (255,), anchor="lm", stroke_width=4, stroke_fill=(62, 34, 30, 255))
    x += f.getlength(chh) + 2
cl, cm2 = kit("btn_close")
mock.alpha_composite(cl, (1070, 100))
bg_, bm = kit("btn_gold")
mock.alpha_composite(nine(bg_, bm, 300, 84), (450, 790))
st, _ = kit("slider_star_thumb")
mock.alpha_composite(st.resize((54, 54), Image.LANCZOS), (482, 803))
ImageDraw.Draw(mock).text((640, 826), "BACK", font=font(40), fill=(59, 35, 70, 255), anchor="mm")
mock.convert("RGB").save(os.path.join(EVID, "mock_select_mode.png"))

# ---- contact sheet: ref 06 | mock | every piece at 2x and stretched
ref = Image.open(os.path.join(ROOT, "assets/art/reference/style/06_select_mode_b.jpg")).convert("RGBA").resize((1200, 896))
W = 2400 + 40
sheet = Image.new("RGBA", (W, 896 + 40 + 1300), (236, 230, 242, 255))
sheet.alpha_composite(ref, (0, 0))
sheet.alpha_composite(mock, (1240, 0))
d = ImageDraw.Draw(sheet)
d.text((10, 900), "LEFT: reference 06   RIGHT: mock built only from kit v2 pieces (x1, Godot-style nine-patch stretch)", font=font(22), fill=(59, 35, 70, 255))
x, y, rowh = 20, 950, 0
for name in META:
    im = Image.open(os.path.join(X2, name + ".png"))
    if x + im.width > W - 20:
        x, y, rowh = 20, y + rowh + 50, 0
    # checker behind so alpha edges show
    ch = Image.new("RGBA", im.size, (255, 255, 255, 255))
    cd = ImageDraw.Draw(ch)
    for cy in range(0, im.height, 16):
        for cx in range(0, im.width, 16):
            if (cx // 16 + cy // 16) % 2: cd.rectangle([cx, cy, cx + 15, cy + 15], fill=(214, 206, 222, 255))
    ch.alpha_composite(im)
    sheet.alpha_composite(ch, (x, y))
    d.text((x, y + im.height + 4), "%s %dx%d" % (name, im.width, im.height), font=font(18), fill=(59, 35, 70, 255))
    x += im.width + 24
    rowh = max(rowh, im.height)
sheet.convert("RGB").save(os.path.join(EVID, "contact_sheet.png"))
print("POST_DONE", len(patches), "patches")
