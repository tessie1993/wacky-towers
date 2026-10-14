# Shared look r1: Art Director review (blind)

Scope: lighting-v1 (before/after, contact sheets, weather) and blocks-v4. Judged as a build, against
`assets/art/reference/biome_block_materials_ref.png`, `biome_screens_ref.jpg` and the style boards.
Pass mark 9.7. Not viewed: other reviews. Viewed: lighting-v1 before/after contact sheets, after/biome_meadow.png,
after/biome_lava.png, blocks-v4/ingame_vs_ref13_set.png, the references. Not individually viewed: the other 10 after/
biome captures, the weather_after captures (judged from the contact sheet only).

## Scoreboard

| Item | Score | Basis |
|---|---|---|
| A1 Lighting mood and shading | 6.5 | Real gain: after_contact.png has warm/violet separation, rimmed island edges, and a dark floor in cave/neon/lava. Defects below cap it. |
| A2 Colour and value hierarchy (board, rim, pieces) | 5.5 | Pieces are the lowest-value, lowest-chroma objects on most boards. |
| A3 Block material quality | 6.0 (capped) | The blocks-v4 captures pre-date the lighting pass, so they are stale for the shared look (cap 6). The post-lighting pieces do not show the ref 13 caps and toppers. |
| A4 Post finish (bloom, grade, vignette) | 6.0 | Bloom is visible on lava, neon and cave. Grade and vignette are not clearly legible. Smoke crush is a defect. |
| A5 Per-biome identity | 7.0 | Palettes and props separate well in after_contact.png. The block surfaces do not carry the identity. |
| A6 Overall screen quality | 6.0 | The island and props are strong. Pieces and the HUD in the lower third are not at the ref 15 and biome_screens_ref finish. |

Any open defect caps an item at 8.5. Several visible defects here, so none are near 9.

## Ranked defects

1. **Pieces lose value hierarchy against the board (A2, A3).**
   - after/biome_meadow.png: the piece is dark navy-teal on a bright cream board, with no grass or soil cap. Ref 13 meadow reads as grass-topped soil.
   - after/biome_lava.png: the pieces are near-black with thin orange cracks. The ref lava blocks are mid-value basalt with glowing seams and a bright top.
   - after_contact.png, cave, neon and pirate: the pieces are dark on a dark or mid board, so the eye goes to the island rim and props first.
   - The "readable piece hues" claim of blocks-v4 (the multi-colour stacks in ingame_vs_ref13_set.png) is not visible in lighting-v1/after. All pieces are one dark hue.
2. **Stale capture, no combined proof (A3, A6).**
   - blocks-v4 captures were taken before the lighting pass. No capture shows v4 materials under the new grade, AO and bloom, with a full multi-hue stack.
   - lighting-v1 shows only a 1-piece opening state. Materials cannot be judged. Cap 6.
3. **Lava smoke and the dark mass occlude the scene (A1, A4).**
   - after/biome_lava.png: the black smoke plume at the top right is a flat black silhouette with no value inside it. The rim shadow hole around the board crushes to pure black.
   - The overall value range crushes at the dark end. There is no violet fill in the shadows as intended; they are neutral black.
4. **Board and rim separation uneven across biomes (A2, A5).**
   - Meadow, candy, carnival and clockwork: the board is cream or beige, close to the "no beige or parchment" rule (the tan floor in clockwork and carnival is the closest). The board and rim values are close, so the edge is read through colour only.
   - Cave and neon boards are well separated (cool grid lines on dark violet), so the style is inconsistent between biomes.
   - Ice, underwater, pirate: the grey-blue board flattens next to a white rim.
5. **Post grade is weak on bright biomes (A4).**
   - before_contact.png vs after_contact.png on meadow, candy and ice: the change is mostly a warmer cast and a slightly stronger rim. The vignette is barely perceptible.
   - Weather captures were not individually assessed, so none of the 8 can be credited.
6. **HUD in the lower third is plain (A6).** after/biome_lava.png: the Look/Fast fall row and the Hold/Then slots are flat purple pills. The reference HUD cards (boards 15, 05) have wood and vine framing with more depth.
7. **Small inconsistency (A6).** In after/biome_meadow.png the score plate is missing and the Look row is absent. The HUD differs between the meadow screen and the others. It looks like a tutorial layout, but it breaks cohesion.

## Fixes (each with an owner)

| # | Fix | Owner |
|---|---|---|
| 1 | Set a minimum piece luminance of about 0.45 and saturation above the board. Pieces should be the brightest and most chromatic object on the board. Take the hue family from the ref 13 palette. Verify with the `_grey` captures in blocks-v4. | blocks maker / technical-artist |
| 1 | Restore the caps and toppers (grass, icing, glow top) in the post-lighting build so the ref 13 silhouette reads at 720x1280. | blocks maker |
| 2 | Recapture all 12 biomes at 720x1280 with a mid-game stack (at least 10 cubes, 4 hues) after the lighting pass, plus a `_grey` version. Add a side-by-side against ref 13 and ref 15. | blocks maker + QA |
| 3 | Lift shadow floor to violet (about 0.08 to 0.12 luminance) instead of black. Give the smoke a warm rim and an inner gradient. Cap bloom threshold on lava. | technical-artist (lighting) |
| 4 | Retune board colours per biome. Remove the tan and cream boards (clockwork, carnival, meadow) in favour of mid-value, hue-tinted stone, and set a board-to-rim value gap of at least 15 percent. | world builder + art director |
| 5 | Strengthen grade (split-tone lows toward violet, highs toward warm) and vignette (about 20 to 30 percent corner falloff). Re-shoot the before/after with a greyscale crop to prove it. | technical-artist |
| 6 | Add wood and vine framing and depth to the Look row and Hold/Then slots, in line with board 05 and board 15. | UI designer / ui-programmer |
| 7 | Make the HUD layout identical across biomes, except where the level's mechanics dictate otherwise. | UI designer |

## Why no score is near 9

No item has three clean pieces of evidence without an open defect. The strongest result is the lighting of the island, rim and props (after_contact.png), which is real progress over before_contact.png. The scoreboard stays well below 9.7 until the pieces read as the key subject.
