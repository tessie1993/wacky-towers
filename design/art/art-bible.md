# Wacky Towers — Art Bible

Version 2.1 · 2026-10-13. This replaces the v1 bible. The user decided: "delete the old art, make it
look like the reference style". v2.1 adds the full cast, bosses, party-mode HUD, the Party Quest hub,
mode-select picture cards and story-beat composition after a study of every board (see
`assets/art/reference/index.md`). Gap list: `design/art/art-gap-review-2026-10-13.md`. Asset list:
`design/art/asset-list-v2.md`.

**Logo rule:** boards 09-12 mockups carry the logos "TETRO PARTY DIMENSIONS", "WACKY PARTY" and "PARTY
QUEST". We use those boards for layout and content only. Never copy, redraw or ship those logos. Our
logo is `assets/art/reference/logo_master.jpg`. Avoid "Tetris" naming anywhere.

**References** (in `assets/art/reference/style/`) are the source of truth. When this document
and a reference disagree, the reference wins.

| File | Shows |
|---|---|
| `15_title_and_hud.png` | Title screen and in-level HUD (meadow, ice, celestial). **Primary target.** |
| `13_biome_blocks.png` | The 12 biome block materials. **Primary target for blocks.** |
| `14_tournament_flow.png` | Tumble Fair lobby, round wheel, round play, standings, win |
| `05/06_select_mode_*.jpg`, `03_choose_mode_library.jpg` | Mode select: framed picture cards |
| `04_settings_wide.jpg`, `08_settings_options_tall.jpg` | Settings and Options panels |
| `01/02/07_story_*.jpg` | Story beats (wizard's library, tutorial, boss, finale) |
| `09`–`12_minigames_*.jpg` | Party minigames and their HUD |
| `logo_master.jpg` | The logo. Use as-is. Never redraw it. |
| `16_settings_wizard_peek.jpg` | Settings with the wizard peeking in, rope borders, gear ornaments |
| `minigame_mockups/mockup_06, 12, 14` | Party HUD, 4-player split screens (layout only, logos banned) |
| `minigame_mockups/mockup_15.jpg` | Portrait party battle: P1-P4 cards with lives, goal chips |
| `minigame_mockups/mockup_16.jpg` | Party Quest hub: central fort, bridges to minigame islands |
| `minigame_mockups/mockup_17.jpg` | Quantum Spire: sci-fi hex board, holo HUD |

---

## 1. The look in one sentence

A **painted, chunky, toy-like storybook fantasy**. Everything is soft, rounded, thick and
glossy, like a premium mobile puzzle game. The player looks at a floating island diorama
through a purple-wood frame wrapped in vines.

### Pillars

1. **Chunky and tactile.** Every object has thickness, bevels and a lit top edge. Nothing is
   flat, thin or outlined with a hairline. Buttons look pressable. Blocks look like you could
   pick them up.
2. **Painted, not vector.** Hand-painted texture, soft gradients, rim light, warm bounce
   light, specular glints. **No flat clip-art. No single-colour fills. No geometric
   placeholder characters.**
3. **Floating-island dioramas.** Every play space is a floating island chunk: a grass, snow
   or stone top, layered rock cliffs under it, roots or icicles hanging down, set in a sky
   full of distant islands.
4. **Warm, saturated and magical.** Golden sparkles, glow, confetti and stars. Purple and gold
   are the brand colours.
5. **Readability first.** Pieces and the landing ghost must read at a glance on a phone. The
   decoration sits on the rim. It never covers the grid.

---

## 2. Colour

### Brand UI palette (sampled from refs 05, 06, 08 and 15)

| Token | Hex | Use |
|---|---|---|
| `wood_purple` | `#6b4a8a` | Frame planks (main frame colour) |
| `wood_purple_dark` | `#3f2a55` | Frame shadow side, grain, inner bevel |
| `wood_purple_light` | `#9a78b8` | Frame top-edge highlight |
| `wood_brown` | `#8a5a34` | Signboards, sliders, secondary planks |
| `wood_brown_dark` | `#4e2f1a` | Text on parchment, sign shadow |
| `parchment` | `#f6e7c4` | Panel and card interiors |
| `parchment_shade` | `#e2c995` | Parchment edge burn, inner shadow |
| `gold` | `#f8c840` | Primary button face, trims, stars |
| `gold_deep` | `#c98418` | Button lip, gold shadow |
| `gold_glint` | `#fff3b0` | Specular on gold |
| `vine_green` | `#4f9a3a` | Vines and leaves on frames |
| `leaf_light` | `#8fd05a` | Leaf highlight |
| `blossom` | `#fff6f0` + `#ffd34d` centre | Little white flowers on vines |
| `ink` | `#3b2346` | Body text (plum, never pure black) |
| `danger_red` | `#e0483c` | Close (×) button, warnings |
| `go_green` | `#4cc04a` | ON toggles, "Ready!" |

### Display text ("SETTINGS", "SELECT MODE", "CAMPAIGN")

- **Multicolour chunky wooden letters.** Each letter is a different candy colour: orange
  `#f08a2c`, cream `#f6e2b8`, blue `#4aa8e8`, green `#6cc04a`, lilac `#b48ad8`, pink
  `#ee6aa0`.
- Every letter has a thick dark outline, a lit bevel and a drop shadow.
- Section headings ("AUDIO", "TOURNAMENT") are cream-on-brown carved signboards.

### Biome palettes

Defined by the blocks in ref 13 and the islands in refs 15, 09–12. The block palette per biome
lives in `assets/data/biome_looks.json`. Each record has `top`, `body`, `accent` and `glow`.

---

## 3. Typography

| Role | Font | Notes |
|---|---|---|
| Display / titles | **Lilita One** (OFL) or **Luckiest Guy** (OFL) | Chunky and rounded. Rendered with outline and shadow, or baked as multicolour letters for big titles |
| UI labels / buttons | **Fredoka 700** (OFL, already in repo) | ALL CAPS on buttons. Dark-plum ink |
| Body / small | **Fredoka 600** | Sentence case |

- Numbers (score, timer) use the display font, cream on dark wood.
- Never use thin or light weights.
- Never use pure white text on light backgrounds.

---

## 4. UI components

All UI pieces are **rendered from Blender 3D models** (`assets/source/blender/ui/`) to PNG and
used as nine-patches. They must match these specs.

| Component | Spec (ref) |
|---|---|
| **Main frame** | Thick purple planks with visible grain, metal corner caps with gold stars, rope or vines wrapping the corners, small white blossoms. Inner edge is a dark bevel (refs 05, 06, 08) |
| **Parchment panel** | Cream with a burnt edge, soft inner shadow, very rounded corners (refs 06, 14) |
| **Wood panel** | Brown planks, horizontal grain, rope border for sub-groups (ref 04) |
| **Title plaque** | Purple-wood scroll plaque, gold trim and curls, multicolour title text (refs 05, 06) |
| **Primary button** | Gold glossy pill: thick gold-deep lip underneath, white specular streak on top, a star icon on the left, dark-plum ALL-CAPS text ("PLAY", "BACK", "DONE") |
| **Secondary button** | Cream or wood pill with a brown lip (refs 08, 04) |
| **Close button** | Red round or square gem, white ×, gold rim |
| **Toggle** | Rounded track (green ON, cream OFF) with a star knob |
| **Slider** | Branch or stick track with a gold star thumb (ref 08) or a coloured fill (ref 04) |
| **Mode / picture card** | Painted illustration in a gold or wood frame with a signboard label (refs 03, 05, 06) |
| **HUD chip** | Parchment card in a biome-tinted frame (green vines, ice blue, celestial purple), with a label and a big number (ref 15) |
| **Next / hold slot** | Square parchment tile in a biome frame showing a 3D render of the piece (ref 15) |
| **Piece tray (bottom)** | A three-slot parchment shelf in a biome frame (ref 15) |
| **Player tag** | Dark rounded tag: portrait, name, score (refs 09–12) |
| **Meter** | Vertical thermometer (heat, balance, altitude) with a red→green gradient and a bulb (refs 09–12) |
| **Timer** | Dark rounded lozenge, cream digits (refs 09–12) |

See section 5b for the full party HUD language (cards, hearts, slots, meters, boss bar, goal chips).
Settings extras (ref 08, 16): rope borders, gear ornaments on the lower corners, star corner caps,
branch-stick slider tracks, a tiny wizard hat on a corner, a segmented control (gold selected, brown
unselected), and a green "link account" pill. The wizard peeks around the frame edge, holding his wand.

**Banned:** light-yellow flat bars, hairline borders, flat rectangles, default Godot theme,
and unstyled text buttons.

---

## 5. Characters

The cast is original. It is chunky "super-deformed" fantasy: big heads, big hands, about 2.5
heads tall. Characters are painted, never flat.

| Character | Look |
|---|---|
| **The Wizard (mascot)** | Purple star-spangled robe and hat, huge white beard, rosy cheeks, gold star wand, often riding a cloud |
| **Knight** | Silver armour, red plume, round friendly face |
| **Pirate** | Red beard, tricorn hat with skull, eyepatch, cutlass |
| **Dwarf** | Ginger braided beard, helmet or miner's lamp, pickaxe |
| **Elf / Thief** | Green tunic and hood, blond, slingshot or lockpick |
| **Robot** | White and blue round robot, glowing visor |
| **Astronaut** | White suit, round visor |
| **Tournament wizards** | Red, blue, green and purple wizard variants, each with a P1–P4 marker (circle, triangle, square, star) (ref 14) |
| **Bosses** | Molten golem, rainbow kraken, angry wind cloud, stone guardian (refs 02, 07, 11) |

- **In 3D:** low-poly sculpted, then hand-painted textures. Smooth shading, soft rim light.
  Idle bob and cheer/oops poses.
- **In 2D UI:** portraits rendered from the 3D model at three-quarter view.

**Never use Nintendo or other third-party IP** (no Mario, Luigi, Yoshi, Toad, Peach or
Bowser). Two user boards show those characters. They are a **layout** reference only and
are not stored in the repo.

---

## 6. Blocks (ref 13 is law)

Every biome has its own block material. A cube is a rounded box with a visible **bevel** and a
**biome cap** on the top face.

| Biome | Block |
|---|---|
| Meadow | Dirt body with pebbles, thick grass cap with clover, a sprout or flower on top |
| Candy | Translucent jelly (pink, orange), dripping frosting cap, sprinkles, heart topper |
| Ice | Frosted translucent blue, snow cap with icicles, snowflake emboss |
| Underwater | Deep-blue glassy body, bubbles inside, coral topper |
| Lava | Dark cracked basalt with glowing orange cracks, a spike on top |
| Forest | Bark sides, tree-ring top, moss patches, a leaf topper |
| Crystal Cave | Grey stone with embedded purple crystals |
| Clockwork | Navy panel with gold riveted frame, gear emboss |
| Neon | Dark glass with cyan circuit lines that glow |
| Celestial | Purple galaxy with gold stars, star topper |
| Tumble Fair | Pink and cream candy stripes, ticket topper |
| Dune Bazaar | Sand tile with a teal arabesque band, gold dome topper |

- Piece colour still reads at a glance. Each shape is tinted by `palette` within the biome
  style, as in ref 15 where meadow pieces are green, pink, yellow and blue.
- Ghost: translucent glassy cube with a glowing edge (refs 01 and 14 show it).
- Tops get a small sprout, crystal or star on **some** cubes (ref 15), not every cube.

**Build:** Blender models plus a Godot shader. The material uses a painted albedo, a cap mask
and an emissive for lava, neon and celestial. Small toppers are separate instanced meshes.

---

## 7. Islands and environments

- **Board island** (ref 15): a square stone-tile board, slightly inset, sits on a thick
  floating chunk. The biome rim around it has flowers, clover and grass tufts (meadow), snowy
  shrubs and frost trees (ice), or marble with gold inlay and broken pillars (celestial).
- **Cliffs:** 2–3 layered rock bands with painted strata. Roots, icicles or crystals hang from
  the bottom.
- **Backdrop:** painted sky (gradient plus soft clouds) and 3–6 distant floating islands with
  biome landmarks (castle, waterfall, volcano, temple arch). Light atmospheric haze.
- **Lighting:** warm key light from top-left, cool fill, soft shadows, glow on emissives,
  gentle bloom. Golden-hour warmth by default. Ice is cool. Celestial is night.
- **Fair** (ref 14): bunting, lanterns, tents, Ferris wheel in a dusk palette.

---

## 8. Screens (what each must look like)

| Screen | Reference | Key elements |
|---|---|---|
| Title | 15 (left) | Wooden logo, wizard on cloud, cottage island with waterfall, big gold PLAY, wood BIOMES sign, library shelves framing it |
| Mode select | 05 / 06 | Purple-vine frame, "SELECT MODE" plaque, 5 painted picture cards, gold BACK |
| Level map | 06 "Campaign" card | Winding path over floating islands, round stone level nodes, wizard on cloud |
| In-level HUD | 15 | Pause gem, SCORE chip with stars, NEXT chip, biome frame around the screen, 3-slot piece tray at the bottom |
| Results | 02 "Story Victory" | Banner, treasure chest, confetti, star row, gold buttons |
| Settings | 04 / 08 | Wood or parchment panel, star sliders, star toggles, signboard headings |
| Tournament | 14 | Lobby cards, spinning wheel, 4-island round play, standings table, win screen |
| Story beats | 01 / 02 / 07 | Full painted scenes, title banner. Optional and secondary. Never flat vector |

---

## 9. Production pipeline

1. **Model** in Blender 5.2: `assets/source/blender/<area>/` (gdignored).
2. **Paint:** Blender texture paint or procedural painted materials, baked to albedo.
   Hand-painted style: soft gradients, edge highlights, no photoreal noise.
3. **Export:**
   - 3D goes to GLB in `assets/models/<area>/`.
   - UI goes to PNG renders in `assets/art/ui/` at 2× with nine-patch margins in JSON.
4. **Godot:** stylised shaders in `src/view/shaders/` (rim light, cap mask, emissive). The
   renderer is Forward+ on desktop; mobile must also look right.
5. **Third-party:** CC0 only (Poly Haven, Kenney, BlendKit free/CC0). Credit everything in
   `assets/third_party/CREDITS.md`. Restyle third-party assets to this bible (repaint,
   recolour) so they don't clash.
6. **Verify:** every art change ships with a screenshot in `production/qa/evidence/` taken
   **side-by-side with its reference**. The reviewer compares silhouette, colour, thickness
   and lighting.

## 10. Acceptance checklist (every asset)

- [ ] Placed next to its reference, it looks like the same game.
- [ ] Chunky: visible thickness, bevel and a lit top edge.
- [ ] Painted shading, not a flat fill.
- [ ] Uses the palette tokens above.
- [ ] Readable at phone size. Gameplay pieces are never obscured.
- [ ] No third-party IP. Licence recorded.
