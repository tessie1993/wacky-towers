# Art Direction Review: Minigame and Party Mockups

> **Status**: Draft for user decision
> **Author**: art-director
> **Date**: 2026-10-13
> **Inputs**: all 34 images in `assets/art/reference/` (20 sheets in `minigame_mockups/`, 7 top-level PNG, 7 top-level JPG); `design/art/art-bible.md`; `design/art/block-art-sets.md`; `src/ui/common/wt_storybook.gd`; `src/view/wt_island_builder.gd`; `assets/data/biome_looks.json`.
> **User decision this builds on**: minigames are reusable building blocks inside campaign levels, reskinned per biome. They also run as random head-to-head tournament rounds.

All hex values below were read **by eye** from compressed JPGs. Treat them as starting points. Confirm them with a colour picker on the source PNGs and tune them in-engine.

---

## 0. How the references sort (which ones to trust)

The 34 images fall into four style families. They don't agree with each other, so the first job is choosing which family is canon.

| Family | Images | Verdict |
|---|---|---|
| **A. Storybook toy (canon)** | `title_screen_ref.png`, `screens_flow_ref.png`, `title_variants_ref.jpg`, `wizard_turnaround_ref.png`, `tournament_flow_ref.png`, `biome_block_materials_ref.png`, `underwater_biome_sheet_ref.png`, `volcanic_biome_sheet_ref.png`, `logo_ref.jpg`, mockups 12-16, 18-20 | **Follow.** Soft painterly 3D, chunky wood with parchment, cuddly chibi characters, lilac shadows. This family matches the bible and the shipped storybook UI. |
| **B. "Mobile midcore" painterly** | mockups 01-11, `biome_screens_ref.jpg` | **Mine for content, not style.** Good minigame ideas, props and meter types. But the characters are taller and more realistic (3.5-4 heads), the HUD uses dark slate glass plates, and lighting is high-contrast everywhere. That breaks "Quiet World, Loud Board". |
| **C. Flat vector / Tetris-like** | `party_modes_ref.jpg`, `party_minigames_ref.jpg`, `party_versus_ref.jpg` | **Mine for layout only.** Flat cubes, classic 7-tetromino shapes and guideline colours, flat UI. Wrong finish and an IP risk (see section 4). Useful for split-screen versus layouts and the head-to-head HUD. |
| **D. Off-brand / third-party IP** | `party_biome_islands_ref.jpg` (Nintendo characters), mockup 17 "Quantum Spire" (gritty realistic sci-fi metal) | **Do not use.** Section 4 lists the actions. |

---

## 1. Style guide distilled from the mockups

### 1.1 Palette per biome

These are scene palettes for backdrop, island and props. Block palettes stay in `block-art-sets.md`. Columns run from deepest to lightest, then the accent. "Watch" names the bible collision to manage.

| Biome | Sky / backdrop | Island body | Board tiles | Signature accent | UI paint (frame / edge) | Watch |
|---|---|---|---|---|---|---|
| **Meadow** | `#8EC9F0` -> `#D9EEF8` -> cream `#F7F1DE` | grass `#7DBF4E`, soil `#8A5A36`, root dark `#5E4630` | stone `#E2D8C3` | daisy white, lilac flower `#B9A0E0`, clover `#5FA03A` | honey wood `#B07A45` / vine green `#6E9A4A` | Clover vs. the lime piece |
| **Candy** | pink-lilac `#F6D9EC` -> `#FFF3F8` | sponge `#C98B4F`, icing `#FFF1F4`, chocolate `#6B3B2A` | wafer `#E2B270` | peppermint red `#E04848`, lollipop swirl | pastel pink `#F2B6C8` / mint `#9ED9C0` | Hot pink sits close to debuff magenta (322 deg). Keep icing pinks at 345 deg or more, or lighter than 80% value |
| **Ice** | `#C9DDF0` -> `#EEF3F8` | snow `#F2F6FA`, glacier `#A9CDEB`, shadow lilac `#B9B5DD` | frosted tile `#D6E2EE` | snowflake white | pale blue-white `#E4EEF6` / deep teal `#3F7F99` | Glacier cyan glow vs. buff `#1FD3E6`. Keep ice desaturated (40% or less) |
| **Underwater** | deep `#1E4F7A` -> `#3E86A8` -> god-ray `#9FD3E0` | rock lilac `#6B5E8E`, kelp `#5E7F3E`, sand `#E8DCC0` | pale coral tile `#EDE3CC` | nacre lilac `#A99BE0`, pearl `#F1ECF7`, coral `#E08AA6` | sea green `#4E8F7A` / coral `#E08AA6` | Bioluminescent cyan in the mockups collides with buff. Use the production sheet's soft lilac/teal instead |
| **Lava (Volcanic Isles)** | lilac haze `#CFC2D8` -> ash `#8E8395` (production sheet), not the mockups' orange skies | obsidian `#2E2A33`, ash `#6E625F` | slate tile `#4A4550` | crack glow violet/blue `#7B5BC7` on blocks; magma `#E8682A` **only on the underside and in the distance** | charred brown `#4A3326` / iron `#2A2628` | Mockups 01, 02, 14 and `biome_screens` show orange glowing crack-blocks, which is hazard orange. The volcanic sheet's violet glow is the fix |
| **Forest** | sage mist `#BFD3B0` -> `#E8EEDC` | bark `#7A4F2E`, moss `#6E9B3A` | end-grain wood tile `#D9A86A` | leaf `#79B84A`, acorn | dark oak `#5B3A24` / moss `#6E9B3A` | Moss vs. lime piece |
| **Crystal Cave** | `#2E2B45` -> `#5C5868` (cool, dark) | slate `#5C5868`, light slate `#8A8597` | flagstone `#7E7A8C` | amethyst `#9A6FD6`, lantern amber `#F0B25A` | slate `#4E4B5C` / crystal violet `#9A6FD6` | Amber lantern vs. reward gold. Keep it dimmer and oranger (`#E09A50`) |
| **Clockwork** | warm smoke `#C9B49A` -> `#EADBC4` | walnut `#5B3A24`, copper `#B86A3C`, iron `#4A4A52` | riveted plate `#8C8C94` | brass `#C8963E`, navy enamel `#2E4170` | walnut / brass | Brass vs. reward gold. Brass must stay browner (`#B88A3A`, 50% sat) than gold `#FFC83D` |
| **Neon** | navy `#1E1A4A` -> indigo `#3A2C8A` | dark panel `#2A2550`, trim `#4A4290` | grid tile `#2E2A60` with lines | glow lime `#9CF04A`, glow violet `#A070FF` | navy / flat paint pink and cyan (bible) | Every mockup uses cyan and magenta glow, which are the buff and debuff hues. Neon must pick lime, violet and amber glows, or the user moves the status accents |
| **Celestial** | deep violet `#2C1F5E` -> nebula `#6A4BB0` | marble `#E9E2EE`, vein lilac `#C8B8E0` | marble tile `#EEE8F2` with gold border | star cream `#F6E7B0`, trim gold `#C9A85A` | cream / gold | Trim gold vs. reward gold (already flagged in the bible) |
| **Tumble Fair** (side island) | dusk lilac `#B49AD0` -> lantern warm `#F7D9A8` | painted boards `#8A5A34`, tent red `#C8424E` | checker tile cream/pink | stripe pink `#EE6A8C`, cream `#FBEFD8`, ticket red | red-brown wood / bunting | Stripe pink vs. debuff |
| **Dune Bazaar** (side island) | `#F2D9AC` -> `#FBEBD0` | sandstone `#E9C99A`, terracotta `#C77A3E` | tiled `#E8D2A8` | teal glaze `#3E9A9A`, brass knob | sand / teal | Teal glaze vs. buff cyan. Keep it at 175 deg or lower and 45% saturation |

**Minigame environments map onto biomes; they never become new biomes.** Under the user's decision, every scene in mockups 01-20 is a reskin of a campaign biome:

| Mockup scene type | Host biome |
|---|---|
| Grass cliffs, castles, catapults, sheep, gnomes, balloon race | Meadow |
| Cake, donuts, lollipops, gingerbread, rails, candy dodger | Candy |
| Avalanche, iceberg sumo, glacier rush, penguins | Ice |
| Coral conduit, submarine salvage, kraken, bubble build | Underwater |
| Volcano dash, lava rumble, rubble rumble, prehistoric nest | Lava |
| Jungle temple, idol, vines, giant ape, ancient ascenders | Forest (jungle variant; see the open question in 2.10) |
| Mines, gem grab, digging frenzy, maze heist | Crystal Cave |
| Gears, conveyors, airships, steampunk gear-up | Clockwork |
| Laser hack, neon maze, cyber defender, gravity goal | Neon |
| Wormhole, galactic grab, chroma sky climb, magnetic mash | Celestial |
| Fair, spin wheel, tournament lobby | Tumble Fair |
| Pyramid climber | Dune Bazaar |
| Pirate ships, treasure, tiki, tropical island, fruit stack | **Not covered by any biome.** See 2.10 |

### 1.2 Materials

Blocks are the only glossy, saturated material (Principle 1). Everything else is matte and painterly. The look of each material as it appears in the references:

| Material | Where | How it reads | Build rule |
|---|---|---|---|
| **Glossy jelly / gummy** | Candy blocks, gummy bear, jelly props | Lit from inside, deep colour at the bottom, white window highlight at top-left, faked subsurface | Blocks only: fake inner glow (inverted fresnel). No real transparency (bible trade-off 3) |
| **Icing / frosting cap** | Candy cake cube, island rims | Thick, rounded drips, cream-white with a pink shadow | Drips stay short (bible §3) |
| **Frosted glass / glacial ice** | Ice blocks, ramps, minigame ice cubes | Pale blue body, white frosted edges, snow cap with icicles, inner sparkle | Opaque with a faked rim. Snowflake motif on the hero cube only |
| **Pearl / nacre** | Underwater blocks (production sheet) | Deep blue-violet glassy body, iridescent rim, pearl beads at the corners, shell emblem, kelp twist on the edges | Corner pearls stay inside the 5% raised-detail limit |
| **Lava rock / obsidian** | Lava blocks and island | Faceted charcoal stone, cracks glowing violet-blue on blocks and orange on the island underside only | Never orange cracks on blocks (hazard accent) |
| **Galaxy / cosmic** | Celestial blocks, chroma sky climb | Deep violet with nebula swirl, cream four-point stars | Stars are cream, never reward gold |
| **Brass and enamel** | Clockwork blocks, timer gear ring, UI corners | Polished brass frame, rivets, navy enamel inset, embossed gear | Brass is browner than reward gold |
| **Painted wood** | All UI frames, hub stage, signs, catapults, carts | Chunky planks, visible straight grain, darker rounded edges, iron nails or bolts at the corners | Grain runs along each plank so nine-patch edges can stretch |
| **Parchment** | Every UI interior | Warm cream, faint fibre noise, slightly darker at the edges | Flat centre. Text never sits on texture |
| **Turf over soil** | Meadow blocks and islands | Grass cap with a fringe, soil band, pebbles, clover | Already in `biome_looks.json` (`cap_drip`) |
| **Bark / end grain** | Forest blocks | Bark sides, growth rings on top, moss patches | As in `block-art-sets.md` |
| **Slate with crystal** | Cave blocks and island | Chunky stone, small amethyst inclusions, crystal cluster as the hero prop | — |
| **Neon glass** | Neon blocks | Dark glassy body, glowing circuit lines | Glow hue rule in 1.1 |
| **Sci-fi metal** | Mockup 17, galactic panels | Grimy realistic panels and greebles | **Reject.** If space needs metal, use toy-like painted tin from the Clockwork language |

### 1.3 Island silhouettes

Every board is a floating island built in the same three layers (bible §6). The references add these rules:

1. **Top:** a near-square cushion. The superellipse is about 5, which `wt_island_builder.gd` already uses. The rim is soft and lumpy (bushes, snow, icing) and rises slightly above the tile level. The tile grid inset is pale and flat with thin grooves.
2. **Body:** the strata thicken toward the centre, and the cliff face is about 0.6-0.9x the board width tall.
3. **Underside:** an **inverted cone or spike** (volcanic, underwater) or a **ragged root mass** (meadow, forest), in proportion about 1:1 to the body. The underwater sheet adds a stepped "shell spiral" cone. Lava drips glow orange here, and only here.
4. **Silhouette variety per biome** comes from the rim (icicles, icing drips, crystal spikes, coral) and the underside. The footprint stays almost square, so camera framing doesn't change between biomes.
5. **Floating debris:** two to six small rock chunks orbit lava, celestial and ice islands. They are matte and slow-moving.
6. **Hub and multi-island layouts** (mockup 16, mockup 18): a central wooden stage island joined to minigame islands by **rope-and-plank bridges**. In the mockup the bridge rails glow cyan, which the bible forbids, so the rails should be plain rope or a muted biome colour.
7. **Minigame islands** can grow non-square tops: race tracks (balloon race), maze footprints, rings (lava rumble). Keep the strata and underside language so each reads as "a Wacky Towers island".

### 1.4 Character proportions

| Measure | Canon (family A: wizard turnaround, mockups 19/20, tournament) | Reject (family B) |
|---|---|---|
| Head count | **2.2-2.6 heads tall**, including the hat or headgear | 3.5-4 heads |
| Head width | About 45% of total height (with beard/hair mass) | Realistic |
| Hands and feet | Oversized mitten hands, stubby boots | Realistic |
| Eyes | Large and oval, glossy black with one white catch-light, set low on the face | Small, detailed |
| Faces | Button nose (pink or peach), big rosy cheeks, simple brows | Wrinkles, stubble |
| Surface | Soft felt/clay, smooth, almost no texture | Detailed cloth, metal wear |
| Outline | Soft dark tint of the local colour (as on blocks), never black | Black ink |

**In-world scale:**
- Seated wizard on a cloud: about 1.2 cubes tall, off-board (bible).
- Standing minigame avatar: **about 1.4 cubes tall**, so a character beside a 1x1 cube reads like a child next to a toy box (as in mockups 19 and 20).
- Portraits are framed head-and-shoulders.

### 1.5 Lighting

- **Key:** soft and warm from the top-left, matching the gloss window on blocks.
- **Fill:** cool lilac sky. Shadows lean lilac (`#B9A9D6`), never grey.
- **Contact:** a soft lilac blob under pieces and characters.
- **Family A reads as midday-to-golden-hour with low contrast and gentle haze on far islands.** Family B's dramatic lightning, storms and full-orange lava skies are too loud. Use them only as mood-state spikes (danger, boss), and darken the backdrop rather than saturating it.
- **Tournament fair** (`tournament_flow_ref.png`): dusk with warm lantern bokeh behind parchment panels, a good "menus and shop" lamplight state.
- **Dark biomes** (Cave, Neon, Celestial): add a thin cool rim light on blocks and characters so silhouettes separate from the backdrop.

### 1.6 UI chrome

The canon UI is **painted wood framing parchment, with plum ink**, already implemented as `WtStorybook` (`PLUM #3b2346`, `PARCHMENT #fbf1dc`, `WOOD #8a5a34`, `GOLD #f7c548`, Fredoka). Each piece below is described as the references show it:

| Piece | Reference | Form | Notes |
|---|---|---|---|
| **Wood/parchment plaque** | 12-15, `screens_flow`, `tournament_flow`, volcanic sheet | Rounded rectangle, 2-plank-thick wood rim (about 10% of the short side), darker edge bevel, 4 corner nails/bolts, parchment inset | The base of every panel, card and goal card |
| **Goal/mission card** | 12-15 bottom right | Parchment strip with wood rim, H3 title plus small caps goal line | Nine-patch plaque, smaller |
| **Ribbon banner** | 12-15 ("PARTY BATTLE"), `party_modes`, tournament | Red cloth ribbon, folded swallow-tail ends, cream text with plum outline, slight arc | One per screen at most (bible "avoid repeated banners") |
| **Wooden sign banner** | 16 ("BRIDGE BUILDERS", "LAVA ESCAPE") | Single plank with notched (arrow) ends | Good for island labels in the hub. Diegetic |
| **Gear-ring timer** | 12-15 top centre, `tournament_flow` round pick ("3") | Wooden disc with a brass rim, 2 small brass cogs on the left and right shoulders, parchment face, H2 digits | Circle-shaped info: see 2.5 |
| **Portrait score card** | 12-15 | Wood plaque with a square portrait well on the left; SCORE label, big number and lives hearts on the right; **player tab** (P1-P4) in the player colour sitting on top | Hat emblem goes on the tab |
| **Player tab** | 12-15, tournament | Small rounded flag in the player colour with "P1" and an emblem, overlapping the card's top-left | Must carry the emblem, not just colour |
| **Next Block box** | `screens_flow` (canon), 12-15 "NEXT ITEM/AMMO/RAMP", 19/20 | Square wood frame, deep parchment well, H3 label above. Contents: **the real 3D piece**, or a prop icon for minigame items | Mockups 01-11 show flat 2D tetromino icons. Reject those (bible §7) |
| **Piece tray** | `screens_flow`, `title_variants` | Wide parchment tray with a biome trim frame, 3 slots split by wood dividers | Campaign HUD bottom |
| **Square icon button** | `screens_flow` (pause), 18-20 (gear, clock), `title_screen` (settings) | Rounded square, cream or wood, chunky lip | |
| **Pill button** | `title_screen` PLAY/BIOMES, tournament READY | Gold primary with star icon; cream secondary; thick darker lip under the face | Already in `WtStorybook.pill_button` |
| **Thermometer meter** | 01-11 ("Heat", "Altitude", "Stability", "Oxygen") | Vertical glass tube, bulb at the bottom with an icon, gradient fill, % ticks | Re-skin in wood/brass; colour rules in 2.6 |
| **Horizontal bar** | 02 "Fort HP", 04 "Boss Health Bar", 07 "Hull Integrity", `party_versus` "Stability Meter", 11 "Castress Health" | Rounded bar in a frame, gradient or solid fill, label above | Boss HP needs a boss face cap at the left end |
| **Speedometer gauge** | 11 "Speed" | Semicircle dial, rainbow arc, needle | Rare. Build only if a minigame needs it |
| **Preview stack** | 07 "Preview" (3 queued) | Vertical column of 3 small slots | Useful for queued pieces |
| **Minimap** | 02 "Maze Heist" | Square framed inset | Only for maze minigames |
| **Live leaderboard** | 03 | Ranked rows with portrait coin and score | Use parchment rows (tournament standings style) |
| **Spin wheel** | `tournament_flow` round pick | Wooden wheel with 3 parchment wedges, brass hub, pointer at the top, reroll lantern sign | Tournament round pick |
| **Map pin / speech bubble** | 19, 20 (balloon race) | Rounded-square bubble with a tail, portrait inside, player-colour fill | Tournament map and race progress |
| **Block-set tray** | 19, 20 | Wood tray with a 2x3 grid of material swatches | Skin picker |
| **Bunting** | 12-15, tournament | Triangle flag string across the top edge | Decoration. Must stay above the safe area and under 10% of screen height |
| **Lives hearts** | 12-15 | Red glossy hearts, with dark empty hearts | See 2.6 |
| **Logo lockup** | `logo_ref`, `title_screen`, 15, 16, 18 | Chunky wooden letters on a dark plank sign with vines and daisies; "PARTY QUEST" / "PARTY MODE" on a red ribbon below | Needs one canonical lockup (2.9) |

**Text:** Fredoka 600/700, plum ink. Titles use cream fill with a plum outline and a soft drop shadow. Numbers have a fixed width (bible §7).

---

## 2. Gaps vs. the art bible (where the bible must change)

Each gap names the bible section, what the references show, and a recommendation. **All of these are user decisions.** The recommendation is marked.

### 2.1 Orientation (bible §7: landscape by default)
The campaign references (`screens_flow`, `title_screen`, `title_variants`, mockup 15, `party_versus`) are **portrait**. The minigame sheets 01-14 are landscape.
- **Option A (recommended):** portrait for campaign and solo minigames, landscape for local multiplayer. One-handed phone play favours portrait.
- **Option B:** landscape everywhere (bible as written).
- **Option C:** portrait everywhere, with split-screen versus stacked vertically (`party_versus` style).

The bible §7 "Starting decisions" and the HUD layout zones need rewriting for whichever option is chosen.

### 2.2 The character cast (bible §5 covers only the wizard)
The bible defines one archetype: the wizard on a cloud, kept off the board. The user has a **nine-character roster**, and minigames show characters **walking on islands, carrying blocks, riding carts and firing catapults**.

The bible needs:
- A **cast section** with proportions (1.4 above).
- **Two body modes:** "cloud mode" (seated, off-board, in puzzle levels) and "avatar mode" (standing, on-island, in minigames).
- A rule that avatars are matte felt/clay and **never block-shaped**, which matters most for the robot.
- A per-character silhouette hook (3.3).

Bible §3 "Wizards stay off the playfield" must become: "Characters stay off the **puzzle grid**. In minigames they may stand on the island but never occupy a grid cell as if they were a piece."

### 2.3 Player identity emblems
The references contradict each other:
- `wizard_turnaround_ref` uses **circle / triangle / diamond / club**.
- `tournament_flow_ref` uses **circle / triangle / square / star**.

Bible §4.6 relies on emblems as the colourblind backup.
- **Recommended:** circle / triangle / square / star (the tournament set). These are simpler at 24 px, and the star is already shown as P4's emblem.
- **Conflict:** the bible reserves the star for reward. The alternative is circle / triangle / square / **diamond**, which leaves the star exclusive to reward. I lean to diamond for that reason. User call.

Non-wizard characters wear the emblem as a **badge** (pirate hat cockade, astronaut shoulder patch, robot chest light, penguin bow tie, and so on), not on a cone hat.

### 2.4 UI frame material (bible §7: "painted wood, one set per biome")
- **Underwater sheet:** the frames are **kelp rope with shells and coral**, not wood.
- **Mockups 01-11:** dark slate glass plates with player-colour borders.
- **Mockups 12-15, 18-20, the tournament and the volcanic sheet:** wood.
- **Recommended:** keep painted wood as the base everywhere and reject the slate plates (generic and off-brand). Allow **biome trim decals** like kelp, shells, icicles and vines **wrapped onto** the wood, as the underwater sheet does, within the bible's 10% trim limit.

The bible should add a technical rule that trim is a **separate overlay sprite** on the corners, not baked into the nine-patch. One nine-patch base can then serve every biome (3.1).

### 2.5 Circle-shaped information: timer and portrait medallions (bible §3 UI grammar and §7 "Best avoided")
The bible says circle = consumable item and "information shown as circles" is to be avoided. The references use a **round gear-ring timer** (12-15, tournament) and **round portrait medallions** (`party_versus`, mockup 09).
- **Recommended:** add a named exception. The **gear ring** (brass cogs on the rim, no button lip, no drop-shadow press depth) is the one round info shape, reserved for the timer and countdown. Portraits stay **square-in-wood** (the 12-15 score cards), not circular.

### 2.6 Meters (absent from the bible)
Minigames depend on meters: thermometer (heat, altitude, oxygen, pressure), stability bar, boss HP, progress (n/12), lava rise. Every mockup paints them as **green-to-yellow-to-red gradients** with a **red bulb**, which raises two problems:
1. Red-green carries the meaning alone (bible §4.6).
2. The red end and the boss bar collide with **danger red `#F23A3A`**.

Rules to add:
- **Fill colour by meaning, not traffic light.** Good resources (oxygen, stability, own progress) fill in the player colour or a neutral teal-green. Threats (heat, lava rise, topple risk) fill in hazard orange. Only the final 15% turns danger red, **and it pulses**.
- **Every meter carries an icon cap** (flame, bubble, balance scale, skull-free boss face) **and tick marks.** A threshold chevron marks the danger zone, so colour is never the only signal.
- **Boss HP** is horizontal, top centre, with a boss portrait cap. The fill is a **plum-to-violet** boss colour, not red.
- **Lives hearts:** use a warm rose `#E8566A` (about 352 deg, 30 deg from debuff). Empty hearts are a dark outline, not grey, plus shape (a full heart vs. an outline only).
- Fills are drawn in-engine (a shader or `TextureProgressBar`), so a meter frame is one PNG and the fill is not baked.

### 2.7 Player colours (bible §4.3: red / blue / green / purple)
Mockups 12-15 use **P3 yellow** and repeat red for P1 and P2. Yellow collides with reward gold. **Recommended:** keep the bible's set, which `tournament_flow_ref` also uses. No change to the bible, but `wt_storybook` tabs must follow it.

### 2.8 Glow budget and accent collisions (bible §1 Principle 3, §4.1)
The references glow a lot:
- cyan bridge rails (16)
- cyan and magenta neon (03, 07, 10, 13, 14, `biome_screens`)
- orange lava-crack blocks (01, 02, 14)
- glowing gems everywhere

The bible's rules stand. The art bible needs a **per-biome glow table**: which hue each biome may glow in (Lava: violet; Neon: lime and violet; Underwater: soft teal at 40% saturation or less; Celestial: cream). This needs a ruling from the user on Neon, which the reference identity wants in cyan and magenta. Either move the status accents for Neon only (a logged 4.7 override) or drop cyan and magenta from Neon. **Recommended:** drop them from Neon. The accents must read the same in every biome.

### 2.9 Logo and sub-brand
There are four logo treatments:
1. Wooden plank letters with vines (`logo_ref`).
2. Cream and lilac block letters on a plank (`title_screen`).
3. Yellow and purple cartoon letters (15, 18, 19, 20, `party_modes`).
4. Gold letters with a red "PARTY QUEST" ribbon (16).

The bible needs a §7 "Brand" entry:
- **Recommended:** the `title_screen` lockup (wood sign, cream/lilac/honey letters) as the master.
- **Sub-brand:** "PARTY MODE" on the standard red ribbon below it.
- Retire the alternative names "Wacky Party", "Wacky Party Quest" and "Tetro Party" (section 4).

### 2.10 A tropical/pirate home is missing
The roster includes **pirate, tiki, monkey and parrot**, and many minigames (fruit stack, island claim, pirate plunder, bumper battle, kraken keep) are tropical or pirate. None of the 10 main biomes is tropical.

Options:
- **(A, recommended)** Make it a side island like Tumble Fair and Dune Bazaar ("Tiki Cove"), reusing the Meadow and Underwater sets.
- **(B)** Treat it as an Underwater "surface" variant.
- **(C)** Add an 11th biome. That is a scope call for the producer.

The jungle temple minigames also need a host. "Forest (jungle variant)" is the low-cost route.

### 2.11 Next-block preview for minigames (bible §7)
Minigames queue non-piece things (ammo, ramp, key, connector, potion, fruit). The bible says the next-piece preview is the real 3D piece and other icons avoid block shapes. Rules to add:
- The **slot shape is shared.**
- The **label changes** (NEXT BLOCK / NEXT AMMO / TOOL).
- The content is either a real 3D piece render or a painterly prop icon.
- Never a flat tetromino icon.

### 2.12 Bosses and living-object faces (bible §5)
Mockup bosses include a stone golem (02, 19), a pumpkin scarecrow giant (13), krakens (04, 07, 08, 10), a wind cloud (04), a giant ape (09) and a T-rex (07). The bible's boss rule (blocks only where they are played, matte stone elsewhere) holds.

Add one more rule: **no angry-face cubes** (see the Thwomp item in section 4). Boss heads stay rounded.

### 2.13 Small mismatches to tidy
- Bible parchment `#FFF4DE` vs. code `#fbf1dc`.
- Bible ink `#2E2433` vs. code `#3b2346`.
- **Recommended:** the bible adopts the code values, which were tuned on screen.
- Bible §8 naming uses `chr_`, `prp_` and `ui_<biome>_`, while the agent convention is `char_` and `env_`. This document uses the **bible's** prefixes, because they already govern `assets/models/`.

---

## 3. Asset list to build (prioritised)

**Priority key:**
- **P0:** needed for the minigame vertical slice and the tournament.
- **P1:** needed before the minigames ship in more than two biomes.
- **P2:** polish or later.

### 3.0 Shared Blender render rig (build first, P0)
`tools/asset-pipeline/blender/wt_render_rig.blend` plus `render_ui.py`, run headless with `/tmp/claude-0/blender/blender-5.2.2-linux-x64/blender -b wt_render_rig.blend -P render_ui.py -- --item <name>`.

The rig contains:
- An **orthographic camera** at exactly 2x the shipped pixel size (1 Blender unit = 100 px at 1x).
- **Transparent film** and **Eevee** with a toon setup: Shader-to-RGB, then a 3-step colour ramp, with lilac shadow tint and cream highlight.
- A warm key light from the top-left and a cool lilac fill.
- An **inverted-hull outline** (Solidify, flipped normals, backface-culled dark-tint material) on outer silhouettes only.
- AO baked into the colour.
- **Post-step:** downscale 2x with Lanczos to the shipped size, keeping the 2x source (bible §8).

**Nine-patch rule:** frames are built as **curves with a bevel profile object** (or a mesh with a Screw/Array along straight runs). That keeps the cross-section of every straight edge identical, so the stretch zones tile cleanly. Corner nails and decorations live only inside the corner margins. Wood grain runs **parallel to each edge** (a stretched Wave texture), so stretching never shows smearing. The parchment centre is flat colour plus noise that fades to zero at the centre.

In Godot, use `NinePatchRect` / `StyleBoxTexture` with the margins listed. Nine-patch sizes below are the **1x shipped size**; the source is rendered at 2x.

### 3.1 UI kit (nine-patch PNGs, RGBA8, uncompressed UI atlas per bible trade-off 6)

| # | Asset | Prio | Size (1x) | Nine-patch margins (L/T/R/B) | Blender approach |
|---|---|---|---|---|---|
| U1 | `ui_common_plaque_frame.png`: wood rim + parchment centre, neutral honey wood | P0 | 256x192 | 48/48/48/48 | Rounded-rect curve with a 2-plank bevel profile; Wave-texture grain along the curve; 4 corner nail meshes; parchment plane inset 6 px below the rim with an AO lip |
| U2 | `ui_<biome>_plaque_frame.png`: per-biome paint variant (the table in bible §7) | P0 meadow; P1 the rest | 256x192 | 48 each | Same .blend, swapping the paint material colours via the script's `--biome` flag reading `biome_looks.json` `frame` |
| U3 | `ui_<biome>_trim_corner_{tl,tr,bl,br}.png`: overlay decals (vines, icicles, kelp/shells, embers, cogs, stars) | P1 | 96x96 each | none (sprite) | Sculpt/model small props; render each corner with the same camera; anchor in Godot at the frame corners |
| U4 | `ui_common_btn_pill_{gold,cream}_{normal,pressed,disabled}.png` | P0 | 192x72 | 36/24/36/30 (bottom includes the lip) | Capsule curve, face plus a 10 px darker lip; pressed state moves the face down 6 px and drops the lip to 4 px |
| U5 | `ui_common_btn_square_{wood,cream}_{normal,pressed}.png`: pause, settings, icon buttons | P0 | 96x96 | 32 each | Rounded box with bevel modifier, segments 4 |
| U6 | `ui_common_slot_next.png`: Next Block / Item well (deep parchment pocket) | P0 | 160x160 | 44 each | U1 rim plus a 10 px inner bevel down into a darker parchment well (AO bake); the label sits in Godot |
| U7 | `ui_common_scorecard.png`: portrait score card (fixed portrait well on the left) | P0 | 320x136 | 136/40/40/40 (left = portrait well, never stretched) | U1 profile; portrait well is a square inset with a cream mat |
| U8 | `ui_common_player_tab_{p1..p4}.png`: player-colour flag with emblem | P0 | 96x48 | 24/16/24/16 | Cloth-like rounded flag (Cloth sim baked once, or a sculpted wave); emblem decal (circle / triangle / square / star or diamond, per 2.3) embossed in cream |
| U9 | `ui_common_ribbon_{red,purple,gold}.png`: banner with swallow tails | P0 red; P1 others | 512x112 | 140/0/140/0 (horizontal 3-patch) | Curve bent into a shallow arc with a solidify thickness; tail folds as separate meshes; satin shader (anisotropic sheen faked by a ramp) |
| U10 | `ui_common_timer_gearring.png` + `ui_common_timer_cog_small.png` | P0 | 176x176 fixed; cog 48x48 | not a nine-patch | Brass torus with a gear-tooth array, wood disc, parchment face; cogs rendered separately so Godot can spin them on tick |
| U11 | `ui_common_meter_v_frame.png`: thermometer tube | P0 | 64x320 | 0/48/0/80 (vertical 3-patch: cap / tube / bulb) | Glass tube (opaque, faked highlight streak), brass bands, wooden backing strip; bulb is a sphere with an icon socket; **fill drawn by shader** |
| U12 | `ui_common_meter_h_frame.png`: stability, boss HP, progress bar | P0 | 320x48 | 48/0/48/0 | Same materials, horizontal; left cap socket for icons (boss face, scale) |
| U13 | `ui_common_meter_caps.png` atlas: flame, bubble, scale, mountain, boss face, wave, gear | P1 | 8x 64x64 | sprite | Small props in the icon style (bible §7 iconography) |
| U14 | `ui_common_heart_{full,empty}.png` | P0 | 40x40 | sprite | Puffy heart (Skin/Subdivision), rose `#E8566A` jelly gloss; empty is a plum outline ring |
| U15 | `ui_common_emblem_{circle,triangle,square,star/diamond}.png` | P0 | 48x48 | sprite | Embossed cream token with a plum rim |
| U16 | `ui_common_bunting.png`: tileable flag string | P1 | 512x64 | horizontal tile | Array of triangle flags on a curve rope, render with a wrap-safe camera |
| U17 | `ui_common_sign_plank.png`: notched wooden island label (hub) | P1 | 288x80 | 64/0/64/0 | Single plank with V-notched ends; also exported as a GLB (`prp_common_sign_plank.glb`) for diegetic use |
| U18 | `ui_common_tray_pieces.png`: 3-slot piece tray (campaign) | P1 | 512x160 | 48 each; dividers as separate sprites | U1 profile, wide |
| U19 | `ui_common_wheel_{rim,wedge,hub,pointer}.png`: tournament spin wheel | P1 | 512 rim; wedge 256 | sprite set | Lathe wood rim, brass hub; wedges rendered once and rotated in Godot |
| U20 | `ui_common_pin_bubble.png`: map pin / speech bubble | P2 | 96x112 | 32/32/32/48 | Rounded square plus tail, player-colour fill via modulate on a white face layer |
| U21 | `ui_common_logo_master.png` + `ui_common_logo_party_ribbon.png` | P1 | 1024x512; 640x140 | sprite | Extruded text (a licensed rounded display font, converted to curves), wood material per letter, plank sign, vines; **only after the user picks the master (2.9)** |
| U22 | `ui_common_portrait_mat.png`: cream mat behind portraits | P0 | 112x112 | sprite | Plane with an inner-shadow bake |

### 3.2 Props per biome (GLB, glTF 2.0, 1 unit = 1 cube, transforms applied, matte painterly material with baked AO, outline mesh tagged `-outline`)

**Universal minigame prop kit (P0):** one mesh each, with a `paint` and an `accent` material slot. Biome reskins swap only the materials and trim decals, which serves the "reusable building block" decision.

| Asset | Size (cubes) | Notes / Blender approach |
|---|---|---|
| `prp_common_catapult.glb` | 2.0 L x 1.2 W x 1.5 H | Chunky wood beams, rope lashing (curve with bevel), 4 wheels; armature with 1 bone for the throw arm |
| `prp_common_cannon.glb` | 1.5 x 0.8 x 0.9 | Lathe barrel (Screw modifier), wooden carriage; bone for recoil |
| `prp_common_chest.glb` | 0.7 x 0.5 x 0.6 | Lid bone, brass bands; also renders the "treasure" UI icon |
| `prp_common_bomb.glb` | 0.6 diameter | Plum-black sphere, rope fuse curve, spark VFX socket (avoid a pure-black body; use `#2E2433`) |
| `prp_common_spring.glb` | 0.8 dia x 1.0 | Helix via Screw; shape key for compression (wobble towers) |
| `prp_common_seesaw.glb` | 4.0 x 1.2 x 1.0 | Tumbling Towers balance platform; pivot bone |
| `prp_common_cart.glb` | 1.0 x 0.7 x 0.6 | Minecart / candy cart / balloon cart base; rail-snap pivot |
| `prp_common_rail_{straight,curve}.glb` | 1-cell modules | Array along a curve; 1 x 1 grid snapping |
| `prp_common_bridge_plank.glb` + `prp_common_bridge_rope.glb` | 1-cell module | Island links (bible §6). Rope rails are plain, not glowing |
| `prp_common_balloon.glb` | 0.6 dia, string 1.2 | Glossy-ish rubber (allowed: not a block, so no bevel or cube form) |
| `prp_common_conveyor.glb` | 1-cell module | Belt plus rollers; UV-scroll belt in-engine |
| `prp_common_claw_crane.glb` | 1.0 x 1.0 x 2.0 | Galactic grab / salvage; 3-finger bone rig |
| `prp_common_stage_hub.glb` | 8 x 8 x 2 | Mockup 16 central stage with the scoreboard plank |

**Rim and dressing props per biome** (sit on the island margin, never on the grid; 0.3-1.2 cubes; 3 env props plus 3 hero ornaments, as in the production sheets):

| Biome | Prio | Env props | Hero ornaments (1 per piece, 25-35% of a cube) | Landmark (painted card, 2048x1024 PNG) |
|---|---|---|---|---|
| Meadow | P0 | daisy clump, clover patch, round bush, mossy rock, small sheep | sprout, daisy, clover | windmill hill island |
| Lava | P0 | obsidian spur, cooled stone stack, volcanic vent (smoke socket) | cooled shard (violet), small vent, ash tuft | volcano with lava rivulets (volcanic sheet) |
| Underwater | P0 | coral branch, scallop shell, kelp tuft (2 bones for sway) | coral bud, pearl cluster, small shell | sunken ship |
| Candy | P1 | lollipop, cupcake, candy cane, gumdrop | heart sprinkle cap, cherry, swirl | gingerbread castle |
| Ice | P1 | snowy pine, ice crystal, snowman stump | snow cap, snowflake charm, icicle cluster | glacier castle (`screens_flow`) |
| Forest / jungle | P1 | fern, mushroom pair, log, stone idol head (rounded) | leaf, acorn, twig | temple ruin |
| Crystal Cave | P1 | crystal cluster, lantern post, mine-cart buffer | amethyst cluster, mushroom, lantern | mine entrance |
| Clockwork | P1 | gear stack, steam pipe, pressure gauge | small cog, rivet cap, key wind-up | airship |
| Neon | P2 | arcade cabinet (generic, no logos), holo panel, antenna | glow stud, chip, spark | city skyline |
| Celestial | P2 | marble column, star lantern, orbiting moonlet | star charm, moon, comet | arch gate (`screens_flow`) |
| Tumble Fair | P2 | striped tent, lantern string, barrel | ticket, balloon, pennant | ferris wheel |
| Dune Bazaar | P2 | palm, pot, sand dune | brass dome knob, lamp, tile | pyramid |
| Tiki Cove (if 2.10 A) | P2 | palm, fruit pile, tiki torch | banana, coconut, flower | volcano-free atoll |

Blender approach for dressing:
- Low-subdivision sculpt or a primitive-plus-Bevel/Subdivision build.
- Hand-painted colour via vertex paint baked to a 512 px atlas per biome (`env_<biome>_props_alb.png`).
- Matte, with no specular.
- Keep the shapes chunky enough to read at 30 px.
- **Overlap with code:** `wt_island_builder.gd` already scatters procedural tufts, flowers and props. The GLB props replace `_prop()` kinds one-for-one, so the data-driven `props` list in `biome_looks.json` stays the switch.

### 3.3 Character set

**One shared toy rig** (`chr_common_rig.blend`): a 2.4-head biped with mitten hands, stubby legs and a big head bone.
- Wing variants reuse the arm chain for penguin and parrot.
- Every character exports **two GLBs**: a seated cloud version (puzzle levels) and a standing avatar (minigames, about 1.4 cubes tall).
- Shared animation set: idle, cast/act, cheer, oops, run, carry, push, throw, taunt, win, lose.
- Faces use texture-swap eyes and brows (a 4x4 expression atlas) plus jaw and brow bones. This is cheaper and more readable at 48 px than shape-key heavy faces.
- Material: matte felt/clay, a toon ramp with the lilac shadow, outline in a dark tint of the local colour.
- **Portrait renders** come from the same rig and scene: `ui_chr_<name>_portrait.png` at 256x256 (square), plus `ui_chr_<name>_icon.png` at 96x96.
- Emblem badge position is listed per character.

| # | Character | Prio | Silhouette hook (must read at 48 px) | Palette | Emblem badge | IP guardrail (section 4) |
|---|---|---|---|---|---|---|
| C1 | **Wizard** (mascot) | P0 | Tall floppy cone hat with a bend, huge cloud-white beard, wide sleeves | Purple robe and hat, cream trim, single star on the hat | Hat front (replaces the star in multiplayer) | No Fantasia star-and-moon pattern on a blue hat; no grey Gandalf staff and robe |
| C2 | **Pirate** | P0 | Tricorn with a feather, big red-brown beard, long coat flare | Navy coat, red sash, cream shirt | Tricorn cockade | No dreadlocks, beads or bandana (Jack Sparrow); no hook hand or curled moustache in a red coat (Hook) |
| C3 | **Astronaut** | P0 | Round bubble helmet with a gold visor and a big backpack | White suit, panels in the player colour | Shoulder patch | No purple/green suit with wings (Buzz Lightyear); no single visor slit on a bean body (Among Us) |
| C4 | **Robot** | P0 | Dome head with a single antenna ball, two round lens eyes, barrel body. **Not cube-shaped** (bible: only blocks are cubes) | Painted tin grey-blue, brass bolts | Chest light | No binocular eyes on treads (WALL-E); no white egg body (EVE); no BB-8 ball |
| C5 | **Penguin** | P1 | Pear body, flipper wings, big feet, bow tie | Navy-black `#2E3550` (not pure black), cream belly, orange feet | Bow tie knot | Not Pingu (clay, beak shape), not Tux, not Club Penguin |
| C6 | **Alien** | P1 | Big head with **two** antennae with ball tips, two large eyes, small body | Soft green `#8CCF6A`, lilac jumpsuit | Belt buckle | No three-eyed alien with a single antenna in a blue suit (Toy Story Little Green Men) |
| C7 | **Tiki** | P1 | Tall carved mask body, wide grin with teeth, short legs | Warm wood `#A86A3C`, teal and coral paint | Painted forehead mark | **No feather crown on a floating mask** (Crash Bandicoot's Aku Aku / Uka Uka); give it legs and a leaf skirt |
| C8 | **Monkey** | P1 | Big round ears, heart-shaped face mask, long curling tail | Brown `#8A5A36`, peach face | Neckerchief knot | No red cap and shirt (Diddy Kong); keep the tail and an explorer kerchief to avoid Curious George |
| C9 | **Parrot** | P1 | Big curved beak, rainbow wing tips, safari jacket (19/20) | Red body, blue/yellow wing bands, khaki jacket | Jacket pocket badge | Not Iago (Aladdin) or Blu (Rio); keep the jacket and pith hat as the hook |

Cloud mode: every character sits on the **same cloud** prop (`chr_common_cloud.glb`, 1.0 x 0.6 cubes, soft lilac-white), as the bible requires.

**Pose order:** idle, cheer and oops first (they appear in the HUD), then the minigame verbs.

### 3.4 VFX and particles (for completeness; delegate to technical-artist)
P1:
- `vfx_common_confetti`
- `vfx_lava_ember`
- `vfx_underwater_bubble`
- `vfx_ice_snow`
- `vfx_common_dust_puff`
- `vfx_common_shockwave_ring`

These use biome particle colours and stay out of accent hues.

---

## 4. IP check: what must NOT be copied

The references are AI-generated mood images and several contain third-party IP. **Nothing below may appear in any shipped asset, store page, trailer or name.**

### 4.1 Remove or quarantine now
- **`assets/art/reference/party_biome_islands_ref.jpg` is direct Nintendo IP.**
  - Characters: Mario, Luigi, Peach, Bowser, Yoshi, Toads.
  - Enemies and objects: Goombas, Thwomps, green warp pipes, Peach's Castle.
  - Names: "Mushroom Kingdom", "Bowser's Lava Keep", "Rainbow Road".
  - **Recommended:** delete it from the repo, or move it outside the Godot project.
- **Export risk:** `assets/art/reference/` sits under `res://` and every image has a `.import` file, so **the references can ship inside the exported PCK**. Recommended fixes:
  - Move `assets/art/reference/` out of the project, or add a `.gdignore` to it.
  - Add `assets/art/reference/*` to the export preset's exclude filter.
  - Coordinate with technical-artist / devops.

### 4.2 Logos and names on the sheets (do not use)
- **"TETRO PARTY DIMENSIONS" / "PARTY MODE ACTIVE!"** (mockups 06, 10). "Tetro" evokes the **Tetris** trademark. Never use "Tetr-" prefixes, "Tetris", "Tetrimino/Tetromino" or "Rainbow Road Tetris" in names, UI or marketing.
- **"WACKY PARTY QUEST: CRAZY DIMENSIONS"** (11), **"WACKY PARTY"** (12, 14), **"Wacky Towers: Party Quest"** (16). These are AI-invented alternatives, not our brand; do not ship them. Also have the producer run a trademark check near **"Wacky Races"** (Warner Bros./Hanna-Barbera) and **"Mario Party"** before naming the party sub-brand. "Party Mode" as a plain label is fine.
- **"Sugar Rush Stack"** (08) and the similar "Sweet Rush Rails" (09). **Sugar Rush** is the game-within-a-film in Disney's *Wreck-It Ralph*. Rename.
- All minigame titles on the sheets should be treated as placeholders, checked before use.

### 4.3 Trade dress to avoid
- **Tetris look:** the classic 7 tetrominoes in guideline colours (cyan I, yellow O, purple T, green S, red Z, blue J, orange L) in a flat 2D well (`party_modes`, `party_minigames`, `party_versus`, Next Block icons in 01-11). Our 67-shape 3D bank and per-biome palettes are distinct; keep it that way. **Never ship a mode or icon that is just the seven tetrominoes in those colours.**
- **Thwomp-style angry stone cubes** with spiked rims and gritted teeth (`party_biome_islands`). Our block bosses must not use a cube with a grimacing face.
- **Mario Kart-like** item boxes and shells (03 "Rolling Rumble": coloured discs, floating question-box style items, kart racing): keep karts generic and never use "?" boxes or spiked or coloured turtle-shell projectiles.
- **Rocket League** (06 "Cosmic Gravity Goal": rocket hover-cars in a neon soccer arena): the mechanic is fine; avoid its car silhouettes, boost trails and arena goal design.
- **Raiders of the Lost Ark** combo (05 "Ancient Ascenders", 06 "Temple Roller Run", 10): fedora plus whip plus golden-idol swap plus rolling boulder together reads as Indiana Jones. Use them separately: an explorer with a pith helmet, not a fedora and whip.
- **King Kong on a tower** (09 "Jungle Giant Ascent"): a giant ape boss is fine; avoid a gorilla clinging to a spire and swatting at climbers.
- **Sorcerer's Apprentice** (Fantasia): a blue cone hat with stars and moons. Our wizard is purple, with a single star or emblem.

### 4.4 Franchise-like characters on the sheets (do not reproduce)
| Seen on | Looks like | Rule |
|---|---|---|
| "Sif"/"Elf" in a green tunic with a pointed cap and blond hair (01-11) | Link (*Zelda*) | Not in our roster; do not add a green-capped elf |
| Gandalf-like grey wizard with a pointed blue/grey hat (01-11) | Gandalf (*LotR*, Tolkien Estate / Middle-earth Enterprises) | Our wizard stays the cuddly purple cloud wizard |
| Red-haired mermaid with a purple top (05, `biome_screens`) | Ariel (Disney) | Avoid red hair plus purple shell top plus green tail |
| Blonde princess in a pink gown and crown (20 "Candy Climb") | Princess Peach | Not in the roster |
| Moustached chef with a red neckerchief (05 "Cake Stackers") | Mario-adjacent chef | Avoid |
| Red crowned gummy bear (20) | Haribo Goldbears-adjacent | If gummy bears appear, no Haribo shape or colours, no crown branding |
| Pirate with a monkey on the shoulder (08) | Monkey Island echoes | Generic; fine, but the pirate stays C2's design |
| Dwarf with a braided red beard and axe (01-11) | Gimli / Warcraft dwarves | Not in the roster |
| Knight in a red-plumed helmet (01-11) | Generic | Fine but not in the roster |
| Tiki mask with a feather crown (`party_minigames`, `party_versus`) | Aku Aku (*Crash Bandicoot*) | See C7 guardrail |
| Cheerful brown chimp (19, 20) | Curious George | See C8 guardrail |
| Grey robot with round lens eyes (19, 20) | WALL-E-adjacent | See C4 guardrail |
| Green alien (07, 09, 11, `party_*`) | Toy Story aliens if three-eyed | See C6 guardrail |
| Octopus DJ in a pirate hat (`biome_screens`) | Generic | Fine |
| Dragon in a party hat, fire elemental, cavemen (`biome_screens`) | Generic | Fine |

### 4.5 General rules
- Reference images are **mood only**. No tracing, paint-over, img2img or texture sampling from them for shipped assets (bible §9).
- Fonts in the mockups are unknown. Ship only Fredoka (OFL, already in `assets/fonts/`) or another licensed font.
- Every external material or model (Poly Haven, BlenderKit) is logged in the Blender project's `LICENCES.md` (block-art-sets rule 4).

---

## 5. Top-15 build order

| Rank | Asset | Why first |
|---|---|---|
| 1 | Blender render rig + `render_ui.py` (3.0) | Every PNG and portrait depends on it; locks in lighting and outline consistency |
| 2 | U1/U2 plaque frame (neutral + Meadow) | Base of every panel, card and goal card |
| 3 | U4 pill buttons gold/cream (3 states) | Every screen; replaces the code-drawn pills with the painted look |
| 4 | U6 Next slot (Block/Item/Ammo) | Shared by campaign and every minigame |
| 5 | U7 score card + U8 P1-P4 tabs + U15 emblems | Tournament identity and the colourblind backup (needs the 2.3 emblem decision) |
| 6 | U10 gear-ring timer + cog | Every timed minigame and tournament countdown (needs the 2.5 exception) |
| 7 | U11/U12 meter frames (shader fill) + U14 hearts | Most minigames depend on a meter (needs the 2.6 colour rules) |
| 8 | U9 red ribbon banner | Round titles, "Party Mode" sub-brand |
| 9 | C1 Wizard: standing avatar GLB + portraits (seated version re-rigged on the shared rig) | Mascot; validates the shared rig |
| 10 | C2 Pirate, C3 Astronaut, C4 Robot (GLB + portraits) | The three opponents shown in the hub and every tournament sheet |
| 11 | Universal minigame prop kit, first 6: catapult, cannon, chest, bomb, spring, bridge plank/rope | Most-reused minigame building blocks; material slots enable the per-biome reskin |
| 12 | Meadow dressing props + hero ornaments | First biome; replaces procedural `_prop()` kinds |
| 13 | Lava + Underwater dressing props + hero ornaments (from the production sheets) | Already fully specified on the two production sheets |
| 14 | C5-C9 Penguin, Alien, Tiki, Monkey, Parrot (GLB + portraits) | Completes the roster once the rig is proven |
| 15 | U19 tournament spin wheel + U17 plank sign + U16 bunting | Tournament round pick and hub dressing |

**Decisions needed from the user before ranks 5-7 and 14:**
- Orientation (2.1)
- Emblem set (2.3)
- Gear-ring exception (2.5)
- Meter colour rules (2.6)
- Neon glow hues (2.8)
- Master logo (2.9)
- Tropical home (2.10)
