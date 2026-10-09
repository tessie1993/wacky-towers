# Block Art Sets

> **Status**: Draft (starting defaults, tune by eye and on device)
> **Last Updated**: 2026-10-09
> **Sources**: creative-director, art-director, world-builder, level-designer, game-designer and material research reports (2026-10-09); user decisions.
> **Related**: `design/art/art-bible.md` §3 (Block art sets), `design/gdd/piece-set.md` (shape bank, colour rules)

## What a set is

- A **set** is the whole shape bank (67 shapes, Piece Set GDD) built in one look. Each piece is an empty at the pivot cube with one child object per cube; cubes stay separate objects for game mechanics but sit tight together (cube size about 1.03 of a cell) so a piece reads as one object.
- The **default set** `candy_toy` colours pieces by **family**.
- There is **one art set per biome** (`SET_<biome>`). A biome is an **art style only**: its block material, texture, edge style and palette. It never changes which shapes exist: every biome set contains the same full shape bank, and which shapes a level uses comes from the level's piece pool, not from its biome.
- **The user will make reference images for each biome.** The per-biome rows below are provisional proposals until those references arrive; the references win where they differ.
- New sets are always **copies of the default set**; existing sets are never overwritten.
- Built in Blender (`D:/TESSA/blender-projects/wacky-towers/blocks.blend`, live MCP), exported per set to `assets/models/blocks/<set>/`.

## Cute style north star (all sets)

"A sweet you could pick up": inflated, lit from inside, outlined like a sticker.

| Cue | Default |
|---|---|
| Highlight | Big soft window upper-left + small white dot; bright line on top bevel edges (matcap in Godot, view-space so it stays upper-left) |
| Outline | Inverted hull, deep tint of the block's own hue (about −35% value), about 2–3 px on a 1080p phone; never black |
| Colour depth | Gradient per cube, lighter top, deeper bottom; shadows lean lilac, lights warm cream; never grey |
| Inner glow | Faked (inverted fresnel lighten); no real transparency on blocks |
| Ground | Soft lilac blob shadow under pieces |
| Pattern | Low contrast (≤ about 15% value change); the face centre (50%) stays clean for the shape symbol |
| Sparkles | Small white four-point stars, sparingly; never gold (gold = reward) |

**Status effects look different by behaviour, not surface (user decision 2026-10-09).** Statuses are animated, pulse in the buff/debuff accent colour and show an icon, so biome sets may use cracks, frost, snow caps, icicles, glowing seams, vines, drips, swirls and embers exactly as in the user's references. Still avoided on every set: silhouettes that stop being a cube (add-ons stay small and never change the cube cell).

## Readability rules

1. Only geometry details read at about 24 px per cube (bevel profile, insets, big grooves); everything else is a close-up bonus in the texture or normal map.
2. Each biome has one **cube kit** (face, edge, corner and seam variants); all shapes are assembled from it, so detail cost is per cube.
3. Raised geometry stays within about 5% of the cube edge so stacks sit flush.
4. Real-world textures (Poly Haven) supply relief only (normal and roughness, softened); colour comes from the biome palette and a painted gradient. BlenderKit stylised materials can be used more directly. Every external asset is logged in the Blender project's `LICENCES.md`.

## Roundness levels

| Level | Bevel | Faces |
|---|---|---|
| Fat | about 22% | bulge about 3–5% |
| Medium | about 15% | flat or slight bulge |
| Tight | about 10–12% | flat, crisp |
| Chamfered | flat 45° cut | flat |

## Sets (art style per biome — provisional until the user's references)

Key: G = geometry, N = normal map, T = colour texture, E = emission.

| Set | Roundness | Detail elements | Texture sources (search terms) |
|---|---|---|---|
| **candy_toy** (default) | Fat | Smooth faces; gradient and highlight only | — |
| **Meadow** (gummy jelly, MVP) | Fat pillow, 22%, faces bulge about 5% | Puffy domed faces (G); sugar-sparkle speckle (T); 2–3 trapped lighter bubbles in the border band (T + fake highlight); squash-and-wobble on landing (shader) | BlenderKit: gummy, jelly, candy |
| **Forest** (painted wooden toy) | Medium crisp, 14% | Side faces split into 3 planks by shallow V-grooves (G, 2–3%); end-grain rings on top/bottom (N + faint T); dowel-peg dot per corner (N); lacquer over the grain | Poly Haven: wood planks, plywood (normal only); BlenderKit: stylized wood |
| **Desert** (glazed terracotta) | Medium handmade, 17% with about 1% wobble (G) | Hand-thrown irregular edges (G); glaze pooling darker in seams (T from AO); thin unglazed clay line on the bottom edge (T); one painted pottery band (T) | Poly Haven: clay, plaster (roughness only); BlenderKit: glazed ceramic |
| **Underwater** (pearl/nacre) | Fat shell, 22% | Scalloped shell ribs from face corners (N + shallow G on the bevel); small inset pearl bead at each top corner (G); rainbow tint in the rim only | BlenderKit: nacre, pearl, seashell |
| **Ice** (snow-porcelain) | Tight tile, 11% | Raised porcelain tile per face with an inset border step (G, 2%); embossed lace pattern in the border (N); glaze pooling in the step (T) | Poly Haven: ceramic tiles (normal only); BlenderKit: porcelain |
| **Cave** (polished river stone) | Fat tumbled pebble, 25%, uneven per cube (seeded variants) | Pebble lumps (G); 1–2 smooth tumbled nicks inside the bevel (G, glossy, no debris); lighter speckles (T); wet polish | Poly Haven: river pebbles, granite (normal only); BlenderKit: stylized painted stone |
| **Lava** (volcanic glass) | Chamfered, knapped, about 12% | Flaked scallop ripples on the chamfers (N + slight G); one sharp streak highlight per face; no glowing seams | Procedural Voronoi; BlenderKit: obsidian |
| **Clockwork** (enamelled tin) | Tight panel, 10% | Inset enamel panel per face (G) with panel line (N); 4 corner rivets (N or tiny G on top); tin-tab slots on seams (N); pinstripe in the border (T) | Poly Haven: blue_metal_plate (normal and roughness only); BlenderKit: enamel, painted metal |
| **Rune/Neon** (light plastic voxel) | Chamfered voxel, about 10% | Low glowing groove along the chamfer (E, family hue); glowing rune symbol (E); moulding seam line (N); flush stud rings (N) | BlenderKit: glossy plastic, toy plastic |
| **Celestial** (marble) | Medium moulded, 15% stepped profile (G) | Stepped classical edge (G); pale flowing veins, lighter than the body, never angular (T); 1–2 white star flecks (E) | Poly Haven: marble (normal/roughness only, veins repainted pale); BlenderKit: stylized marble |

Party sets (later): jelly_swirl (fat, wet, one internal ribbon), gummy_bubble (fat, bubbles), crystal_cut (tight, star-burst facets on the face; Lava's facets stay on the edges), plush_felt (fat, stitched seams), toy_plastic (medium, moulded seam, low studs ≤ 4% on the top face).

## Palettes

Every biome keeps each family at the same relative lightness and warmth, so players don't relearn colours; only the exact hue and material change. No hue within 25° of buff cyan (186°) or debuff magenta (322°). Order: standard / special / helper / pento_flat / pento_3d / chunky / party / hollow / long_bar / giant.

| Set | Hexes |
|---|---|
| candy_toy (default) | `#6EA4F0` `#F5DD6A` `#5DCB9E` `#FFB48C` `#A78BEB` `#9A6A4A` `#EE7A8C` `#9FD65B` `#5468D8` `#6E4F9E` |
| Meadow | `#6E9CF0` `#F7DE5A` `#67CF8F` `#FFB27A` `#B08FEA` `#A06A3E` `#F0708A` `#A8DA52` `#4E62D6` `#6F4B9C` |
| Forest | `#5B8FD9` `#F2D25A` `#7FCF86` `#F09A5C` `#9B7FD6` `#A8483C` `#E8607A` `#C2D45A` `#3D52A8` `#5A3E80` |
| Desert | `#4F86D8` `#F2DC72` `#8CC79A` `#F7A46E` `#A68ADB` `#8E4F36` `#E86A7E` `#A9CF5E` `#3E4FB0` `#6A4790` |
| Underwater | `#8C9BF0` `#F6E27E` `#72D0A0` `#FF9E7E` `#B184E8` `#9A4E3A` `#F27C8C` `#B2D86A` `#4A4FC4` `#5C3F8E` |
| Ice | `#5A8EE0` `#F2D64E` `#4FBF8A` `#FF9F78` `#9C78E0` `#7E4E36` `#E25A70` `#A2CC4E` `#3A4BB0` `#5B3A86` |
| Cave | `#7AA6EE` `#EDD06A` `#5FC08E` `#EE9C70` `#A486E0` `#B0664E` `#E07888` `#A6C95A` `#5A6CDA` `#7A5BB8` |
| Lava | `#6A9BF2` `#F2E06A` `#5CCB94` `#FFC2A0` `#A88AF0` `#8C6A58` `#E0607A` `#B4D45A` `#4F63E0` `#8060C8` |
| Clockwork | `#4A80E0` `#F4E07A` `#4DB87A` `#F4A878` `#9478E0` `#8A3A3A` `#EE6E80` `#A6D04A` `#3448B0` `#5A4878` |
| Rune/Neon | `#5A8CFF` `#F6EE6A` `#58E08A` `#FFAA7A` `#A070FF` `#B07040` `#FF6E88` `#B6F04A` `#4A50E8` `#7A4ADC` |
| Celestial | `#7AA8F0` `#F4E48A` `#7CCFA6` `#F7B89A` `#A48AE6` `#9A5A50` `#EE8CA0` `#B8DC78` `#5A70E0` `#8466CC` |

Not yet verified: run each palette through a colour-vision simulator (protan, deutan, tritan) and a greyscale pass on a shaded render against its biome backdrop. Dark biomes keep outlines lighter than the backdrop or add a thin rim light.

## Open questions

- Cave nicks vs. the Crumbling status: smooth glossy "tumbled nicks" (recommended) or no nicks at all.
- Studs: low flat studs on toy_plastic's top face only (recommended), or normal-map studs everywhere.
- Optional "classic colours" accessibility setting that forces the default palette in every biome.
- Should high-difficulty levels ever hide the shape symbol, or does it stay for colourblind players?

## Theme sets from the user's references (2026-10-09)

References: `D:/TESSA/blender-projects/wacky-towers/refs/Oct 09 - 04_36/` (23 sheets, 10 biomes: Meadow, Candy, Forest, Underwater, Ice, Cave, Lava, Clockwork, Neon, Celestial; no Desert sheet). Each labelled sub-style is a **theme set** with its own shape, texture, material and colour scheme. The sheets hold 72 theme sets. **All of them are kept** (user decision 2026-10-09): the primaries below are built first for the campaign biomes, and every other theme set stays available for later sets and minigames. Status effects now have their own look (animation, colour pulse, icon), so cracks, snow, drips and glowing seams are allowed in theme sets.

| Biome | Primary (first build) | Other theme sets (kept, e.g. for minigames) |
|---|---|---|
| Meadow | Lush Grass / Budding Clover turf over soil, with Wild Flowers add-ons | Yellow Daisies |
| Candy | Gummy Candy / Gummy Jelly | Candy Stripes; Sprinkle Glaze |
| Forest | Forest Bark | Moss & Stone |
| Underwater | Deep Sea Gems with bubbles (build 1) / Coral Overgrowth | Bubbly Currents |
| Ice | Frosted Glass / Glacial Ice | Snowy Blocks; Glacier Ice |
| Cave | Slate with violet crystals (sheet `_14` + `_7` crystal clusters) | Amber mineral ore stone |
| Lava | Obsidian Glass (sheet `_15` glowing seams allowed) | Volcanic Stone; Crusted Magma |
| Clockwork | Clockwork Gears on the sheet `_16` cube kit | Copper Cogs; steel |
| Neon | Neon Glass (sheet `_17`, glowing edges) | Cyber Circuits |
| Celestial | The purple cosmic look (Cosmic Dust / Starry Glow / Nebula Swirls in deep violet, gold accents as in the reference) | Golden Galaxies |

Sheets `_14`, `_15`, `_16`, `_17`, `_18` draw separate cubes with tight seams and are the guide for how cubes join; the other sheets guide material and surface only. Open: Neon/Ice/Underwater use cyan and magenta (buff/debuff hues), and Clockwork/Celestial use gold (reward colour) — keep, or shift the status/reward colours.

## Review panel decisions (2026-10-09, user: "listen to reviewers")

After a fresh-eyes review panel (art-bible compliance, gameplay readability, creative direction vs references, store appeal):
1. **Per-piece tint in every set.** Each piece gets its own tint within the theme's material (wood species/stains, crystal colours, glass tints, gem colours…), with at least 5–6 clearly different lightness steps per set so pieces pass a greyscale check.
2. **One hero prop per piece**, about 25–35% of a cube, on the top face of one cube (sprout/flower, crystal cluster, coral, snow cap, twig, ember vent, star charm…), readable at phone size. Other cubes stay clean.
3. **Reserved colours stay off pieces:** buff cyan (186° ±25°), debuff magenta (322° ±25°), hazard orange, reward gold. Settled pieces glow at most faintly; strong glow belongs to the falling piece.
4. **Meadow follows its reference** (turf over a soil band, pastel-tinted per piece). The rainbow **Toy Box** becomes its own set made of real toy materials (painted wood, lacquer, stripes, dots).
5. **Look rules for all sets:** painterly face gradient and stepped shadows; thick wobbly ink on each piece's outer silhouette with soft seams inside; upper-left gloss window; seams stay the strongest line inside a piece; per-biome backdrop and ambient particles in review renders; every set reviewed as a stacked board at phone size and in greyscale.
