# UI kit v2: style notes

Written 2026-10-13 by technical-artist before the Blender kit was built. Sources:
`assets/art/reference/style/01`–`15`, the root `assets/art/reference/*` sheets, all 26 unique
minigame mockups, and the user uploads. Two upload boards show Nintendo characters. They were
read for HUD layout only, and nothing from them is reproduced. One upload (a flat vector card with
a red cross over it) is the user rejecting flat clip-art. The kit must never look like that.

Pixel sizes below are measured on the 1200 px wide refs (05, 06, 04, 08) unless stated.

## Overall
- Toy-like, painted 3D. Every piece has thickness, a rounded bevel, a lit top edge (warm cream
  highlight) and a darker bottom or right side. Light comes from the top and slightly left. Under
  each piece is a soft, plum-tinted drop shadow, offset downward by 3–6 px.
- There are no hairline outlines. The edge reads as a darker bevel band, about 3–5 px wide.
- The materials look hand-painted. Gradients are soft, grain shows as a few broad streaks rather
  than photo noise, and saturation is high.

## Purple wood frame (05, 06, 08 sides, 04 outer)
- **Thickness.** The frame is 55–70 px of a 1200 px screen, about 5 % of the width. The top and
  bottom rails are wider planks than the side posts, and they overhang the posts by 20–40 px with
  rounded plank ends.
- **Construction.** It is built from 4 separate planks. The top and bottom are horizontal planks.
  The sides are vertical posts with grain along their length. Plank ends are rounded and have a
  darker end-grain rim. Faint seam lines run along some planks.
- **Colours.** Mid `#6b4a8a`, shadow and grain `#3f2a55`, top-edge highlight `#9a78b8`.
- **Inner edge.** A dark bevel (shadow `#3f2a55`) sits where the frame meets the parchment or the
  scene, so the frame looks raised above the content.
- **Corners.** Ref 04 has metal and purple corner brackets with a gold star, plus 2–4
  grey-violet rivets. Ref 08 has a star on a purple block corner and rope wrapping the corner.
- **Vines.** Green (`#4f9a3a`, highlight `#8fd05a`) vines, 5–8 px thick, curl from the corners
  along about 15–25 % of each edge. Leaves are small and teardrop-shaped. White five-petal
  blossoms with yellow centres are 12–18 px across, in clusters of 2–3 near the corners. The
  middles of the edges stay clean, which suits a nine-patch.

## Parchment (06 inner, 14 panels, 15 chips)
- The fill is cream `#f6e7c4` with soft mottling. The edges are warmer and darker
  (`#e2c995`), with a thin, slightly burnt brown rim.
- A soft inner shadow, 10–20 px wide, runs along the top and left edges. The corner radius is
  large: 20–30 px on panels and about 14 px on chips.
- In ref 14 the parchment panels sit inside a brown wooden rim about 12 px wide, with nails or
  rivets at the corners.

## Gold buttons (BACK, DONE, PLAY, READY)
- A full pill (radius = half the height) with a glossy gold face `#f8c840`. It sits on a thick
  darker lip `#c98418`, 6–10 px tall, that shows only below the face, so the button looks like
  it stands up. A dark plum or brown outer rim is about 3 px.
- A white-cream specular streak (`#fff3b0` to white) runs across the upper third, inset from the
  ends, with a soft lower edge.
- On the left is a gold star icon with its own bevel. The text is dark plum, ALL CAPS, Fredoka
  or Lilita, 32–40 px.
- PLAY on the title screen (ref 15 left) is larger and has a wood-framed backer.

## Cream and wood buttons (08 CREDITS and SUPPORT, 04 CONNECT and LOW, 15 BIOMES)
- These are the same pill or rounded-rect build with a cream face `#fff4dc` and a brown lip
  `#8a5a34`. The wood variant (08 SWIPE, LOW) has a brown plank face and cream text.

## Close button
- A rounded square (04, 08) or circle (05, 06), 50–60 px. The face is a red gem `#e0483c`
  with a darker lower half and a glossy top highlight. The rim is gold, 4–6 px. The white × is
  thick, with rounded ends.

## Title plaque (05, 06 "SELECT MODE"; 04 and 08 "SETTINGS")
- It is a purple-wood plaque about 420×90 px with rounded ends and a gold trim band around it,
  6–8 px. Gold scroll curls sit at both ends, and a small gold peak or crest sits top-centre.
  In 08 the plaque is brown wood instead.
- **Multicolour title letters.** Each letter is a separate chunky, rounded glyph in its own
  candy colour. In order, the colours repeat orange `#f08a2c`, cream, blue, green, lilac and
  pink. Each glyph has a thick dark-brown outline (4–6 px), a lighter top bevel, a darker
  bottom, and a drop shadow onto the plaque. The letters are slightly rotated or bounced. This
  is text, not part of the nine-patch. It should be built in Godot (per-glyph colour with
  outline and shadow) or baked per title.

## Signboards (04 section headings, 03 card labels, 06/05 card labels)
- A brown plank `#8a5a34` with rounded ends and a lit top edge. Cream text with a brown outline
  sits on it. The board is about 180×44 px. In ref 04 the boards sit on the rope border of each
  group, with vines around them.

## HUD chips (15)
- **Meadow.** A parchment card inside a brown and green wooden frame (about 10 px) with leaves
  and vines at the corners.
- **Ice.** A frosted blue frame `#7fb3d9` with white snow caps on the top edge.
- **Celestial.** A deep purple and blue frame with gold trim and small gold stars.
- Content: a small "SCORE" label, a big number and a row of three stars. NEXT is a square chip
  of the same build.
- The bottom tray is a 3-slot parchment shelf in the same biome frame.

## Controls (08, 04)
- **Toggle.** A rounded track: green `#4cc04a` "ON", or cream with a red bell. The knob is a
  round cream button holding a gold star.
- **Slider.** Ref 08 uses a brown branch or stick with a gold star thumb. Ref 04 uses a dark
  groove with a blue or orange fill and a gold star thumb.
