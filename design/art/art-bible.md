# Art Bible: Wacky Towers

> **Status**: Draft
> **Owned By**: art-director
> **Last Updated**: 2026-10-08
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-10-08 — lean mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

**The rule: the blocks are the toys, and everything else is the box they came in. When in doubt, make the board louder and the world quieter.**

What we take from the references is a mood, not a spec. That means a painterly cartoon finish, chunky bevelled pieces with glossy highlights and soft outlines tinted to each piece's hue, floating-island boards shown as dioramas, UI frames themed to each biome, and the wizard mascot on a cloud. Exact palettes, materials and props are decided per biome later.

These are defaults. A game mode or biome can override them; run the check in 4.7 when it does.

### Principle 1: Silhouette Before Surface (Pillar 1: The Block Is the Constant)

By default every piece keeps the same chunky, bevelled, soft-outlined shape language in every biome and every state. Biomes and status effects can re-skin a piece's surface: frost, honey, cracks or a thin shell. They leave its outline alone, because the silhouette is how players recognise a piece on a small screen. From the candy-block sheet we take the jelly gloss and tinted outlines. We leave out the sphere and the faceted gem shapes, because they break the shape vocabulary.
**Design test:** when a skin or effect would change a piece's outline, prefer the version that keeps the silhouette and moves the effect onto the surface.

### Principle 2: Quiet World, Loud Board (Pillar 2: Readable Chaos)

By default pieces are the most saturated, highest-contrast things on screen. Backdrops, islands and props sit lower in saturation, contrast and motion. The grass-island reference is the target: candy pieces pop against a soft sky and muted ground. The ice reference shows the trap: ice-tinted pieces on an ice board fade into the scene.
**Design test:** when a backdrop element competes with a piece or an effect for attention, soften the backdrop first and leave the piece alone.

### Principle 3: Reserved Accent Colours (Pillar 3: Comeback Energy)

A clutch item only flips a round if both players can read it instantly. By default each effect type gets its own accent hue. Biomes, pieces and player colours stay clear of it so the effect is never ambiguous. For the same reason, glowing backgrounds like the lava sheet's magma are best kept away from the hazard accent.
**Design test:** when a biome, piece or player colour drifts toward an effect accent, the default is to change the other colour and keep the accent, because players learn the accents across every biome.

## 2. Mood & Atmosphere

By default the art style stays the same between states. The pieces, outlines and painterly finish don't change. Mood comes from four default controls: light temperature, the backdrop's contrast and saturation, ambient motion (clouds, particles, wind streaks) and screen overlays (vignette, flash). Following Principle 2, these controls act on the world and leave the pieces alone. Pieces keep their colours in every state by default. Game over is the built-in exception, after play has ended.

The baseline light is a soft key light from the top-left, which matches the gloss highlight on every piece, plus a cool sky fill. Each state pushes away from this baseline and then returns to it.

A game mode or biome can override any of this; see the check in 4.7.

| State | Emotional target | Lighting | Descriptors | Energy (1-5) | Mood carrier |
|---|---|---|---|---|---|
| Calm early campaign | Safe, curious: "I can do this" | Warm late morning, low contrast, soft shadows | sunny, airy, gentle, toy-shelf | 1 | Slowly drifting clouds |
| Rising stack | Focus, momentum | Neutral early afternoon, contrast slightly up | crisp, busy, purposeful | 2 | Ambient particles speed up as the stack grows |
| Danger near height limit | Tension: "fix it now" | Cooler; backdrop darkens and desaturates about 20%. Pieces are unchanged, so they pop more | tight, urgent, pulsing, shadowed | 4 | Pulsing danger-red height line and edge vignette |
| Layer clear | Release, a satisfying pop | Warm white flash along the cleared layer, about 0.3 s | snappy, juicy, bright | 4 (spike) | The layer bursts into confetti in the pieces' colours |
| Level win (3 stars) | Pride, triumph | Golden hour, warm rim light; the backdrop's most saturated look | glowing, generous, celebratory | 5 | Three reward-gold stars stamp in; the mascot cheers |
| Game over | Mild letdown that invites "one more go", not punishing | Dusk, cool, low contrast; pieces desaturate about 50% once play has ended | quiet, wistful, soft, still | 1 | The stack tips over like a toy tower, in slow motion |
| Tournament round | Rivalry, spectacle | Bright "stadium" noon, high contrast; each island rim-lit in its player's colour | loud, showy, competitive | 5 | Islands and banners in player colours |
| Item or debuff hit | Surprise: "something changed!" | A flash of about 0.5 s in that effect's accent colour, on the affected board | sudden, punchy, unmistakable | 4 (spike) | An accent-coloured shockwave ring, then the shell snaps on |
| Menus and shop | Cozy browsing, collectible | Warm indoor lamplight | tactile, inviting, polished | 2 | The biome diorama turns slowly on a toy-shop shelf |

**Defaults for keeping states distinct:**
- Each state leans on one main lever: temperature (calm vs. game over), contrast (rising vs. danger) or a reserved colour (danger red, reward gold, effect accents).
- Each state has its own mood carrier, so states don't blur together.
- Spikes are kept short so they don't hide the board for long (Pillar 2). When states overlap, the danger line stays on top of an item flash by default, because losing is the most urgent information.
- The biome sets the base palette, and the state lighting layers on top of it. In warm biomes such as lava, danger reads through the darkening and the red line rather than through temperature.

## 3. Shape Language

These are defaults. A game mode or biome can override them; run the check in 4.7 when it does.

### Blocks are the hero shapes (Pillar 1)
By default every piece is built from the same unit cube.
- **Bevel:** about 15% of the cube edge, rounded, so a cube still reads as chunky at about 20 px. This is the default set's value; each biome art set picks its own roundness (see **Block art sets** below).
- **Seams:** every cube is a separate object for game mechanics, but neighbouring cubes sit tight together (cube size about 1.03 of a cell, slightly overlapping) so the groove between them is shallow. The piece reads as one toy, and its cube count stays countable for judging fit in 3D. Tight-edged sets add a painted seam line where the modelled groove is too small to see.

### Block art sets (2026-10-09, user decision)
- A **set** is the whole shape bank (67 shapes, Piece Set GDD) built in one look. Each piece is an empty at the pivot cube with one child object per cube.
- The **default set** (`candy_toy`) colours pieces **by family** (one hue per family) with a face motif per shape.
- There is **one art set per biome**. A biome is an **art style only** (block material, texture, edge style, palette); it never changes which shapes exist, so every biome set holds the same full shape bank. Biome styles follow the user's per-biome reference images (`design/art/block-art-sets.md`). Each biome set has a clearly different **cube style** (fat and puffy, medium, tight, or chamfered), its own **details** (for example wood grain and end rings, chipped stone edges, rivets and panel lines, facets, glaze pooling) and its own **material and palette** fitting the biome scene.
- New sets are always made by **copying the default set** and editing the copy; existing sets are never overwritten.
- Materials start from **Poly Haven** (CC0) and **BlenderKit** (free) assets, stylised to the cute reference look; every external asset is logged in the Blender project's `LICENCES.md`.
- **Status effects have their own look (user decision 2026-10-09):** every status is animated, carries a buff/debuff colour pulse and shows its icon. So biome art sets may use any detail from the user's references (cracks, frost and snow caps, icicles, glowing seams, vines and roots, drips, swirls, embers); a status is recognised by its animation, pulse and icon, not by its surface texture. Every cube stays a cube for gameplay.
- **Outline:** a darker tint of the piece's own hue, kept at a constant width on screen.
- **Gloss:** the highlight sits at the top-left by default, matching the key light.

Piece types are told apart in this order:
1. **Silhouette** (the primary identifier).
2. **Face motif:** a small embossed mark on every cube face (dot, ring, bar, cross and so on), in the piece's own tone.
3. **Colour**, which confirms the type.

### Status-effect shells (Pillars 1 and 2)
Shells are surface treatments with a default envelope:
- Shell details stay within about 8% of the cube edge past the base outline, so the silhouette still reads.
- Shells leave the seam grooves and bevel intact, because those show the cube count.

The ideas in references 1 and 2 carry over: vines, cracks, honey, frost and whirlpools. The bulging vine balls and long honey drips get pulled in: drips become short beads, spikes become short nubs, and vines hug the faces. Crumbling can chip corners, kept inside the bevel.

Each shell is made of three things: a surface pattern, a rim in the effect's accent colour, and a small icon badge.

### Islands and environment (Pillar 2)
**By default, gloss plus bevel plus a block-sized cube reads as "block", so we keep that combination for blocks.**
- The environment is matte and painterly, with irregular, organic edges and dark neutral outlines (not tinted to a hue).
- Board tiles are flat, about 1/5 of a cube's height or less, and marked with grid lines.
- Bricks and stones work well as small, matte texture (reference 9).
- The rune cubes around the board edge in reference 10 are the pattern to avoid.
- Props near the board are rounded or jagged rather than boxy.

### Mascots (Pillar 3)
The wizard is a cone hat over a round cloud: two shapes that read at a 48 px icon. The hat carries identity. In multiplayer, each wizard has its own hat emblem as well as its robe colour, so players can be told apart without colour. Wizards stay off the playfield and aren't block-shaped, so they don't read as pieces. They react with big, exaggerated poses, so a trailing player's comeback item reads as a moment.

### UI shape grammar (Pillar 2)
| Shape | Default meaning |
|---|---|
| Rounded-rectangle plate, chunky bevel, flat face | Information (score, next piece, timer) |
| Circle | Consumable item or power-up |
| Pill | Button or action |
| Up / down chevron | Buff / debuff badge |
| Triangle | Hazard or warning |
| Star | Reward |

Biome trim (wood grain, icicles, filigree) stays on frame edges and out of text areas and neighbouring panels.

### Eye order
| Rank | Element | How it earns its rank |
|---|---|---|
| 1 | Falling piece and landing ghost | Motion, highest brightness, glow |
| 2 | Stack and height line | Saturated colour; the line pulses near the limit |
| 3 | Active shells and hazards | Accent colour plus icon |
| 4 | HUD | Screen edges, neutral plates |
| 5 | Mascot | Off the board, small, gestures |
| 6 | Island body | Matte, lower contrast |
| 7 | Backdrop | Lowest saturation and contrast |

## 4. Color System

Everything in this section is a starting default, not a rule. Hex values are first guesses to tune in-engine. A game mode or biome can change any of it (see 4.7).

### 4.1 Effect accents
Default: buff, debuff and hazard each get one bright accent hue, shown with a glow and an icon. Nothing else uses that hue at full strength. This is what makes a clutch item readable at a glance (Pillars 2 and 3).

| Role | Starting hex | Hue | Default backup |
|---|---|---|---|
| Buff | `#1FD3E6` cyan | 186° | Up chevron, rounded shell |
| Debuff | `#E62AA0` magenta | 322° | Down chevron, jagged shell |
| Hazard | `#FF6A13` orange | 22° | Warning triangle, stripes |

We suggest keeping piece and biome hues about 25° or more from buff and debuff, so a status shell never looks like a piece colour. Item icon art can keep its natural colours (a flame is orange). The ring or glow around the icon carries the accent.

### 4.2 Piece palette
Six candy hues to start, one per piece type. Shape tells pieces apart, and colour confirms it. Pieces start softer than the accents (about 45-65% saturation vs. 85% and up), so effects stand out on top of them.

| Lemon | Lime | Mint | Sky | Lavender | Peach |
|---|---|---|---|---|---|
| `#F5DD6A` | `#9FD65B` | `#5DCB9E` | `#6EA4F0` | `#A78BEB` | `#FFB48C` |

There are no pink or cyan pieces, because those hues belong to debuff and buff. The bank has grown to 67 shapes (2026-10-09), so the default set now uses **one hue per family plus a face motif per shape**, and each **biome set uses its own biome palette** (see Block art sets, §3). At higher difficulty, identifying blocks by colour alone is an intended skill.

### 4.3 Semantic colours
| Role | Starting hex | Default use |
|---|---|---|
| Danger | `#F23A3A` | Height line and vignette; pulses |
| Reward / gold | `#FFC83D` | Stars, coins, clears, primary button; paired with a star or sparkle |
| Player red / blue / green / purple | `#D93A4F` / `#3D7BE0` / `#4DB33D` / `#8A4FD6` | Island rims, robes, HUD frames |

Player red and danger red are close in hue, so we tell them apart by behaviour: danger pulses and player red stays steady. Player colours start deeper than the matching piece hues and stay off pieces, so a player's colour is not mistaken for a piece type.

### 4.4 Biome palettes
Starting guidance: backdrops at about 40% saturation or less, one temperature per biome, a clear brightness gap between the board and the pieces, and glowing props a little dimmer than the pieces. Together these keep the playfield reading first.

| Biome | Temperature | Starting colours | Watch for |
|---|---|---|---|
| Grass | Warm-neutral | sky `#8F9AD8`, moss `#7E9C5E`, brick `#A88468` | Moss vs. the lime piece |
| Ice | Cool | sky `#C3D5E6`, tiles `#A9B6C4`, snow `#EEF2F6` | Cyan glows vs. buff; pieces fading into ice |
| Lava | Hot | obsidian `#3A2F35`, ash `#6E625F`, magma `#B5542E` | Background magma vs. hazard orange |
| Celestial | Cool, dark | indigo `#2C2B5E`, nebula `#54488A`, marble `#D6D0E3`, trim `#A8915C` | Trim gold vs. reward gold |

### 4.5 UI palette
Frames take the biome's material. Text plates start from one shared set so text reads the same everywhere: ink `#2E2433`, parchment `#FFF4DE` and white. The primary button starts as reward gold with ink text. The UI can use accents and player colours at full strength, because it sits outside the playfield.

### 4.6 Colourblind backups
Goal: information is never carried by colour alone. Each pair below has a second signal.

| Pair at risk | Type | Backup |
|---|---|---|
| Danger / hazard | Red-weak (protan), green-weak (deutan) | Chevron line and heartbeat audio vs. stripes and triangle |
| Buff / debuff | All types, small sizes | Chevron direction, shell shape, sound sting |
| Lemon / lime / peach; sky / lavender; mint / sky | Protan, deutan, blue-weak (tritan) | Silhouette and face motif |
| Player red / green; blue / purple | Protan, deutan | Hat emblem, screen corner, name label |
| Reward / hazard | Protan, deutan | Star vs. triangle, sparkle sound |

### 4.7 Overriding the defaults
A mode or biome can swap any of these, for example a darker backdrop, a mode-specific accent, or tinted pieces for a minigame. When it does, check that:
1. The pieces still read before the backdrop.
2. Each accent still has its own hue or a clear icon.
3. No new colour collides with the effect colours or player colours on screen at the same time.
4. Every pair still has its colourblind backup; check with a colour-vision simulator.
5. The art bible notes the override.

## 5. Character Design Direction

These are defaults. A game mode or biome can override them; run the check in 4.7 when it does.

### Archetype: the wizard on a cloud
The default player character is a small, kindly wizard sitting on a cloud just off the board: a cone hat, a big beard and a wand. The wizard plays the "toy-box owner" casting pieces into the diorama. That suits Pillar 1, because the blocks stay the stars and the wizard is the hand that plays with them. The cloud keeps the wizard off the grid and gives a plain, soft backing that reads against any biome.

Each biome can dress the same silhouette, for example goggles and brass for underwater (reference 5) or a visor for rune/neon (reference 6). The cone hat and cloud stay the same, so the character is recognisable in every biome.

### Telling characters apart
| Type | Default read | Why |
|---|---|---|
| The 4 multiplayer players | Robe and hat in the player colour, a hat emblem, a fixed screen corner, island rim in the player colour | Colour, shape and position each carry identity on their own (colourblind backup, 4.6) |
| NPC guides | The default grey or biome-costume wizard, no player colour, smaller | Neutral, so they never look like an opponent |
| Living objects | Organic, matte, with eyes and rounded or jagged forms | Alive but clearly not a block |
| Bosses | Large, with a face; built partly from real blocks | See below |

**Bosses made of blocks (reference 12).** By default, a boss is built from blocks only where those blocks are part of play, for example layers the players clear to damage it. Those parts use the full block look (gloss, bevel, tinted outline), because they are blocks. The parts that aren't played with (head, fists, core) are matte, cracked stone with rounded, irregular forms and dark neutral outlines. This keeps Pillar 1 ("everything is built from blocks") and still keeps "anything that looks like a block is a block". In reference 12 the golem's cube-shaped stone head is the part to soften. How boss fights work is still a game-design decision; revisit this default once it is made.

### Expression and pose
Defaults: big and exaggerated, with squash and stretch, and readable as a silhouette alone.
- **Key poses:** idle bob, cast, cheer, dismay, shock and taunt (tournament).
- **Face:** the beard hides the mouth, so the brows, eyes and hat carry emotion. The hat droops when sad and stands up when happy.
- Each pose changes the outline (arms up, hunched, leaning), so it reads at 48 px. This feeds Pillar 3: a trailing wizard's big reaction sells the comeback.

### Detail kept at camera distance
On a phone, wizards default to about 48-80 px tall and bosses to roughly a third of the screen.

| Keep | Drop |
|---|---|
| Hat silhouette, emblem, robe colour | Fabric folds, stitching |
| Brows, eyes, wand glow | Individual beard strands |
| Cloud as one soft shape | Cloud texture detail |
| Boss face and fists | Small cracks and moss on the boss |

## 6. Environment Design Language

These are defaults and starting ideas, not rules; expect them to change as biomes and modes are designed. When a game mode or biome overrides them, run the check in 4.7.

### Floating-island dioramas
By default each board is a floating island shown as a toy diorama, with three layers:
- **Top:** the flat, gridded play surface.
- **Body:** layered strata in the biome's material.
- **Underside:** the biome's signature (roots, icicles, magma drips, crystals).

Biome personality goes mostly into the body and underside, because nothing there touches play.

**Island links (open).** Multi-island layouts (multiplayer, reference 13; linked levels, reference 5) need something joining the islands. One starting idea is physical links: bridges, chains, vines, pipes and stairs. Another is glowing beams, as in reference 5. If beams are used, a muted biome colour avoids confusion with the cyan buff and yellow reward accents. This choice is open.

### Texture philosophy: hand-painted, not PBR
Defaults: hand-painted colour textures with lighting and ambient occlusion baked in, simple stylised shading, and matte surfaces.
- **Style:** it matches the painterly references.
- **Performance:** fewer texture maps and cheaper shaders suit mobile.
- **Readability:** with no specular noise, gloss stays special to blocks (Principle 1).

Texture detail is low-frequency (broad strokes, few small marks), and gets quieter near the board.

### Prop density by zone
| Zone | Default density | Why |
|---|---|---|
| Grid and a one-cube margin | None, only flat tiles | Nothing near the play edge competes with pieces |
| Island rim | Sparse, small and low, at the corners | Frames the board without blocking it |
| Island body and underside | Medium to high | Where the biome's flavour lives |
| Mid-ground islands | Medium, desaturated | Depth without noise |
| Backdrop | Large, simple shapes, slow motion | Quiet World (Principle 2) |
| Menu and shop dioramas | High | No play to protect |

Check rim props from every rotate-view angle, so none of them hide the grid.

### Reading characters against the environment
By default, the space behind a wizard's cloud is low-detail sky or backdrop, and props aren't placed behind characters. The cloud gives a plain backing. Bosses get a darker or simpler backdrop zone behind them.

### Storytelling without text
Each biome tells its story through four default channels:
1. **Island underside:** what the place is made of.
2. **One background landmark:** a volcano, a sunken ship, a giant tree.
3. **The mascot's costume.**
4. **Change across the 10 tiers:** the landmark gets closer, or the island gets more weathered or more overgrown, so progress shows without words.

The 10 biomes aren't named yet; the references suggest grass, ice, lava, forest, celestial, underwater and rune/neon. This section gives a method, and per-biome specs follow once game design names the biomes.

## 7. UI/HUD Visual Direction

These are defaults. A game mode or biome can override them; run the check in 4.7 when it does. Visual direction comes from art direction; the layout and accessibility notes come from the UX check. Detailed layout belongs to `/ux-design`.

### Starting decisions
- **Orientation:** landscape by default, which matches every reference and leaves room for the board, side mascots and multiplayer. Revisit after the touch-controls prototype.
- **Items vs. controls:** items go on the opposite thumb from rotate and drop, so a mis-tap never wastes a clutch moment. A left-handed mirror option swaps the sides.
- **Text on frames:** text sits on a parchment insert inside the themed frame, so it reads the same in every biome. The dark rune/neon biome keeps parchment by default; a dark plate with light text there would be a logged 4.7 override.

### Diegetic vs. screen-space
| Element | Default | Why |
|---|---|---|
| Score, next piece, items, timer | Screen-space, in themed frames | Stays readable and steady when the view rotates |
| Height limit, danger | In the world, on the board | Players read it where the danger is |
| Player identity | Both: island rim in the world, plus a HUD frame | Two signals, one colourblind-safe |
| Status effects | Shells in the world, plus a HUD badge (chevron and icon, not just a glow) | Easy to see on the board, confirmed in the HUD |
| Mascot reactions | In the world | Characters carry the mood |

### Layout zones (UX defaults)
- Information plates along the top edge. Controls in the bottom thumb arcs. The board's touch area stays free of HUD.
- Everything, trim included, stays inside the safe-area insets (notch, rounded corners, home indicator).
- Touch targets are at least 44 pt (iOS) / 48 dp (Android). In-play buttons (drop, rotate, items) are 56-64 pt with at least 8 pt between them. Decorative trim doesn't count toward a target's size.
- **Next-piece preview:** the real 3D piece in its spawn orientation, seen from the gameplay camera angle, in a plate of at least 64 pt. A flat 2D icon doesn't help plan a 3D rotation.

### Typography
- **Display font** (score, titles, numbers): a rounded, heavy, friendly sans with an ink outline or drop shadow, as in the references. Chunky and toy-like, matching the block bevel.
- **Body font:** a clean rounded sans in semibold, for menus, descriptions and the shop.

| Level | Use | Weight | Starting size |
|---|---|---|---|
| H1 | Win/lose banners, round titles | Black | 32-40 pt |
| H2 | Score, timer | Extra-bold, fixed-width digits | 24-28 pt |
| H3 | Labels ("NEXT", player names) | Bold | 14-16 pt |
| Body | Descriptions, shop | Semibold | 14 pt |

The UX minimums are 12 pt for any text and 18 pt for HUD numbers. Fixed-width digits keep the score from jiggling, and plates grow as digits are added.

### Iconography
Small painterly props such as a bomb, flame, snowflake or star, each with one ink outline, two tones plus a highlight, and fitted to its UI container shape (circle for items, chevron badges for buff and debuff). Icons should read as a silhouette at about 32 px. The next-piece preview shows the real piece; other icons avoid block shapes so they don't read as pieces.

### Animation feel
Springy toy behaviour:
- **Pop-in:** overshoot to about 110%, then settle.
- **Press:** a quick squash.
- **Score:** ticks up.
- **Timing:** about 150-250 ms during play, so the UI never holds up the board. Menus can be slower and more playful.
- **Reward moments:** stars stamp in with a bounce.

Frames themselves stay still during play. Twinkling, flickering or sparking edges would pull the HUD above its place in the eye order.

### Biome-themed frames
| Frame | Default biome | Trim |
|---|---|---|
| Wood | Grass, forest | Grain, nails, vines |
| Ice | Ice | Frost edge, short icicles |
| Stone | Lava | Chipped edges, ember glow |
| Rune/neon | Rune biome | Glowing line trim |
| Marble and gold | Celestial | Filigree, sun and moon ornaments |

- Trim changes per biome; the plate interior stays parchment and ink.
- Trim (icicles, vines, drips) stays under about 10% of plate height and points away from the board and the controls.
- Each frame gets a dark neutral outer edge, so ice-on-ice or marble-on-nebula frames don't vanish into the backdrop.

### Readability and accessibility
- A HUD scale setting from 100% to 150%, with plates reflowing rather than clipping. Menus follow the system text size.
- Player plates show the hat emblem and a name the player chooses, not colour alone.
- Combined flashes stay at 3 per second or fewer, so stacked item hits are throttled.
- A reduce-flash/motion toggle swaps flashes for a steady accent rim on the board edge, turns off screen shake and slows the danger pulse.

### Best avoided
- Rotated or vertical text, and the same banner repeated across the screen.
- Glow halos in player colours behind plates, which compete with the effect accents.
- Information shown as circles, which reads as a tappable item (the "FIRE!" pop-ups in reference 13).
- Trim that looks like a button, and text placed directly on textured surfaces.

### Open for game design
The 4-player view on one phone is cramped. In reference 13 each board takes about 15% of the screen, which puts cubes well under the 20 px bevel read, and four people can't share 3-axis touch controls on one phone. Options are pass-and-play turns, one device per player, or tablet-only for 4 players. This is a game-design decision.

## 8. Asset Standards

**Starting assumptions, all open to change:** no engine is configured yet. We're assuming Godot 4.x with the Mobile renderer, aiming for 60 fps on mid-range phones (Adreno 6xx / Mali-G7x). Every number below is a starting target from the technical artist, not an approved budget, and is meant to be tuned once we can profile real builds. Godot API names are from memory and are worth checking once the engine is set up (`/setup-engine`). If a mode or biome wants something different, the suggested route is the 4.7 check plus a quick performance check.

### Formats and pipeline (suggested)
- Model in Blender and export `.glb` (glTF 2.0). Suggested scale: 1 unit = 1 cube edge, transforms applied, so pieces snap to the grid.
- Textures: lossless PNG source, compressed by the engine on import.
- Keep painted source files at about 2x the shipped resolution, so we keep room to re-export at higher tiers later.

### Naming (suggested pattern)
`prefix_scope_name_variant`, plus a map suffix (`_alb`, `_nrm`, `_msk`). Godot import suffixes (`-col`, `-noimp`) go last.

| Prefix | Example |
|---|---|
| `blk_` | `blk_cube_base.glb` |
| `shl_<effect>` | `shl_frost_cube_a.glb` |
| `env_<biome>_` | `env_lava_island_main_alb.png` |
| `prp_<biome>_` | `prp_ice_crystal_01.glb` |
| `chr_` | `chr_wizard_cast.glb` |
| `ui_` | `ui_lava_frame_score.png` |
| `vfx_` | `vfx_confetti_burst.png` |

### Budgets
No polygon, texture or draw-call budgets for now (removed 2026-10-09 by decision). Build for the look first; profile real builds on device and set budgets only if performance needs them.

### Materials, LOD and VFX (starting approach)
- **Shaders:** a small shared set of about five (block, shell, environment, particle, UI). Toon ramp, one directional light, gloss as a step or matcap term.
- **Rendering blocks:** one MultiMesh per board per mesh type (base cube plus each shell type), sharing one block material, so a full board costs a few draw calls instead of hundreds.
- **New looks:** suggested via atlas entries and per-instance parameters (hue, motif, effect ID) rather than one-off materials, which tend to cause compile hitches. Mood states (Section 2) can use the same shared parameters.
- **Outlines:** inverted-hull outlines on blocks, tinted per piece; post-process edge detection is costly on phone GPUs and can't tint per piece.
- **LOD:** none planned for blocks to start, since they're always the hero; auto-generated mesh LOD is best turned off on block and shell imports so it doesn't eat the bevels. Backdrops can be painted cards. A lighter quality tier for the four-board view is suggested.
- **Particles:** starting targets of about 150 confetti per clear and about 500 alive, roughly halved with four boards. The shockwave can be a ring mesh with a shader rather than particles.

### Trade-offs: current starting picks
Each trade-off has a starting pick, chosen 2026-10-08, to revisit once real builds can be profiled on a phone.

| # | Trade-off | Starting pick | Alternative kept open |
|---|---|---|---|
| 1 | **Seams:** modelled grooves read from every angle; normal-map grooves cost 3-5x fewer tris but flatten at grazing angles and at about 20 px | Normal-map seams plus a thin painted seam line in the mask | Modelled grooves |
| 2 | **Face motif at four-board size:** it is the colourblind backup (4.6), but adds clutter and cost when tiny | A bolder, simpler motif in the four-board tier | Drop the motif in that tier |
| 3 | **Honey and frost:** real translucency gives depth but adds overdraw on phone GPUs | Opaque material with a fake rim (the candy pieces in reference 9 already read well opaque) | Real translucency |
| 4 | **Environment outlines:** live outlines match the blocks; painted outlines are cheaper but leave island edges unlined against the sky | Live outlines on the few large island meshes only; painted outlines elsewhere | All painted, or all live |
| 5 | **Painted light vs. rotate-view:** strong painted light looks richest, but after a rotation the shadows sit on the wrong side | Soft top-down painted light with ambient occlusion | Per-angle variants (more memory). If the light turns with the camera, this trade-off goes away; to confirm with game design |
| 6 | **Compression:** ETC2 has the widest support but bands on soft skies and parchment | Uncompressed UI atlas (about 16 MB) plus sky gradients drawn by a shader | ASTC where supported |

Still to set: targets for bosses, living objects and the character texture (technical artist).
## 9. Reference Direction

These are starting references to take from loosely, not templates. Each one points a different way, and the list can grow or change.

| Reference | Points toward | Suggested take | Suggested to avoid |
|---|---|---|---|
| **Captain Toad: Treasure Tracker** | Level composition | Each level is a self-contained diorama read from a fixed angled camera, with cut-away sides that show its strata | Nintendo's character shapes and block icons, and its loud-everywhere saturation (our world aims quieter) |
| **Tetris Effect** | Mood without touching the pieces | The matrix stays readable while the world, light and particles carry each zone's mood; a layer clear lands as a burst | Its dark, neon-on-black, synesthetic look; we lean daylight toy box |
| **Overcooked** | Multiplayer readability | Chunky, low-detail characters that read at small size; player identity at a glance in a crowded shared view | Its chef and animal designs and its top-down framing |
| **Kazuo Oga's gouache backgrounds** (My Neighbor Totoro) | Backdrop painting | Soft, low-contrast skies and clouds; distant shapes fade into the sky; broad brush strokes | Realistic detail and dense foliage; ours leans simplified and toy-like |
| **Tilt-shift toy photography** | Material and light | Pieces that feel like real toys on a table: plastic and candy gloss, painted-wood props, a soft "miniature" haze on far planes (painted rather than real-time depth of field) | Photorealism (our anti-pillar) |

### The user's 13 images
These are loose mood references. Together they suggest the painterly cartoon finish, chunky glossy blocks, floating-island boards, biome-themed frames and the wizards on clouds. They're inspiration rather than specs, and they aren't meant for tracing or shipping. Where they differ from this bible's starting defaults, the defaults are the suggested starting point, open to revisiting through a 4.7 override:
- ice-tinted pieces (8)
- galaxy-skinned pieces (10)
- rune cubes around the board (10)
- links in accent colours (5)
- sphere and gem pieces (3)
- repeated banners and circular info pop-ups (13)
