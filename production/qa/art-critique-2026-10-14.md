# Art Critique — 2026-10-14

Reviewer: art-director (strict pass). Scope: every UI, level, character and story capture listed below,
judged against `assets/art/reference/style/*` and `design/art/art-bible.md` v2.1.
User directives in force: **"you did not remove beige interface like i said"** (zero tolerance) and
**"art is close but misses quality"**.

Skill standards applied: `godot-ui-theming` (one Theme resource as the palette source of truth, type
variations instead of per-node overrides, no hardcoded StyleBox colours) and `godot-3d-world-building`
(WorldEnvironment sky/fog/ambient setup, baked static geometry over runtime CSG). The Skill tool was not
available in this session, so both `SKILL.md` files were read from `.claude/skills/` directly.

---

## 0. Blocking finding: the beige is in the kit, so it is on every screen

The beige was never removed because it comes from the shared kit, not from individual screens:

| Source | What it injects |
|---|---|
| `src/ui/common/wt_storybook.gd:13-14,27` | `PARCHMENT #f6e7c4`, `PARCHMENT_DEEP #e2c995`, `CREAM_PILL #fff4dc`, `STAR_OFF #cdbfa6` |
| `assets/art/ui/kit/x1/panel_parchment.png`, `btn_cream.png`, `chip_hud*.png`, `tray_slot.png` | Blender-rendered beige faces baked into the nine-patches |
| `src/ui/game_ui.gd` lines 12, 92, 99-100, 130, 136-145, 162-163, 582-588, 625, 899, 1016, 1129, 1201-1202, 1371, 1903, 2291 | `CREAM`/`panel_parchment`/`btn_cream` used as the default panel, tab, popup, card, chip, tray and secondary button |
| `src/ui/game_ui.gd:137-139,164-166` | Hardcoded `f4e6c9`, `e4d4b5`, `e5e4d9`, `d7dcd0`, `dce2d5` fallbacks. This breaks the skill's "never hardcode colours in a StyleBox" rule |
| `src/ui/minigame_ui.gd:7`, `minigame_ext_c.gd:7`, `minigame_ext_d.gd:7` | Duplicate `MINT` constants, so the palette has drifted into three files |
| 3D: board tile shader (`src/view/shaders/spatial_env_tile.gdshader`, `wt_stage.gd`) | Beige or tan board tiles on meadow, celestial and candy. The reference tiles are cool light-grey stone (meadow, ice) and white marble with gold inlay (celestial) |
| Ghost cells (`spatial_block_ghost.gdshader`) | Flat tan landing squares (playtest `meadow_02_start.png`) |

**The bible is stale on this point.** Art bible §2 still lists `parchment`/`parchment_shade` as tokens.
§4 and §5b specify parchment panels, chips, tray and cards, and refs 06, 08, 14 and 15 show parchment.
The user's standing rule in `.claude/docs/reference-quality-bar.md` overrides this: "No beige or
parchment interface. Windows are open purple-wood frames over a painted scene (board 05). Groups of
controls sit on translucent purple or wood planks." The bible §2/§4/§5b text has to be amended to match,
or the next maker pass will put the beige back "per spec". Escalate the wording to creative-director.
The replacement below applies the user's rule:

- **Screen interiors:** the painted backdrop shows *through* the purple frame (ref 05). No fill panel.
- **Content panels:** `wood_purple_dark #3f2a55` plum glass at 88% opacity, a 3 px `wood_purple_light`
  inner bevel and a soft inner shadow. Brown-plank `panel_wood` (ref 04) is the alternative for
  settings-style groups.
- **Secondary buttons:** purple-wood or brown-wood pill with `gold_glint` lettering. `btn_cream` is retired.
- **HUD chips, tray slots and NEXT:** a biome-tinted wood frame around a dark plum glass face, gold numbers.
- **Lettering:** `gold_glint #fff3b0` or white on dark surfaces. Cream text survives only as lettering on
  wood, never as a surface.
- **Board tiles:** cool grey stone `#b9b6b0` to `#9e9a94` for meadow and ice, white marble with gold seams
  for celestial, pink-white sugar tile for candy (still not tan).

---

## 1. Scoreboard

PASS needs 8/10 or more. Nothing passes.

| # | Asset | File | Score | Nearest ref | Verdict |
|---|---|---|---|---|---|
| U1 | Title (portrait) | `full-build/ui/title_720.png` | 5 | 15 left | FAIL |
| U2 | Title (portrait, latest) | `islands-v2/title_720x1280_v3.png` | 5 | 15 left | FAIL |
| U3 | Title (landscape) | `full-build/ui/title_1280.png` | 3 | 15 left | FAIL |
| U4 | Mode select (portrait) | `full-build/ui/modes_720.png`, `mode-select-v2/mode_select_720x1280.png` | 4 | 05 / 06 | FAIL |
| U5 | Mode select (landscape) | `mode-select-v2/mode_select_1280x720.png`, `full-build/ui/modes_1280.png` | 3 | 05 | FAIL |
| U6 | Physics Toy Box menu | `full-build/ui/physics_720.png` (+1280) | 2 | 08 / 04 | FAIL |
| U7 | Lobby, portrait | `full-build/ui/lobby_720.png` | 3 | 14 lobby | FAIL |
| U8 | Lobby, landscape | `full-build/ui/lobby_1280.png` | 2 | 14 lobby | FAIL |
| U9 | Puzzle Tools | `full-build/ui/tools_720.png` (+1280) | 3 | 08 options | FAIL |
| U10 | HUD capture | `full-build/ui/hud_720.png`, `hud_1280.png` | 1 | 15 HUD | FAIL |
| U11 | Items / power-up bar | `full-build/ui/items_720.png` (+1280) | 1 | 15 HUD, mockup 15 | FAIL |
| U12 | Story intro | `full-build/ui/story_720.png`, `story_1280.png` | 1 | 01 / 02 / 07 | FAIL |
| U13 | Desktop capture | `full-build/ui/desktop.png` | NOT ASSESSED (all-black frame, the capture failed) | — | — |
| U14 | Legacy title (landscape) | `full-build/title-landscape.png` | 1 | 15 left | FAIL |
| U15 | Legacy gameplay (landscape) | `full-build/gameplay-landscape.png` | 1 | 15 HUD | FAIL |
| L1 | Meadow level (portrait) | `islands-v2/meadow_720x1280_v3.png` | 5 | 15 meadow | FAIL |
| L2 | Meadow playtest start | `playtest-2026-10-14/meadow_02_start.png` | 5 | 15 meadow | FAIL |
| L3 | Meadow level (landscape) | `islands-v2/meadow_1280x720.png` | 4 | 15 meadow | FAIL |
| L4 | Ice level | `islands-v2/ice_720x1280_v3.png` | 5 | 15 ice | FAIL |
| L5 | Lava level | `islands-v2/lava_720x1280_post2.png` | 4 | 07 Molten / 13 lava | FAIL |
| L6 | Celestial level | `islands-v2/celestial_720x1280_polish.png`, `playtest-2026-10-14/addons/pcam_after_celestial_720x1280.png` | 5 | 15 celestial | FAIL |
| L7 | Candy level | `islands-v2/candy_720x1280_polish.png` | 4 | 13 candy / mockup 15 Candy Dodger | FAIL |
| L8 | Physics toy box scene | `physics-v2/toybox_midtopple_baseline_720x1280.png` | 2 | 15 / 13 | FAIL |
| C1 | Wizard idle | `assets/art/ui/wizard_idle.png` | 6 | 15 / 16 wizard | FAIL |
| C2 | Wizard point | `assets/art/ui/wizard_point.png` | 6 | 01 / 07 | FAIL |
| C3 | Wizard cheer | `assets/art/ui/wizard_cheer.png` | 6 | 14 win | FAIL |
| C4 | Wizard oops | `assets/art/ui/wizard_oops.png` | 5 | — | FAIL |
| C5 | Knight idle | `assets/art/ui/knight_idle.png` | 5 | 07 First Steps | FAIL |
| C6 | Knight cheer | `assets/art/ui/knight_cheer.png` | 5 | 07 / 09 | FAIL |
| C7 | Dwarf idle | `assets/art/ui/dwarf_idle.png` | 4 | 01 / 07 | FAIL |
| C8 | Dwarf cheer | `assets/art/ui/dwarf_cheer.png` | 5 | 01 / 07 | FAIL |
| C9 | Elf idle | `assets/art/ui/elf_idle.png` | 4 | 01 / 07 | FAIL |
| C10 | Elf cheer | `assets/art/ui/elf_cheer.png` | 5 | 01 / 07 | FAIL |
| S1 | Story panels | `assets/art/story/**` | 0, **missing**. The folder does not exist | 01 / 02 / 07 | FAIL |

**Overall: 3.6 / 10** (mean of the 32 scored items, with the missing story panels counted as 0).
UI averages 2.6, levels 4.3 and characters 5.1. The 3D work is "close". The interface is what drags the
game down, and the interface is where the beige lives.

---

## 2. Per-item defects (ranked worst first within each item) and fixes

### UI

**U1/U2 Title, portrait (5)**
1. Beige remnants: the cream pills "Clover", gear, "Quit" and (v3) "Party / Arcade / Shop / Toy box" use
   `btn_cream`. Fix: in `game_ui.gd` `_kit_button` default, switch from `"btn_cream"` to a new
   `btn_wood_purple` kit piece. Re-render it in `assets/source/blender/ui/build_ui_kit.py`.
2. Missing painted backdrop: ref 15 frames the title with library shelves, books, a lantern and a globe.
   Ours is an empty lilac-to-teal haze. Fix: add a painted library-shelf foreground layer (left and right
   bookcases, lantern bottom right) as a `TextureRect` behind the logo. Owner world/ui.
3. Dead area: about 130 px of empty haze between the island and PLAY, and the whole lower third is fog.
   Fix: scale the title island ×1.6, place it under the wizard's cloud so the cloud overlaps the island
   (ref 15), and raise PLAY to 72% of the height.
4. The island has no cottage, no waterfall, no trees and a beige tile board. Fix: `wt_title_island.gd`
   should use the meadow board with a cottage, two pines, a fence and a waterfall off the front cliff.
5. MODES is a second gold button, which competes with PLAY. Ref: only PLAY is gold. Fix: MODES becomes a
   wood sign like BIOMES.
6. The footer "42 collected · 18 in your jar" is loose text. Fix: put it in a small dark-plum chip with a star icon.
7. No frame. Ref 15 wraps the title in a purple-wood phone frame with vines. Fix: apply `frame_purple_open`.

**U3 Title, landscape (3)**
1. The island renders at about 70 px and the logo at about 180 px on a 1280 canvas. Most of the screen is
   empty haze. Fix: in `orientation_layout.gd`, use a two-column landscape layout with the art column on
   the left (wizard, island and logo at 55% width) and the button column on the right.
2. The wizard is detached from the island and floats off-axis. Fix: anchor the cloud to the island's top-left corner.
3. All the U1 beige and backdrop defects also apply.

**U4 Mode select, portrait (4)**
1. **Beige**: the whole frame interior is flat `#f6e7c4`-family parchment. Fix: use `frame_purple_open`
   with no interior panel, so the painted backdrop shows through (ref 05). Delete the `panel_parchment`
   fill in `game_ui.gd:464` (the frame builder).
2. The cards are character turntable renders on flat gradients, not **painted illustrations**. Bible §5d
   specifies a campaign path over islands, a trophy, rainbow cubes with a stopwatch, a book with a castle,
   and an orbit of islands. Fix: commission 5 painted card illustrations (`ui_card_campaign_01.png` etc.,
   1024×640 or 640×900), or render Blender dioramas.
3. The Story card reuses the Campaign wizard pose at a smaller size, so the same image appears twice on one
   screen. Fix: the open-book illustration.
4. The cream "Shop / Toy box" pills are beige and read as debug buttons. Fix: wood-sign pills with icons,
   or move them out to the title.
5. Frame thickness: the purple rails are about 22 px. The ref rails are about 6% of the width (about
   44 px at 720), with grain, gold star caps on all four corners, and vines climbing the sides and top,
   not only the corners. Fix: re-render `frame_purple` with a thicker plank profile, a vine run along the
   top rail and blossoms every ~120 px.
6. The title plaque is too small (about 250 px wide, letters about 26 px). The ref plaque is 40% of the
   frame width with chunky bevelled letters. Fix: scale `plaque_title` ×1.5 and render the letters with a
   3–4 px dark outline plus a 2 px lit bevel. The current letters are flat fills with a thin outline.
7. Card labels are tiny wood signs. The ref uses big multicolour or bevelled cream labels that overlap the
   card's bottom edge. Fix: scale the label ×1.4, overlap the frame by 40%, and use display font 34 px.
8. Description strips ("Follow the island path…") are extra text that the ref does not have. Drop them or
   move them to a tooltip.
9. Dead band above BACK (about 70 px). It closes once fix 4 lands.

**U5 Mode select, landscape (3)**
1. Cards are letterboxed strips (about 3.5:1) with 60 px characters floating in empty gradient.
   Fix: use ref 05's grid. Campaign is a big 4:3 card on the left. Tournament, Biomes, Arcade and Story go
   on the right.
2. Beige interior and cream pills, as U4.
3. No surrounding scene. Ref 05 shows a blurred library with windows onto islands. Fix: add a painted
   library backdrop with gaussian depth blur.

**U6 Physics Toy Box menu (2)**
1. 60% of the screen is an **empty beige void** below the card.
2. Beige page plus a beige card. Same kit fix as U4.1, with content panels in plum glass.
3. The dropdown is a cream pill. Fix: OptionButton uses a wood pill with a gold chevron (ref 08 "ENGLISH ▼").
4. There is no illustration of the challenge. Fix: put a picture card per challenge (a domino-chain render)
   in the empty space, or vertically centre a smaller panel over the painted backdrop.
5. A Settings pill in the top right of a sub-screen, beige. Fix: use a gear gem icon button.

**U7/U8 Lobby (3 / 2)**
1. The players are a plain text list ("Clover · Cloud Wizard · 1 perk"). Ref 14 shows four portrait cards
   with recoloured wizards, P1–P4 shape markers and Ready/Not-ready pills. Fix: use a
   `PlayerCard` type variation in the Theme with a portrait slot, marker and status pill. The 1280 version
   hides the toy-box section entirely.
2. Beige page, two beige cards and the cream "Leave lobby" pill.
3. The raw IP "192.168.1.20:24680" is the largest text block. Fix: put it in a small dark code chip with a
   copy icon.
4. Toggle rows are left-aligned labels with right toggles across a 500 px gap. Fix: use a two-column grid
   of mode tiles with icons (ref 14 "Game mode" segmented control).
5. Rivalry title letters: multicolour is correct, but there is no bevel or drop shadow. The fix is the same
   as U4.6.

**U9 Puzzle Tools (3)**
1. Eleven identical cream pills stacked in four beige cards, with no icons. Fix: use icon tiles (a piece
   render for Mono, Tri Corner and Duo; arrow gems for directions) in a 3-column grid on plum glass.
2. A dark-purple bleed shows outside the frame (`#3f2a55` body behind a scroll overflow). The frame does
   not fill the viewport. Fix: anchor the full-rect frame and clip the scroll inside.
3. The scrollbar is a default grey Godot bar. Fix: style the `VScrollBar` grabber as a gold star knob on a
   wood track in the Theme.
4. The disabled "Duo ×0" is a muddy beige-grey. Fix: plum glass at 50% with a lock icon.

**U10 HUD capture (1)**
1. The capture shows a **flat grey `#4a4a4a` void**, with no world, sky or island behind the HUD. Either
   the screenshot harness renders the UI without the 3D viewport, or the HUD layer has an opaque
   background. Either way, the evidence is invalid. Fix: re-capture with the stage loaded, and make sure
   the HUD root `Control` has no `Panel` background.
2. The HUD chips (SCORE, NEXT) are beige parchment. The NEXT chip is empty apart from the text "Tri
   Corner", so no piece render is shown. Fix: put a `wt_piece_preview.gd` render in the chip, drop the text
   name, and use a plum glass face.
3. The goal pill and hint pill are cream. Fix: dark plum lozenge with gold text (bible 5b timer style).
4. The control rows hold 10 small wood buttons (View, View, Soft, Kit, Skill, Potion, Flip, Flip, Roll,
   Roll) in two rows at about 30 px tall. This clutter is not in ref 15. Fix: collapse them into a
   radial/gesture or a 4-icon bar of round gems. Ref 15's bottom is only the 3-slot tray.
5. The tray slots are beige. "HOLD" is a glowing yellow empty box. Fix: plum glass slots with piece renders.
6. The timer "0:42" is clipped off the bottom edge (y≈1272). Fix: give it a safe-area margin and a dark
   lozenge at the top centre (bible 5b).
7. The frame is a brown 8 px rail. Bible §4 calls for a **biome-tinted** frame (green vines for meadow). Fix:
   per-biome frame textures (`chip_hud_*` already exist; extend them to a full-screen frame).
8. 1280 version: two beige parchment side panels cover about 40% of the screen. Fix: use floating gem
   button clusters on the left and right edges, with no panel.

**U11 Items bar (1)**
1. The power-up panel **overlaps the goal chip**. "Party toy box Clear layers 0/5" is clipped behind it,
   which breaks the bible rule "chips never cover the play area". Fix: stack it below the goal row or
   dock it into the tray.
2. The panel is beige with three beige slots. Text-only labels ("1 · Slow time") with no icons.
   Fix: round gem slots with item icons (hourglass, fog cloud, eye) and number badges.
3. The disabled "Potion 0" is dark brown and looks like a different kit.

**U12 Story intro (1)**
1. **Flat vector clip-art.** Thin outlines, no shading, a flat beige card on a slate `#2e3f4c` background
   and a flat orange bar button. The bible bans every one of these ("Never flat vector").
2. The wizard is drawn as a blue triangle hat on a dot face. That is a third, off-model wizard.
3. A row of 10 tiny blob creatures with no meaning or hierarchy.
4. The bottom button is a flat orange rectangle with an arrow glyph. That is the default theme. The skill
   rule "no unstyled buttons" applies.
Fix: replace the entire screen with painted story panels (see S1) in the purple frame with a banner
plaque. Until then, gate the screen off. The owning scene could not be located by grep. It is probably a
legacy path that the `full-build` harness still reaches. Owner story/ui.

**U13 Desktop (NOT ASSESSED)**: the frame is pure black. Re-capture it.

**U14/U15 Legacy landscape title and gameplay (1)**: v1 flat UI (Noto-like font, navy hairline borders,
beige panels, flat cartoon). If these screens are still reachable in the build, they are a ship-blocker.
If they are stale captures, delete them from `production/qa/evidence/full-build/` so they stop being
treated as evidence.

### Levels and biomes

**L1/L2 Meadow (5 / 5)**
1. Backdrop: the mid-ground hills are flat-shaded cutout cards with visible vertical seams. The waterfalls
   are opaque white vertical bars that read as UI glitches. Ref 15 has painted layered mountains, multiple
   misty waterfalls and depth haze. Fix: `canvas_env_sky.gdshader` plus a painted backdrop plate
   (`env_meadow_backdrop_far.png`) with 3 parallax layers. Replace the waterfall cards with a scrolling
   UV-noise material, 40% alpha at the base.
2. The distant floating islands are too close, too big, too saturated and too uniform (identical grass
   slab plus 4 lollipop trees). Fix: halve the scale, push them back, add aerial-perspective fog
   (`fog_enabled`, depth fog begin 30, end 120, light colour sampled from the sky horizon), and vary the
   landmarks (castle, windmill, waterfall, arch).
3. Beige board tiles. Fix: cool grey stone per section 0 (`spatial_env_tile.gdshader` albedo plus grout
   darkening).
4. Block readability: grass-cap blocks are correct. The blue and yellow pieces have no cap and look like
   flat cracked plaster. Ref 15 puts a soft grass edge and sprout toppers on coloured pieces too. Fix:
   `spatial_block_biome.gdshader` should apply the biome cap mask to every piece, with palette tint only on
   the body. Toppers go on 1 of every 3 cubes.
5. Ghost (L2): flat tan squares. Fix: translucent glassy cells with a glowing edge (`spatial_block_ghost.gdshader`
   needs fresnel edge, 25% alpha, emissive outline).
6. The in-world mascot is a grey cone-hat blob that does not match the hero wizard. Fix: use the wizard GLB,
   or remove it.
7. Rim and lighting: there is no warm key from the top left and no golden-hour tint. The island reads
   flat-lit. Fix: DirectionalLight3D at about 4200 K, 45° from the top left, a cool fill, and AO on the
   island skirt (SSAO on Forward+, baked vertex AO for mobile).
8. Framing: the island is cropped on both sides and its bottom roots hide behind the control strip. Fix:
   pull the camera back about 12%, or shrink the play area so the island skirt clears the tray.
9. Debug text "I, O, L" sits under the NEXT render. Remove it.

**L3 Meadow, landscape (4)**: all of L1, plus the backdrop is a repeated row of identical mesa pillars
(obvious instancing), the island is about 35% of the height, and the beige side panels eat 40% of the width.

**L4 Ice (5)**
1. Value range is collapsed. Everything sits between lavender-grey and pale blue, so nothing has
   contrast. Fix: deepen the cliff blue to `#3e6fb3`, add a dark navy underside, and keep the snow white.
2. Ice blocks on an ice board: poor block readability. Fix: give the board tiles a frosted, desaturated
   grey-blue (lower value) so the saturated piece colours (cyan, violet, pink in ref 15) pop.
3. The backdrop mountains are flat cutouts and the castle is tiny and grey. Fix: a painted castle on a
   floating chunk as in ref 15, at mid-distance.
4. Beige HUD chips glare against the cool palette. That is the section 0 fix.
5. The NEXT caption is truncated ("Screw Right, Screw Left"). Remove the caption.

**L5 Lava (4)**
1. Muddy: maroon sky, brown board, brown cliffs and brown blocks all sit in one hue band. Fix: near-black
   basalt (`#2a2224`) on the island, a dark crimson-to-black sky, and **one** strong emissive accent
   (lava pool, rivers in the cliff seams) per bible §7.
2. There is no lava surface anywhere. Ref 07 Molten Guardian has a glowing lava sea. Fix: a lava plane
   under the island with an emissive flow shader and bloom.
3. White glowing discs on the board rim read as holes or UI markers. Fix: orange emissive vents with a
   heat-shimmer sprite.
4. The distant islands look like inverted flowerpots with a white light dot. Fix: volcano silhouettes
   with an orange glow cap.
5. The blocks' crack pattern is a regular brick grid, not organic basalt cracks (ref 13). Fix: a Voronoi
   crack mask in `spatial_block_biome.gdshader` for lava.
6. The brown wood UI frame on lava is unrelated to the biome. Fix: a dark-iron frame variant.

**L6 Celestial (5)**
1. The sky has visible vertical and perspective **grid lines**, which look like a debug overlay. Fix: remove
   the grid from `canvas_env_sky.gdshader`, or set its alpha to 0 in the celestial preset.
2. The board is beige-pink tile. The ref has white marble with gold inlay and a clock-face disc on the cliff.
   Fix: a marble albedo with gold seam emission.
3. Galaxy blocks are dark navy on a dark navy sky, so readability fails. Fix: brighten the block body to
   ref 13 violet `#5b3bc8`, add a gold rim fresnel, and add a star topper.
4. The planet is a flat lilac ball with a beige ring. Fix: a painted gas-giant texture and a lit ring.
5. There is no nebula. Ref 15 has a purple-magenta galaxy swirl. Fix: a nebula layer in the sky shader.

**L7 Candy (4)**
1. Washed out. A pink fog sits over everything and saturation is low. Fix: cut fog density by 60% and
   raise saturation on frosting and sprinkles.
2. The blocks are opaque matte (green, red, cream). Ref 13 candy is **translucent jelly** (pink, orange)
   with a dripping frosting cap and a heart topper. Fix: subsurface or fake-transmission (backlight term
   in `painted_light.gdshaderinc`) and a jelly palette.
3. The board is beige/cream tile. Fix: pink-white sugar tile.
4. The backdrop pillars are flat cutouts with flat white tops.
5. The frame is brown wood. Fix: a pink frosting frame variant.

**L8 Physics toy box scene (2)**
1. A default Godot look: untextured pastel cubes, a flat light-blue clear colour, a flat green slab and
   grey default buttons. Placeholder in every respect.
2. The HUD is raw label text. The buttons are default Godot theme (banned).
Fix: put this mode on the stage pipeline (`wt_stage.gd`, meadow island, `spatial_block_biome` blocks) and
the `GameUi` theme. Do not ship a second renderer path.

### Characters

These apply to all cast renders (Blender, `assets/source/blender/characters/`, then render to
`assets/art/ui/`):
- **Material**: smooth plastic or clay with no painted texture, no colour variation and no hand-painted
  gradient. Bible pillar 2 says "Painted, not vector … painted shading". Fix: bake a painted albedo layer
  (warm-to-cool gradient, edge highlights, cheek and knuckle tints).
- **No rim light.** Every render is lit front and top with a dark falloff. Fix: add a cool rim lamp behind
  the subject, back-left, at about 3× key, plus a warm bounce from below.
- **Metal** (knight, dwarf helmet, pickaxe) is mirror chrome, which reads as CG rather than toy. Fix:
  roughness 0.35, with a painted highlight band.
- **Floating hands**: the knight (both renders), the dwarf (cheer) and the elf show hands detached from
  the arms. The wizard's arms are connected. This is inconsistent across the cast. Fix: model wrists, or
  commit to floating hands on every character. Pick one.

**C1–C4 Wizard (6/6/6/5)**
1. Eyes: in idle and point, the open glossy eyes under heavy grey brows read as surprised or stern. Ref 15
   and 16 use a **closed-eye smile** as the default expression. Fix: the closed-eye smile becomes idle.
   Open eyes are kept for "oops" only.
2. The hat has one cream star. Ref: several gold stars, a cream band, and a floppier bent tip. The robe has
   2–3 tiny stars. Ref: an all-over star pattern with cream trim.
3. The beard is one smooth mass. The bible calls for 3–5 curl lobes. Fix: sculpt the lobes with a painted
   cavity shadow.
4. "oops" is idle with the arms raised. There is no surprise in the face, the brows or the body tilt.
   Fix: O-mouth, raised brows, body leaned back, hat tipped.
5. The cloud swirls are faint. Fix: stronger lilac swirl paint and a soft emission underside.

**C5/C6 Knight (5/5)**
1. Chrome armour (see above). 2. The face is too plain. Add a visor brim and rivets. 3. The idle pose is
   stiff and static. 4. The sword blade is a flat unbevelled slab. Add an edge bevel and a fuller.

**C7/C8 Dwarf (4/5)**
1. The beard sculpt has lumpy noise (cellulite-like bumps) and swallows the body. In idle the silhouette
   is a beard blob. Fix: smooth the beard into 4 big braided lobes and shrink it by 20% so the arms read.
2. The idle camera angle looks up from below, so the face is cropped by the helmet. Fix: a three-quarter
   view from slightly above, as the bible's 2D-portrait rule requires.
3. Neither render has a backpack (bible §5).

**C9/C10 Elf (4/5)**
1. **IP risk**: the combination of green tunic, green pointed cap, blond side-hair and pointed ears reads
   as Link. Bible §5 forbids Nintendo IP. Fix: change the hood to a leaf-shaped hood with a tan trim, change
   the tunic to a mossy olive-teal, and give the hair a different cut. This is an escalation item for
   creative-director.
2. Elf idle: there is a visible gap and hole where the neck should be inside the collar. Fix: close the
   neck geometry.
3. The slingshot fork in idle is a closed loop of malformed geometry. Remodel it.

### Story

**S1 Story panels (0, missing)**: `assets/art/story/` does not exist. The only story screen is the U12
vector placeholder. Bible §5e lists 9 painted beats. Fix: produce at least "The Story Begins" and
"Learn to Stack" as painted 3-layer scenes with banner plaques (ref 07 composition), and gate story mode
behind "Coming soon" until they exist. The mode card already does this.

---

## 3. Top 15 fixes, ordered by visual impact

| # | Fix | Owner |
|---|---|---|
| 1 | Purge parchment and cream from the kit. Retire `PARCHMENT`, `PARCHMENT_DEEP`, `CREAM_PILL` and `STAR_OFF` in `wt_storybook.gd`. Re-render `panel_parchment`, `btn_cream`, `chip_hud*` and `tray_slot` as plum glass or purple wood. Move all colours into one Theme `Palette` type, and delete the hardcoded fallbacks in `game_ui.gd:137-166` and the duplicated `MINT` | ui |
| 2 | Screen interiors become frame plus painted backdrop (ref 05), with no fill panel. Content groups use plum glass panels via a `PlumPanel` theme type variation | ui |
| 3 | Fix the HUD evidence and layout: render the 3D stage behind the HUD, collapse the 10 control planks into a gem icon bar, give NEXT and tray slots piece renders, put the timer in a safe area, and stop the item bar overlapping the goal chip | ui |
| 4 | Replace the beige board tiles with biome stone (grey stone, marble with gold, sugar tile), and make the ghost cells glassy and edge-lit | world |
| 5 | Kill the vector story screen (U12) and the legacy landscape v1 screens (U14/U15). Gate story behind "Coming soon" | story |
| 6 | Painted backdrops: 3-layer parallax plates per biome, real waterfalls, depth fog, and smaller, farther, varied distant islands | world |
| 7 | Mode-select picture cards: 5 painted illustrations per bible §5d. Use the ref 05 layout in landscape | ui |
| 8 | Block shader: biome cap mask on every piece, palette tint on the body only, toppers on 1 cube in 3, jelly transmission for candy, Voronoi cracks for lava, brighter galaxy with gold fresnel for celestial | blocks |
| 9 | Lighting pass: warm top-left key, cool fill, rim, SSAO or baked AO under island lips. Lava gets a single strong emissive accent and a lava sea | world |
| 10 | Frame upgrade: thicker purple planks, gold star caps on all corners, vines along the rails, and biome-tinted HUD frames (vine, ice, gold-star, iron, frosting) | ui |
| 11 | Display titles: chunky bevelled multicolour letters with a 3–4 px dark outline and drop shadow, with the plaque scaled ×1.5 | ui |
| 12 | Celestial sky: remove the grid lines, add a nebula, and paint the planet | world |
| 13 | Cast material pass: painted albedo, rim light, toy metal (no chrome), one consistent hand rule, wizard closed-eye-smile default, beard lobes, star pattern | characters |
| 14 | Elf redesign away from Link. Fix the neck hole and the slingshot | characters |
| 15 | Title screen: library-shelf foreground, an island ×1.6 with cottage and waterfall, MODES turned into a wood sign, and the landscape two-column layout | ui |

## 4. Process notes

- `production/qa/evidence/islands-v2/` holds about 80 captures across 8 iteration suffixes
  (`_final`, `_polish`, `_caps`, `_post`, `_post2`, `_v3`). There is no single "current" set, and some
  biomes stop at `_polish` while others reach `_v3`. Re-shoot all 5 biomes on one build with one suffix.
- `desktop.png` is black. Re-capture it.
- The bible's §9.6 rule is "every art change ships with a screenshot side-by-side with its reference". The
  UI captures have no `_vs_ref` pairs. Add them.
