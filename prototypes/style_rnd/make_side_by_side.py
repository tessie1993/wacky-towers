# Builds the labelled reference-vs-prototype evidence images. Run: python3 prototypes/style_rnd/make_side_by_side.py
import os
from PIL import Image, ImageDraw, ImageFont
R = "assets/art/reference/style/"
E = "production/qa/evidence/style-rnd/"
FONT = ImageFont.truetype("prototypes/style_rnd/fonts/LilitaOne-Regular.ttf", 30)

def pair(ref, ref_box, ours, ours_box, out, h=720, labels=("REFERENCE", "PROTOTYPE (Godot Compatibility)")):
    a = Image.open(ref).convert("RGB"); a = a.crop(ref_box) if ref_box else a
    b = Image.open(ours).convert("RGBA"); b = b.crop(ours_box) if ours_box else b
    if b.mode == "RGBA":
        bg = Image.new("RGB", b.size, (243, 230, 200)); bg.paste(b, mask=b.split()[3]); b = bg
    a = a.resize((int(a.width * h / a.height), h)); b = b.resize((int(b.width * h / b.height), h))
    s = Image.new("RGB", (a.width + b.width + 30, h + 60), (59, 35, 70))
    s.paste(a, (10, 50)); s.paste(b, (a.width + 20, 50))
    d = ImageDraw.Draw(s)
    d.text((14, 8), labels[0], font=FONT, fill=(246, 231, 196)); d.text((a.width + 24, 8), labels[1], font=FONT, fill=(248, 200, 64))
    s.save(E + out); print("wrote", E + out, s.size)

pair(R + "13_biome_blocks.png", (40, 20, 380, 300), E + "a_block_compat.png", (330, 20, 1000, 640), "a_block_vs_ref13.png", 560)
pair(R + "05_select_mode_a.jpg", (40, 100, 1160, 880), E + "b_ninepatch_ui.png", None, "b_ninepatch_vs_ref05.png", 560)
pair(R + "08_settings_options_tall.jpg", (0, 0, 600, 896), "prototypes/style_rnd/renders/frame_purple_vine.png", None, "b_blender_frame_vs_ref08.png", 560, ("REFERENCE", "PROTOTYPE (Blender Cycles render, 1024px)"))
pair(R + "15_title_and_hud.png", (425, 0, 838, 941), E + "c_island_meadow.png", None, "c_island_meadow_vs_ref15.png", 900)
pair(R + "15_title_and_hud.png", (843, 0, 1255, 941), E + "c_island_ice.png", None, "c_island_ice_vs_ref15.png", 900)
# tonemapper strip
ims = [Image.open(E + "a_tonemap_%s.png" % k).convert("RGB").crop((300, 0, 1000, 720)).resize((350, 360)) for k in ("linear", "filmic", "aces", "agx")]
s = Image.new("RGB", (1400, 410), (59, 35, 70)); d = ImageDraw.Draw(s)
for i, (im, k) in enumerate(zip(ims, ("LINEAR", "FILMIC", "ACES", "AGX (chosen)"))):
    s.paste(im, (i * 350, 50)); d.text((i * 350 + 10, 8), k, font=FONT, fill=(248, 200, 64) if i == 3 else (246, 231, 196))
s.save(E + "a_tonemap_strip.png"); print("wrote strip")
#for k in ("linear", "filmic", "aces", "agx"): os.remove(E + "a_tonemap_%s.png" % k)
