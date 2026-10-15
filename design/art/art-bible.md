# Wacky Towers — Art Bible

> **User rule, 2026-10-14: no beige or parchment interface.** "You did not remove beige interface like
> I said." Parchment and cream are retired as surface colours. Windows are open purple-wood frames over
> the painted scene (ref 05). Groups of controls use plum glass or wood planks. This rule overrides any
> parchment wording elsewhere in this bible. See `.claude/docs/reference-quality-bar.md`.


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
3. **Dioramas.** Every play space is a level-specific diorama: the board sits in its own terrain
   (plank bridge, fort wall, raft, mine shaft, ravine ledge). The floating island, with a grass, snow
   or stone top, layered rock cliffs under it, roots or icicles hanging down and a sky full of
   distant islands, is one terrain among many (amended 2026-10-14, user rule "a level is a scene, not a grid").
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
| `parchment` | `#f6e7c4` | **RETIRED for surfaces (user rule 2026-10-14).** Only small text or highlights; never a panel, card, chip or button fill |
| `parchment_shade` | `#e2c995` | **RETIRED (user rule 2026-10-14)** |
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
| **Plum glass panel** | Translucent dark purple (`wood_purple_dark` at about 75%) with a soft inner border and very rounded corners. It replaces the retired parchment panel (ref 05) |
| **Wood panel** | Brown planks, horizontal grain, rope border for sub-groups (ref 04) |
| **Title plaque** | Purple-wood scroll plaque, gold trim and curls, multicolour title text (refs 05, 06) |
| **Primary button** | Gold glossy pill: thick gold-deep lip underneath, white specular streak on top, a star icon on the left, dark-plum ALL-CAPS text ("PLAY", "BACK", "DONE") |
| **Secondary button** | Purple-wood or brown-wood pill with a dark lip and cream text (refs 08, 04) |
| **Close button** | Red round or square gem, white ×, gold rim |
| **Toggle** | Rounded track (green ON, cream OFF) with a star knob |
| **Slider** | Branch or stick track with a gold star thumb (ref 08) or a coloured fill (ref 04) |
| **Mode / picture card** | Painted illustration in a gold or wood frame with a signboard label (refs 03, 05, 06) |
| **HUD chip** | Plum glass card in a biome-tinted frame (green vines, ice blue, celestial purple), with a label and a big number (ref 15) |
| **Next / hold slot** | Square plum glass tile in a biome frame showing a 3D render of the piece (ref 15) |
| **Piece tray (bottom)** | A three-slot plum glass or wood shelf in a biome frame (ref 15) |
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

| Character | Look (silhouette key, colour key, prop) |
|---|---|
| **The Wizard (mascot)** | Tall floppy purple hat with gold stars and a cream band, purple robe with star pattern and cream trim, huge white beard in 3-5 curl lobes, rosy cheeks, closed-eye smile, gold star wand. Rides a puffy cloud with lilac swirls. Poses: point (story), wand wave, peek (settings), cheer. Colour key: purple + white + gold (refs 01, 02, 07, 15, 16) |
| **Knight** | Silver plate with a red plume, round friendly face, short sword or cannon crew (refs 01, 07, 09). Colour key: silver + red |
| **Pirate** | Tricorn with skull badge, red or ginger beard, eyepatch, blue coat, cutlass. Colour key: navy + red (refs 01, 09, 10, 16) |
| **Dwarf** | Stocky, ginger braided beard, steel helmet or miner's lamp, pickaxe or hammer, backpack. Colour key: ginger + steel (refs 01, 02, 12) |
| **Elf / Thief** | Blond, green tunic and pointed hood, slingshot, grappling hook or lockpick. Colour key: green + tan (refs 01, 10, 11, 12) |
| **Robot** | Small white and blue round-headed robot, glowing blue visor eyes, antenna, tiny arms. Colour key: white + cyan (refs 09, 12, 16) |
| **Astronaut** | White chunky suit, gold-tinted round visor, backpack. Also used as a diver (ref 06). Colour key: white + gold visor (refs 02, 07, 12) |
| **Explorer** | Pith hat, brown vest, backpack, rolled sleeves, runs (refs 06, 11, 12) |
| **Alien** | Small green-skinned humanoid with big black eyes, sleek suit, hover board (ref 06). Colour key: lime + purple |
| **Gnomes** | Tiny garden gnomes: red pointed hat, white beard, round nose. Meadow Mayhem herders and rock throwers (refs 12, 14, 15). 1.5 heads tall |
| **Tournament wizards** | Four recolours of the mascot wizard at the same silhouette: red P1 (circle), blue P2 (triangle), green P3 (square), purple P4 (star). The marker shows on the hat and the tag. Each sits on a cloud (ref 14) |
| **Crowd / extras** | Painted blurred spectator silhouettes with banners for arenas (refs 01, 07). Low detail, never in focus |
| **Wildlife** | Sheep (fluffy, round), penguins, monkeys, jellyfish, shark, sea serpent. Same soft toy forms (refs 02, 10, 15, 06) |

Each hero needs 5 poses: idle, run/carry, cheer, oops, point. Eyes: small glossy black ovals with
catch-lights. Faces are friendly even on bosses' enemies (goblins excepted).

### 5a. Bosses and enemies

| Boss | Look | Where |
|---|---|---|
| **Molten golem** | Hulking basalt body, glowing orange cracks and a lava-rim mouth, big fists, rises from a lava pool. Emissive 2.0+ in cracks, dark rock mass, orange splash lighting | Forge Boss, Molten Guardian (refs 02, 07) |
| **Rainbow kraken** | Giant octopus with a rainbow gradient body, purple suckers, big yellow eye, foamy white splash. Tentacles frame the screen edges | Kraken Blockade (ref 12) |
| **Angry wind cloud** | Puffy storm cloud with a furious face and blowing cheeks, swirl streams of wind, lilac shading. Used over the sky climb | Chroma Sky Climb (ref 12) |
| **Stone guardian** | Moss-covered stone golem with glowing teal eyes, sleeps in a maze of ruined pillars | Maze Heist (ref 11) |
| **Goblins** | Green skin, big pointed ears, big noses, ragged brown clothes, throwing rocks from the bushes. The only "scary" faces in the game, and still cartoon | Goblins' Ambush (ref 07) |
| **Sea serpent / swamp monster** | Teal friendly-grumpy sea monster with fins | Tumbling Towers (ref 10) |

Boss rules: silhouette reads at 64 px. Each boss carries one dominant colour and one accent. Never
photoreal. A boss health bar uses the party HUD language (5b).

### 5b. Party-mode HUD language (refs 09-12, 15, mockups 06/12/14/15)

All items share one set of materials: dark translucent navy-brown tags for the top row, plum glass
cards for the bottom row, wood-brown signboards for names.

| Element | Spec |
|---|---|
| **Top player tag** | Rounded dark tag (navy for P1-style, brown-red for opponents), portrait on the outer side, name in Fredoka 700 cream, score in a bigger number. Stack of 2-4 tags down the left or right edge. P1 left, others right |
| **Player card (portrait mode)** | Plum glass card in a wood frame, bottom corner. Tab above it in the player colour with the label "P1" to "P4" (red, red-brown, gold, green). Portrait box left, "SCORE" and a big number, "LIVES" with 3 red hearts (empty = dark heart). Wizard portrait sits left of the number |
| **Goal chip** | Plum glass card bottom right: minigame name in brown caps, goal line in small caps ("GOAL: HERD SHEEP!"). Torn-paper edge |
| **Round timer lozenge** | Dark rounded lozenge top centre, cream digits, optional gear ornament on the sides, bunting above in party mode |
| **NEXT slots** | Square wood-framed slot top right: label NEXT BLOCK / NEXT AMMO / NEXT ITEM / NEXT RAMP / NEXT HAZARD above, a 3D icon inside (block, log, ramp, key, pickaxe, boxing glove, boot, blaster) |
| **Vertical thermometer meters** | Glass tube with a bulb at the bottom and a red-yellow-green gradient (heat: orange fill; balance and stability: red-yellow-green with Danger tick; altitude and pressure: green or cyan fill; speed boost: green). Label above. Always on the left edge |
| **Horizontal bars** | Rising Lava Height, Conveyor Speed, Guard Sleep, Fort HP: thin wood-framed bar, coloured fill, small icon at the left |
| **Boss health bar** | Wide red bar with a dark frame, top centre under the timer, label "BOSS" above |
| **Goal chips / counters** | Small plum glass chips: sheep 5/10, stars 7/12, targets 8/15, treasure 0/30 |
| **Live leaderboard** | Dark panel, 4 rows, rank, portrait, score, gold highlight on first place |
| **Hazard sign** | Yellow triangular warning sign with a red exclamation mark, on island edges |
| **Hint bubble** | White speech bubble with a brown outline and a pointing-hand cursor |

Rules: HUD sits in the outer 15% of the screen. Chips never cover the play area. Colours of player
tags match the P1-P4 colours used in the tournament (red, blue, green, purple).
Sci-fi biomes (Cosmic, Quantum Spire) swap parchment for **holographic panels**: cyan glass, thin
bright edge, hex pattern (refs 02, 17).

### 5c. Party Quest hub (mockup 16)

A **central wooden fort** on a floating island: octagonal plank deck, rail posts with lanterns, a
barrels-and-cannon corner, a purple banner with a gold crown hanging below, a scoreboard stage at the
back with a purple pennant and a four-row scoreboard. The four heroes (wizard, pirate, astronaut,
robot) stand in the middle. **Four glowing wooden bridges** with blue rope-light run from the
corners to four minigame islands, each a unique miniature of its game:
Bridge Builders (grass island with block bridge), Bomb Defuse (brass clockwork disc with a giant bomb),
Balloon Race (a cloud with a racing track and balloon carts), Lava Escape (volcano with a block pyramid).
Each island has a brown signboard with its name and, optionally, a small stat row. Background: a flat
sky blue, one gentle gradient, no clutter. Camera: iso 3/4 from above. The logo sits above the hub.
Use our logo, not the board's.

### 5d. Mode-select picture cards (refs 03, 05, 06)

Each mode is a **painted illustration** inside a gold or wood frame. Content:
- **Campaign**: winding dirt path over floating islands, stone towers, a red flag, the wizard on a cloud
- **Story**: open glowing book, a castle springing from it, a feather quill
- **Tournament**: gold trophy with a star, banners, a crowd silhouette, confetti
- **Arcade**: tumbling rainbow cubes, coins, a stopwatch
- **Biomes**: orbit of floating islands around a globe: meadow, ice, crystal
A signboard label hangs over the bottom edge, cream text with a brown carved look, a tiny icon on the left.
Variants: a big Campaign card with a "Level 15" ribbon, a "LIVE NOW" red badge on Tournament (ref 05);
all five equal cards in a grid over the painted scene with a candy-coloured outline per card (ref 06); library
scene with five tall portrait cards on a shelf (ref 03). The wizard peeks over the top-right card.
Background is a blurred library with big windows showing floating islands.

### 5e. Story-beat scene composition (refs 01, 02, 07)

Painted full-scene cards, one per beat, each with a **banner** at the bottom (purple wood or gold
ribbon plaque with cream caps text). Compose with a clear foreground character group (rule of thirds), a
glowing focal object (book, tower, treasure chest, portal) and a depth of 3 layers.

| Beat | Composition |
|---|---|
| The Story Begins (lost tomes) | Library interior, warm candlelight, the wizard points at a glowing open book on a lectern, elf and dwarf watch, a ghosted block tower rising from the book, potion bottles |
| Learn to Stack / tutorial | Bright sky, floating meadow island, a ghost block and dotted arrows, the wizard on a cloud, a hand cursor and a white tutorial bubble |
| Explore the Biomes | Cart carrying heroes on a stacked-block wagon along a path through ice castle, volcano and neon city islands |
| Canopy Chaos | Jungle, a buggy loaded with mossy blocks, monkeys, vines, waterfall |
| Goblins' Ambush | Forest clearing, a brick fort and cannon, goblins throwing rocks |
| Forge / Molten Guardian | Dark cave, orange rim light, golem rising from lava, miners with cart, lava-cracked blocks |
| Cosmic Gateway / Nexus | Purple galaxy, a glowing crystal tower with a gold star, a swirling portal, astronauts on floating plates |
| Grand Finale | Gold chest brimming with jewels, fireworks, confetti, the cast cheering on a floating island, "STORY VICTORY!" ribbon |
| Tournament | Arena with bunting, crowd, towers of coloured blocks colliding, cannons and catapults |

Scene lighting: one hero light (candle, lava, portal, sun) plus a cool fill. Palette per beat is warm
or cool, never mixed. Text is always in a banner, never loose.

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

- **Board terrain** (amended 2026-10-14: the board follows the level's mask and terrain, and the square
  stone-tile board on a floating chunk of ref 15 is one terrain among many). In that terrain the board is
  slightly inset on a thick chunk. The biome rim around it has flowers, clover and grass tufts (meadow), snowy
  shrubs and frost trees (ice), or marble with gold inlay and broken pillars (celestial).
- **Cliffs:** 2–3 layered rock bands with painted strata. Roots, icicles or crystals hang from
  the bottom.
- **Backdrop:** painted sky (gradient plus soft clouds) and 3–6 distant floating islands with
  biome landmarks (castle, waterfall, volcano, temple arch). Light atmospheric haze.
- **Lighting:** warm key light from top-left, cool fill, soft shadows, glow on emissives,
  gentle bloom. Golden-hour warmth by default. Ice is cool. Celestial is night.
- **Fair** (ref 14): bunting, lanterns, tents, Ferris wheel in a dusk palette.
- **Minigame biome sets** (refs 09-12, mockups): waterfall canyon with a river (Bridge Bashers), snowy
  mountain with avalanche (Avalanche Ascent), lava cave (Rubble Rumble, Digging Frenzy), castle meadow
  (Fort Frenzy), forest racing track (Rolling Rumble), tropical ocean (Tumbling Towers, Kraken),
  sea cliff and ships (Shatter Shootout, Fort Blast), jungle temple (Temple Roller), underwater (Submarine
  Salvage), clockwork factory (Clockwork Conveyor, Factory Frenzy), neon stadium (Cosmic Gravity Goal),
  candy cake land (Candy Dodger), glacier (Glacier Rush), crystal mine (Gem Grab), sci-fi hex deck
  (Cyber Defender, Neon Splat, Quantum Spire). Every set is an island or arena diorama with a
  readable play surface and dressing on its edges.

---

## 8. Screens (what each must look like)

| Screen | Reference | Key elements |
|---|---|---|
| Title | 15 (left) | Wooden logo, wizard on cloud, cottage island with waterfall, big gold PLAY, wood BIOMES sign, library shelves framing it |
| Mode select | 05 / 06 | Purple-vine frame, "SELECT MODE" plaque, 5 painted picture cards, gold BACK |
| Level map | 06 "Campaign" card | Winding path over floating islands, round stone level nodes, wizard on cloud |
| In-level HUD | 15 | Pause gem, SCORE chip with stars, NEXT chip, biome frame around the screen, 3-slot piece tray at the bottom |
| Results | 02 "Story Victory" | Banner, treasure chest, confetti, star row, gold buttons |
| Settings | 04 / 08 | Open purple frame over the painted scene, plum glass rows, star sliders, star toggles, signboard headings |
| Tournament | 14 | Lobby cards, spinning wheel, 4-island round play, standings table, win screen |
| Story beats | 01 / 02 / 07 | Full painted scenes, title banner. Optional and secondary. Never flat vector. See 5e |
| Party minigame | 09-12, mockups 12/14/15 | Diorama play area, top tags, timer, NEXT slot, meter, player card. See 5b |
| Party Quest hub | mockup 16 | Fort, four bridges, four islands. See 5c |
| Mode select | 03 / 05 / 06 | Picture cards. See 5d |

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
- [ ] No board logo (TETRO PARTY DIMENSIONS, WACKY PARTY, PARTY QUEST) and no "Tetris" naming.
- [ ] Characters: 2.5 heads tall, one colour key, readable at 64 px.
- [ ] HUD pieces use the 5b tokens and never overlap the play area.

## Asset sourcing rule (user, 2026-10-15)

Don't reinvent the wheel. Before modelling, search for an existing CC0 mesh, model or texture (PolyHaven, free CC0 BlenderKit, and what the repo already has in `assets/models/env_v3/` and `assets/third_party/`), then modify and restyle it. Keep every downloaded original, unmodified, in `assets/library/<models|textures|hdri>/<source>/<asset_name>/` with a `LICENSE.txt` (source URL and licence), so it can be reused. The restyled game version goes to the level's own folder, and every third-party source is credited in `assets/third_party/CREDITS.md`.
