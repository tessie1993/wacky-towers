# MB-007 Meadow block palette (starting defaults, tune by eye on device)

Data: `assets/data/palettes/meadow.json` (`colors` is read by `PaletteTable`; `outlines` and `patterns` are extra keys for the block shader, ignored by `PaletteTable` today).
Hue ids follow `block-art-sets.md` family order: 0 neutral, then standard / special / helper / pento_flat / pento_3d / chunky / party / hollow / long_bar / giant.
Backdrop: floor = moss `#7E9C5E` (L 0.290), sky `#8F9AD8` (L 0.339) from art bible 4.4 Grass. Ratios are WCAG contrast ratios, worked out by hand from relative luminance (not checked with a tool).

| Hue id | Family | Body hex | Outline hex | Pattern | Body : floor | Body : sky | Outline : floor | Outline : sky |
|---|---|---|---|---|---|---|---|---|
| 0 | neutral | `#EDE4D3` | `#4A3B2E` | none | 2.44 | 2.14 | 3.48 | 3.98 |
| 1 | standard | `#6E9CF0` | `#23417A` | h_stripes | 1.13 | 1.01 | 3.23 | 3.69 |
| 2 | special | `#F2E35C` | `#4F4310` | dots | 2.34 | 2.05 | 3.18 | 3.63 |
| 3 | helper | `#67CF8F` | `#184A2E` | waves | 1.60 | 1.40 | 3.27 | 3.74 |
| 4 | pento_flat | `#FFB27A` | `#6A3418` | checker | 1.75 | 1.53 | 3.22 | 3.69 |
| 5 | pento_3d | `#B08FEA` | `#3E2A78` | rings | 1.17 | 1.02 | 3.73 | 4.29 |
| 6 | chunky | `#A06A3E` | `#4A2A12` | bricks | 1.47 | 1.68 | 4.18 | 4.77 |
| 7 | party | `#F0708A` | `#6E2034` | plus | 1.09 | 1.05 | 3.55 | 4.06 |
| 8 | hollow | `#A8DA52` | `#33460F` | diamonds | 1.88 | 1.65 | 3.36 | 3.84 |
| 9 | long_bar | `#4E62D6` | `#1C2470` | v_stripes | 1.68 | 1.93 | 4.38 | 5.00 |
| 10 | giant | `#4B2A8A` | `#24124A` | grid | 3.41 | 3.90 | 5.40 | 6.18 |

## Rules this meets

- Every outline is at least 3:1 against both the floor and the sky (ACC-32 non-text level). Outlines are a deep shade of the piece's own hue, never black. Body fills are mid-tone like the backdrop, so **the outline is what separates a piece from the world**: it must be on in every set.
- Reserved hues: no body within 25° of buff cyan 186° or debuff magenta 322°. The closest is party rose at 348° (26°). Peach (25°) shares hazard orange's hue (22°), so it stays apart by saturation (52% vs 93%) and lightness (L 0.545 vs 0.316). Hazard also keeps its triangle and stripes, so pieces never use triangle, stripe-diagonal, chevron or star patterns.
- Mizzle `#7E6496` (271°, S 33%, L 0.158): giant has moved from `#6F4B9C` to `#4B2A8A` (more saturated, much darker; 2.08:1 against Mizzle). Lavender (262°, S 39%) is the closest piece colour but it is a lighter pastel (1.92:1 against him). He never appears on the grid.
- Lemon has moved from `#F7DE5A` (50°) to `#F2E35C` (54°), to put more space between it and reward gold `#FFC83D` (43°).
- Greyscale: about 6 lightness steps (L 0.05 / 0.15-0.18 / 0.32-0.35 / 0.49-0.59 / 0.75-0.78). Blue, lavender and rose share a step, and so do lemon and neutral. Patterns and shape symbols tell those apart.

## Open items

1. The sky `#8F9AD8` is as bright as the blue, lavender and rose bodies (about 1.0:1). Lighten or haze the sky, or accept outline-only separation.
2. ACC-30 sets the default to "Symbols". The user's decision says patterns are on by default too, so ACC-30 should change to "Symbols + patterns".
3. `block-art-sets.md`, Meadow row: lemon and giant need updating to match.
4. Not checked yet: a protan, deutan and tritan simulator pass, and a greyscale render of a shaded stack.
