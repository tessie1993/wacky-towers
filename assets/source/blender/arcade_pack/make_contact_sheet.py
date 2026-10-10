"""Arrange Blender look-check renders; run after build_arcade_pack.py."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[4]
EVIDENCE=ROOT/"production/qa/evidence/arcade_pack"
font=ImageFont.truetype("DejaVuSans.ttf",26)
small=ImageFont.truetype("DejaVuSans.ttf",20)
names=[("meadow","MEADOW · Bridge and breeze"),("clockwork","CLOCKWORK · Repair and rhythm"),("celestial","CELESTIAL · Shadows and stars")]
tile=600
header=92
row_header=32
sheet=Image.new("RGB",(tile*3,header+(tile+row_header)*3),(224,226,232))
d=ImageDraw.Draw(sheet)
for col,(key,label) in enumerate(names):
    d.text((col*tile+22,18),label,font=font,fill=(45,42,52))
    d.text((col*tile+22,54),"Blender 4.5.9 · matte diorama · top Y=0",font=small,fill=(92,86,101))
    for row,view in enumerate(("front","rear","top")):
        im=Image.open(EVIDENCE/("blender_env_"+key+"_arcade_"+view+".png")).convert("RGB")
        im=im.resize((tile,tile),Image.Resampling.LANCZOS)
        yy=header+row*(tile+row_header)
        d.text((col*tile+22,yy+5),view.upper(),font=small,fill=(65,60,74))
        sheet.paste(im,(col*tile,yy+row_header))
sheet.save(EVIDENCE/"blender_arcade_contact_sheet.png")
print(EVIDENCE/"blender_arcade_contact_sheet.png")
