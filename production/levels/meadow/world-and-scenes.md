# Meadow World + Scene Brief: Pip's Picnic

> **Status**: Draft v1 (world-builder, 2026-10-10), for narrative-director + user review
> **Canon Level**: Established where it cites `design/levels/meadow.md` (approved 2026-10-10); everything marked *(prov.)* is **Provisional**
> **Visible To Player**: Discoverable (all of it is told without words: the island, its underside, the backdrop, Pip and the Miller)
> **Source**: `design/levels/meadow.md` (rules, beats, skits; it wins every conflict), `production/levels/meadow/layout.md`, `production/levels/campaign/biome-stories.md` (tone, cast), `production/levels/campaign/biome-bible.md` §2.1 and §4, `design/gdd/mechanics-module.md` (atom ids), `mechanics-catalog.md`, `level-specific-mechanics.md`, `twist-library.md` (twist visuals), `obstacles.md`, `design/art/art-bible.md` §3 and §6, `design/art/block-art-sets.md`, `docs/architecture/implementation-plan.md` §2.2 (one scene per level)
> **Cross-References**: `production/levels/candy/layout.md` (seeds, §5)
> **Contradictions Check**: none introduced. Contradictions found **between existing docs** are listed in §6. No rule, number or beat from `meadow.md` changes here.
> **Scope**: world facts, scene contents and lore fields only. No player-facing text (that is the writer's job; the flavour lines in §4 are design notes, not UI copy). No mechanics are decided here.

**Every name, beat and asset in this file is a tunable default.**

**Tags used in this file**
- **[K]** = shared biome kit (instanced by every Meadow scene, and by `generic_level.tscn` through `biomes/meadow.json`). **[U]** = unique to one level scene.
- **[G]** = greybox now (needed to read the level or its story). **[P]** = polish later (charm, never needed to play).

**The scene contract** (implementation plan §2.2, restated so this brief stays inside it): a level scene owns the *place* (the island, props, mascot spots, camera framing, skits). It never holds a rule value. Every moving thing in this brief that reacts to a rule (the sails on a gust, the fog banks, the belt) is a **presenter**: it listens to the `BoardController` signals (`rule_event`, `layers_cleared`, `piece_locked`...) and reads its timing from the event, never from its own numbers.

---

## 1. Meadow world rules (one page)

**Tone.** A sunny, wholesome, slapstick toy diorama. Wordless (biome-stories tone rule 1). Failure is a gag, nobody is hurt, only bonked, floured or stuck (tone rule 4). Of all the biomes it is the most classic, and the one that feels most like home. "Gentle weather": each level has at most one visible disturbance (meadow.md §1), so the scene never adds a second, competing motion near the board.

**Geography.** *(prov.)* The Meadow is a scatter of small floating turf islets drifting around **Mill Hill**, the biggest island, with the windmill on top. Each level is played on a different islet (meadow.md "one island per level"), and the level 10 board is the mill yard on Mill Hill itself. That reconciles the biome bible's "sunny home island" with one island per level: the home island is the whole cluster. Islet bodies are turf over a soil band, with pebbles and roots (block-art-sets: turf over soil). The underside is roots and dangling clover (art bible §6: the underside carries the biome's signature).

**The landmark gets closer** (art bible §6 channel 4). The mill is in the backdrop of every level, and its distance tells the player where the story is without any words: far and quiet in 01–02, near enough to see the Miller from 03 (meadow.md), hidden in the fog in 07, right next door in 09, and in 10 you are standing in its yard.

**Inhabitants.**
- **Pip**, a harvest mouse (Established). Tiny, brave, always carrying a picnic basket twice its size. Helper in tiers 1–3 (it points at a cell and makes **Pip's catch**), watcher from tier 4. Pip never pranks in the Meadow (meadow.md).
- **The Miller**, a flour-dusted badger (Established; "badger" is still a working choice per biome-stories). He wants a quiet mill and loud gusts. He causes every disturbance from 03 on and is the boss in 10. He stays smug, gets bonked into flour, and stomps off vowing a rematch (tone rule 5).
- **The meadow friends** (Established as a group): three sleepy friends in nightcaps (02), frogs at the pond (04), a dozing owl (07), nesting birds and chicks (09), and ants (bonus, H2). *(prov.)* Their species are left to the narrative-director. Suggestion: a vole, a shrew and a hedgehoglet in 02, chosen because they read as three different silhouettes at phone size.
- **The Wizard** sits on a cloud, off the board, in the Meadow costume. Its Keepsake for this biome is a tiny windmill (Established).

**Ecology.** It is late-summer grassland: clover, daisies, dandelions, sunflowers, mushrooms in the damp hollows, a lily pond, one big nesting tree, bees and butterflies. Everything is natural except the mill, the only machine in the biome. That gives a simple rule players can read: **if it is a machine-made disturbance, it comes from the mill** (gusts from the sails, fog from the chimney, the belt, the lever). *(prov.)* Living objects that are not the Miller's doing (sprouts, eggs, ants) are just the meadow being alive.

**What the blocks are.** The **block drizzle** is weather. It rains blocks here from a sunny sky, and nobody explains why (tone rule 7, Established). Meadow blocks are chunky turf-over-soil toy blocks with wildflower add-ons (block-art-sets primary theme set). *(prov.)* The meadow folk treat the drizzle like a soft summer shower: it is harmless, a little in the way, and useful. A full layer **settles**: it sinks into the islet and becomes meadow (meadow.md 01: "the plot sinks, a leaf pops"). That is why the story often grows on each clear (a leaf, a bed, a sail knocked off). **Towers** are things Pip builds for a purpose: a lookout (05), a bouquet (06), a packed basket (bonus).

**Readability rules for the world** (art bible §3, §6; they apply to every scene below).
1. The grid plus a one-cube margin hold only flat tiles. Rim props are sparse, low and rounded, placed at the corners, and checked from every snap angle.
2. Nothing in the dressing is gloss, bevel and cube-sized at once; that look belongs to blocks.
3. **No decorative mushrooms or eggs within the island rim.** Those shapes are board content (SP19, SP21) in 04 and 09, so the dressing must not use them as props near the board. Backdrop use is fine.
4. Ambient motion is slow and kept in the backdrop. The single disturbance owns the motion near the board.

**Day and weather across the biome** *(prov.; a story-adjacent choice, for narrative-director).* The picnic keeps getting postponed, which the player reads from the light alone. **Day 1** (01–02): morning planting, then bedtime in the burrow. **Day 2** (03–06): wind, mushrooms, the lookout reveal and the bouquet, ending in the late afternoon. **Day 3** (07–10): dawn fog, the drying dew, the flip at midday, and the picnic at golden hour after the boss. This fits the Established beats (02 blows out a candle, 07 is morning fog, 08 has a low sun that rises). Alternative: a single, timeless sunny day with weather variation only. That is cheaper, but loses the "postponed picnic" read. Art-bible mood states (danger desaturation, the golden-hour win) are layered on top of either option.

**Hidden layer** *(prov., Hidden; for narrative-director).* The Miller does not hate picnics; he hates *noise*. In 10, a tiny, neat one-badger picnic blanket can sit on the mill roof beside him. It is visible only from the high snap angles and never explained. It sets up his rematch without a word.

---

## 2. Per-level scenes

Every scene inherits the base level scene and instances the **Meadow kit** (§3). The lines below list only what makes each scene different. "Mill" gives the backdrop mill variant (§3 B2). Mascot spots are the `Marker3D` names the scene must provide.

### 01 First Sprout (seed plot)
| | |
|---|---|
| Island | Bare 4×4 soil plot, freshly dug; turf only on the rim **[U][G]** |
| Landmark | Mill far, sails idle, no Miller (he is not "on" until 03) **[K][G]** |
| Time / weather | Day 1, clear morning, light drizzle sparkle at spawn **[K][G]** |
| Ambient life | Two butterflies in the backdrop, a bee pass **[K][P]** |
| Storytelling beat | The seed mound in the plot centre grows one leaf per clear (a presenter on `layers_cleared`) and becomes a sunflower on the win; Pip hangs the basket on it **[U][G mound + leaf stages, P sunflower]** |
| Mechanics in-world | Block Drizzle (AR01) and Seed Spin (CV02): first-day blocks only spin flat. Pip's Catch (WO11). **Rubber duck** (SE05) in the underside socket, seen from one low angle **[K socket][U placement][G]** |
| Mascot spots | `pip_idle` (plot corner), `pip_point`, `pip_catch`, `pip_cheer` **[G]** |

### 02 Tilt & Roll ★PROTO (the burrow)
| | |
|---|---|
| Island | A cut-away burrow: the islet is sliced open so the two starter layers sit inside a stone-and-root chamber **[U][G]** |
| Landmark | Mill far, seen through a round burrow window **[U window][K mill][P]** |
| Time / weather | Day 1, evening; warm candle-lit interior with a dusk backdrop through the window **[U][G light preset, P candle flicker]** |
| Ambient life | Three sleepy friends in nightcaps by the pockets; a filled pocket snores (presenter on `piece_locked` inside a pocket) **[U][P]** |
| Storytelling beat | Nightcaps hang on the pocket edges, so each pocket reads as "a bed for someone" before any text **[U][G]** |
| Mechanics in-world | Yesterday's Stack (BL05): the starter blocks are burrow bed-frames *made of drizzle blocks*. They must use the normal block look, never stone, because they clear like blocks (see §6 C11). Tilt & Roll (CV01). Duck (SE05) **[K][U placement][G]** |
| Mascot spots | `pip_idle`, `pip_point`, `pip_catch`, `friends_a/b/c` **[G]** |

### 03 Breezy Hill (hillside lane)
| | |
|---|---|
| Island | Long 8×4 sloped lane; the downhill wall (x = 7) is a low stone fence, the "brace" **[U][G]** |
| Landmark | Mill mid, at the top of the slope (uphill, −x side), sails spinning; the Miller visible as a tiny silhouette **[K][G]** |
| Time / weather | Day 2, late morning, scudding clouds **[K][G]** |
| Ambient life | Dandelion field on the rim and in the backdrop; seed fluff drifts *only* during a gust **[K][P]** |
| Storytelling beat | Dramatic irony: the player can see the Miller cranking the sails, but Pip cannot yet (that is paid off in 05) **[K][G]** |
| Mechanics in-world | Dandelion Gust (EV01): the sails spin up a beat before each gust; the grass-bend and petal-stream telegraph comes from the kit presenter (twist-library visuals). Dandelion Puff (SP28): a block with a seed-head **[K][G]** |
| Mascot spots | `pip_idle`, `pip_catch`, `pip_sneeze` **[G]** |

### 04 Mushroom Ring (pond ring)
| | |
|---|---|
| Island | Ring islet around a 3×3 lily pond (the masked centre) with water level below the tiles **[U][G]** |
| Landmark | Mill mid; the Miller works a bellows on the mill's side *(prov.: spores puffed from the mill)* **[K mill, U bellows][P]** |
| Time / weather | Day 2, noon, pond glitter **[U][G light, P glitter]** |
| Ambient life | Frogs on lily pads in the pond (inside the mask, below the grid, so off the play cells); they flinch on each pop **[U][P]** |
| Storytelling beat | Pip's picnic cloth floats in the pond from the intro skit until the payoff **[U][P]** |
| Mechanics in-world | Pond Ring (BL02). Mushroom Pop-up (EV04 + SP19): the sparkle is a spore landing; the mushroom with a face is board content (kit skin), so it is the same in every Meadow level **[K][G]** |
| Mascot spots | `pip_idle`, `pip_bounce` (backdrop mushrooms, off the rim) **[G]** |

### 05 Tall Tower ★PROTO (hilltop)
| | |
|---|---|
| Island | Bare hilltop, small 5×5, a lot of sky; the **wooden sign** on a post at layer 9 **[K sign][U][G]** |
| Landmark | Mill far on the horizon (the reveal needs distance) **[K][G]** |
| Time / weather | Day 2, afternoon, high clouds, light breeze (the sign sways; not a rule) **[K][G]** |
| Ambient life | One kite-like bird circling far away **[K][P]** |
| Storytelling beat | Pip climbs as the tower grows (`pip_climb_*` spots follow the height). The payoff spyglass shows the Miller cranking a giant fan, the "so that's who it is" moment **[U][G spots, P skit]** |
| Mechanics in-world | Reach the Sign (M1 = GO02 + FT02 + CL14). Lookout Wobble (PL03): the lookout creaks and leans. Popcorn Trim (FT02): cubes pop off and bounce **[K][G]** |
| Mascot spots | `pip_idle`, `pip_climb` (moved by a presenter on height), `miller_laugh` (backdrop) **[G]** |

### 06 Flower Bed (garden bed)
| | |
|---|---|
| Island | A tidy 8×8 garden bed with a wooden edging; flower outline drawn in the soil (the target shape is a board overlay) **[U][G]** |
| Landmark | Mill mid, quiet; the Miller is napping in the backdrop (a calm level) **[K][P]** |
| Time / weather | Day 2, late afternoon, warm and still **[K][G]** |
| Ambient life | Bees around the rim flowers; a watering can at one corner **[U][P]** |
| Storytelling beat | An empty vase by the bed (from the intro) waits for the payoff bouquet **[U][P]** |
| Mechanics in-world | Plant the Picture (M2). Growing Sprouts (SP22): Pip's seeds, planted on purpose. Popcorn Trim (FT02) **[K][G]** |
| Mascot spots | `pip_idle`, `pip_water` **[G]** |

### 07 Hide & Seek (foggy hollow)
| | |
|---|---|
| Island | A damp hollow with mossy banks; the starter layers are yesterday's stack, left in the dip **[U][G]** |
| Landmark | Mill hidden in the fog; only a sail silhouette and the chimney puffing mist **[K mill, U chimney puff][G]** |
| Time / weather | Day 3, dawn, low fog banks around the rim (backdrop fog is ambience; the fading of the stack is the twist) **[U][G]** |
| Ambient life | A half-asleep owl on a stump; dew on the moss **[U][P]** |
| Storytelling beat | The picnic basket "lost" in the fog from the intro sits on Pip's head the whole level, a gag for players who look closely **[U][P]** |
| Mechanics in-world | Morning Fog (EV02): mist from the mill chimney. A clear blows it away (the reveal presenter puffs the rim fog too). Fog Ghost (SP26): a piece made of mist **[K][G]** |
| Mascot spots | `pip_idle` (in the fog, ears sticking out), `pip_pop` **[G]** |

### 08 Dewdrop (dewy lawn)
| | |
|---|---|
| Island | A small, glittering lawn, 5×5 **[U][G]** |
| Landmark | Mill mid-far, silhouetted against the low sun; flour drifts from its open door *(prov.)* **[K][P flour drift]** |
| Time / weather | Day 3, sunrise; a low sun that rises across the 150 s (a presenter on goal progress; the HUD sun dial is the rule, this is the echo) **[U][G light, P sun motion]** |
| Ambient life | Snails leaving shiny trails on the rim **[U][P]** |
| Storytelling beat | Pip stuck to a dewdrop at one corner, wriggling **[U][G spot, P anim]** |
| Mechanics in-world | Sticky Dew (PL01). *(prov.)* Flour from the mill settles on the dewy grass and turns it to paste, which keeps "the Miller causes every disturbance from 03" true. Hold On (GO04) **[K][G]** |
| Mascot spots | `pip_stuck`, `pip_free` **[G]** |

### 09 Topsy-Turvy ★PROTO (tree island)
| | |
|---|---|
| Island | Islet with the big nesting tree at one corner; nests in its branches **[U][G]** |
| Landmark | Mill near; the Miller at a giant lever on Mill Hill, linked by a rope to the islet *(prov.)* **[K mill, U lever + rope][G]** |
| Time / weather | Day 3, midday, bright **[K][G]** |
| Ambient life | Mother bird fussing over empty nests **[U][P]** |
| Storytelling beat | The empty nests explain the eggs on the board before the first flip **[U][G]** |
| Mechanics in-world | Topsy Tumble (EV03): the Miller's lever turns the islet over. The countdown ring and side arrows come from the kit presenter. Hatching Eggs (SP21): eggs shaken out of the tree **[K][G]** |
| Mascot spots | `pip_idle`, `pip_hang` (from a root, for the flipped state) **[G]** |
| Open | How the flip is shown (does the whole diorama turn over, exposing a dressed underside, or only the stack?) is a presentation decision (§6 F2) |

### 10 Meadow Mill ★PROTO (mill yard, boss)
| | |
|---|---|
| Island | The mill yard on Mill Hill: flour sacks at the corners, the mossy **Mill Belt** as the board surface, and the mill itself on the +x edge (meadow.md sketch) **[U][G]** |
| Landmark | The mill, close up, with three sails as boss health (each clear knocks one off, a presenter on `layers_cleared`), the Miller on the roof, a shutter and the giant lever **[U][G sails + Miller spot, P shutter]** |
| Time / weather | Day 3, afternoon, turning golden for the payoff picnic **[U][G]** |
| Ambient life | Flour puffs from the door on every belt shift; sparrows on the sacks scatter on the flip **[U][P]** |
| Storytelling beat | Pip's picnic blanket rolls along the belt in the intro and waits at the edge. *(prov., Hidden)* The Miller's own tiny blanket on the roof (§1) **[U][P]** |
| Mechanics in-world | Mill Belt (EV05): the mill's drive belt (level-specific-mechanics: "a mossy belt"). Dandelion Gust (EV01) across the belt from the sails. Topsy Tumble (EV03) in phase 2 from the giant lever. The Miller is the face of the rules, not a rule: he cheers on a warning and sulks on a clear (meadow.md) **[K presenters, U mill rig][G]** |
| Mascot spots | `miller_roof`, `miller_lever`, `miller_bonk`, `pip_blanket` **[G]** |
| Open | The flip has the same question as 09, plus what happens to the Miller and the mill when the hill is upside down (§6 F2) |

### B Picnic Puzzle (picnic cloth)
| | |
|---|---|
| Island | A tiny islet covered by a chequered picnic cloth; the 4×4 board is the open hamper **[U][G]** |
| Landmark | Mill mid (the hamper is the focus) **[K][P]** |
| Time / weather | Picnic noon, bright **[K][G]** |
| Ambient life | A line of ants with tiny forks marching across the rim toward the cloth. It is the visible clock (meadow.md), so it is a presenter on the level timer, not ambience **[U][G]** |
| Mechanics in-world | Packed Lunch (AR09), Empty Hamper (FT07) **[K][G]** |
| Mascot spots | `pip_lid`, `ant_scout` **[G]** |

### H1 Seed Sprouts · H2 Picnic Ants · H3 Two Fields (hard track)
| Level | Scene difference | Tags |
|---|---|---|
| H1 | The 01 seed plot, overgrown; the sunflower gone to seed and sagging; late-summer light. A sunflower variant of 01's prop | **[U][G plot reuse, P sunflower]** |
| H2 | A picnic-cloth islet with sandwich crumbs at the rim; ant content uses the kit skin (SP31); the mushroom callback uses the kit SP19 | **[U][G]** |
| H3 | Two 4×4 veg patches joined by a wooden **plank** (meadow.md; it answers the art bible's open "island links" question for the Meadow with a physical link); a watering can on the plank | **[U][G]** |

---

## 3. Shared Meadow biome kit

Every Meadow level scene instances these, and `generic_level.tscn` builds its default Meadow diorama from them (player and daily levels). Names follow the art-bible `env_meadow_` prefix; folder paths are left to the tech-artist.

**B. Backdrop**
| # | Item | Notes | Tag |
|---|---|---|---|
| B1 | Sky dome / gradient | Warm-neutral Grass palette (sky `#8F9AD8`), ≤ 40% saturation | [G] |
| B2 | Mill on Mill Hill, 3 distance variants (far / mid / near) | Animated sails (idle, spinning, gust spin-up); a Miller silhouette slot from 03 | [G] silhouette, [P] paint |
| B3 | Rolling-hill and cloud cards | Painted cards, slow drift | [G] flat, [P] painted |
| B4 | Mid-ground turf islets | Desaturated, 3 sizes | [P] |
| B5 | Lighting presets | Morning, noon, afternoon, golden, dawn-fog, sunrise, interior candle; art-bible mood states layer on top | [G] |

**I. Island kit**
| # | Item | Notes | Tag |
|---|---|---|---|
| I1 | Turf top tiles | Flat, ≤ 1/5 cube height, grid lines; works for any mask (ring, lane, square) | [G] |
| I2 | Island body strata | Turf, soil, pebble band; edge and corner modules | [G] |
| I3 | Underside | Roots, dangling clover, a soil drip; includes a **duck socket** (SE05) | [G] socket, [P] roots |
| I4 | Rim props | Daisy clumps, clover tufts, pebbles, a fence-post stub. Low, rounded, corners only. **No mushrooms or eggs** (§1 rule 3) | [P] |

**C. Characters** (rigs shared; each scene provides only the spots)
| # | Item | Notes | Tag |
|---|---|---|---|
| C1 | Pip + picnic basket | Poses: idle, point, catch, cheer, cover-eyes, sneeze, stuck, hang | [G] proxy, [P] rig |
| C2 | The Miller | Poses: crank, lever, cheer, sulk, laugh, bonk | [G] proxy, [P] rig |
| C3 | Rubber duck | SE05 collectible; tap target | [G] |

**E. Event and content presenters** (driven by `BoardController` signals; no rule values)
| # | Item | Drives on | Tag |
|---|---|---|---|
| E1 | Dandelion Gust presenter: grass-bend shader, petal stream, sail spin-up | wind warning / gust events (twist-library visuals) | [G] |
| E2 | Morning Fog presenter: rim fog banks that puff away on a clear | fade / reveal events | [G] |
| E3 | Topsy Tumble presenter: side arrows, countdown ring, "whump" | flip warning / flip | [G] |
| E4 | Mill Belt surface: mossy belt with rollers | conveyor shift | [G] |
| E5 | Content skins: mushroom with a face (SP19), sprout (SP22), egg and chick (SP21), fog ghost (SP26), dandelion puff (SP28), ant (SP31) | board content render | [G] proxy, [P] final |
| E6 | Wooden goal sign (GO02) and flower-outline overlay (GO03) | goal setup | [G] |
| E7 | Story-grows-on-clear hook: a generic "advance one stage" node used by the 01 leaf, the 10 sails and others | `layers_cleared` | [G] |

**A. Ambience**
| # | Item | Notes | Tag |
|---|---|---|---|
| A1 | Meadow ambience bed: birdsong, bees, soft breeze | Layers follow meadow.md §9 (base → + wind → + plucks → …) | [P] |
| A2 | Ambient particles: pollen motes, rare butterflies (backdrop only) | Low density, slow | [P] |
| A3 | One-shots: frog croak, owl hoot, mill creak, flour puff | Used by 04, 07, 09, 10 | [P] |

**Greybox minimum for the four prototypes (02, 05, 09, 10):** B1, B2 (silhouette), B5, I1, I2, I3 socket, C1/C2 proxies, E1–E7 proxies, plus each level's [U][G] rows in §2.

---

## 4. Lore fields for the mechanics database

Keyed by **module atom id** (the ids the Meadow recipes and level JSON use). The catalog id is given where `mechanics-catalog.md` §9 maps one (see §6 C10). `Canon`: E = Established (from meadow.md or a GDD), P = Provisional. Flavour lines are design-facing notes for the writer; they are not UI text.

**Tag vocabulary**: `biome:meadow` on every row, plus `src:` (miller / nature / pip / wizard / level), `kind:` (board, arrival, verb, placement, clear, collapse, goal, fail, event, living, special, secret, mascot) and `tone:` (calm / chaos).

| Atom | Catalog / M | Meadow name | Flavour (one line) | Tags | Used in | Canon |
|---|---|---|---|---|---|---|
| BL01 | — | The Patch | Every meadow islet has a flat patch of turf just the right size for stacking. | src:level kind:board tone:calm | all | P |
| BL02 | B5 | Pond Ring | The patch wraps round the lily pond, and nothing stacks on water. | src:nature kind:board | 04 | E (pond ring) |
| BL05 | — | Yesterday's Stack | Some patches start half built: last night's drizzle settled into burrow beds and hollows. | src:nature kind:board | 02, 07, H1, H2 | P |
| BL07 | B3 | Two Fields | Two veg patches, one plank, one drizzle. | src:pip kind:board tone:chaos | H3 | E |
| AR01 | — | Block Drizzle | Soft turf blocks drift down from a sunny sky, and nobody asks why. | src:wizard kind:arrival tone:calm | all | E |
| AR09 | — | Packed Lunch | Exactly six pieces in the hamper, no seconds. | src:pip kind:arrival | B | P |
| CV01 | — | Tilt & Roll | Turn a block any way it will go. | src:pip kind:verb | 02–H3 | P (level name E) |
| CV02 | — | Seed Spin | First-day blocks only spin flat, like a seed on a plate. | src:pip kind:verb tone:calm | 01 | P |
| PL01 | M3 | Sticky Dew | Mill flour on dewy grass makes paste: whatever lands, stays. | src:miller kind:placement tone:chaos | 08 | E (dew); P (flour) |
| PL03 | P2 | Lookout Wobble | Tall lookouts creak in the hilltop breeze; lean too far and the top piece slips. | src:nature kind:placement | 05 | E |
| CL01 | — | Settle | A full layer sinks into the islet and becomes meadow. | src:nature kind:clear tone:calm | all clear levels | P |
| CL14 | — | No Settling | On the hilltop and in the flower bed, full layers stay put. | src:level kind:clear | 05, 06, B | P |
| CO01 | — | Slump | What sat on a settled layer drops gently down. | src:nature kind:collapse | all clear levels | P |
| GO01 | — | Grow the Story | Each settled layer moves the story on: a leaf, a bed, a sail. | src:level kind:goal | 01–04, 07, 09, 10, H1–H3 | P |
| GO02 (M1) | — / M1 | Reach the Sign | Build to the wooden sign; nothing settles up here. | src:pip kind:goal | 05 | E (sign) |
| GO03 (M2) | — / M2 | Plant the Picture | Cover the outline in the soil and it blooms. | src:pip kind:goal tone:calm | 06, B | E (outline) |
| GO04 | — | Hold On | Hang on until the sun dries the grass. | src:nature kind:goal | 08 | E |
| FT01 | — | Close Call | Too high once is a scare (Pip covers its eyes); too high again ends the day. | src:level kind:fail | all rescue levels | P |
| FT02 | §6 Trim | Popcorn Trim | Cubes over the line bounce off the island like popcorn; it never fails. | src:level kind:fail tone:calm | 05, 06 | E (popcorn image) |
| FT07 | — | Empty Hamper | When the hamper is empty, the packing is done, ready or not. | src:pip kind:fail | B | P |
| EV01 | — (T1 Wind) | Dandelion Gust | The Miller's sails blow gusts down the hill; the grass bends a beat before. | src:miller kind:event tone:chaos | 03, 10, H1 | E |
| EV02 | — (T2) | Morning Fog | Mist from the mill chimney swallows the stack; a clear puffs it away. | src:miller kind:event | 07 | E (name); P (chimney) |
| EV03 | — (T3) | Topsy Tumble | The Miller hauls his big lever and the whole islet turns over. | src:miller kind:event tone:chaos | 09, 10 | E |
| EV04 | — (T4) | Mushroom Pop-up | The mill's bellows puff spores; a sparkle marks where the next mushroom pops. | src:miller kind:event | 04, H2 | E (name); P (spores) |
| EV05 | M4 | Mill Belt | The mill's mossy drive belt carries the whole stack round. | src:miller kind:event tone:chaos | 10 | E |
| SP19 | — | Mushroom | A cheeky mushroom with a face; a free cell if you planned for it, and it squeaks when cleared. | src:nature kind:living | 04, H2 | E |
| SP21 | — | Hatching Egg | Eggs shaken out of the upside-down tree hatch into chicks that hop into gaps. | src:nature kind:living | 09 | E |
| SP22 | — | Growing Sprout | Pip's planted seeds push up a cube of stalk all by themselves. | src:pip kind:living tone:calm | 06, H1 | E |
| SP26 | — | Fog Ghost | A piece made of mist drifts through the stack until a tap makes it real. | src:miller kind:special | 07 | E |
| SP28 | — | Dandelion Puff | A block crowned with a seed-head bursts in two when it lands. | src:nature kind:special | 03 | E |
| SP31 | — | Picnic Ants | Ants munch a cube on every lock; a clear beside them sends them packing. | src:nature kind:living tone:chaos | H2 | E |
| SE05 | — | Rubber Duck | The wizard's rubber duck hides under the island; only one low look finds it. | src:wizard kind:secret | 01, 02 | E |
| WO09 | — | Pip Watches | From tier 4 on, Pip only cheers and gasps. | src:pip kind:mascot | 04–H3 | E |
| WO11 (WO06 role) | — | Pip's Catch | Once a level, Pip leaps, catches a bad drop and hands it back. | src:pip kind:mascot tone:calm | 01–03 | E |

**Considered but not used in the Meadow**: EV13 Halftime swap (meadow.md 10, kept in reserve). **Obstacles** (`obstacles.md`) are not used in any Meadow level. These Meadow skins are reserved for the generic scene and future remixes *(all P)*:

| Obstacle | Meadow name | Flavour | Tags |
|---|---|---|---|
| Crate | Twine Crate | Planks and twine (obstacles.md); breaks on the first settle. | src:level kind:obstacle |
| Rock | Field Stone | A stubborn stone that holds its layer back until it cracks. | src:nature kind:obstacle |
| Stone Pillar | Old Fence Post | A post driven right through the patch; the layer settles around it. | src:level kind:obstacle |
| Junk | Mud Clod | A grey, hue-less clod flung in by a rival. | src:rival kind:obstacle |

**Non-atom story entries** (for the database's story fields): `boss.meadow` = The Miller (E); `mascot.meadow` = Pip (E); `keepsake.meadow` = tiny windmill (E); `landmark.meadow` = the mill on Mill Hill (P name).

---

## 5. Seeds for later biomes (same id, new flavour)

One line per id. Biome casts follow `biome-stories.md` and `candy/layout.md` (see §6 C2 for why not the biome bible). These are premises only; game-designer and level-designer own the rules.

- **EV01 Gust**: Candy cotton-candy breeze · Forest falling-leaf wind · Underwater current lane · Ice blizzard · Celestial solar wind · the Miller's own gusts crashing a later biome as a rival return (biome-stories).
- **EV02 Fog**: Underwater octopus ink · Ice whiteout · Lava smoke screen · Neon blackout · Celestial eclipse.
- **EV03 Topsy Tumble**: Candy Fountain Tilt · Underwater whirlpool · Ice the cracked iceberg flips · Clockwork rewind · Celestial gravity everywhere.
- **EV04 + SP19 Pop-up**: Candy Gumdrop Hail · Forest squirrel acorns · Underwater jellyfish · Ice snowballs · Lava geysers · Clockwork springs · Celestial meteors.
- **EV05 Belt**: Forest root wiggle · Cave minecart rail · Lava magma flow · Clockwork conveyor street.
- **PL01 Sticky**: Candy gumdrops (sticky tag) · Lava hot syrup.
- **PL03 Wobble**: Ice icicle tower · Candy jelly tiers (if Candy wants physics silliness).
- **SP21 Hatching egg**: Ice penguin eggs (Pebble's egg story) · Lava ember eggs that hatch into sparks.
- **SP22 Sprout**: Forest saplings · Underwater coral · Cave stalagmites · Celestial star buds.
- **SP26 Ghost piece**: Underwater see-through jelly · Neon glitch ghost · Cave echo.
- **SP28 Split piece**: Forest maple "helicopter" seed · Underwater bubble pair · Neon pixel split.
- **SP31 Pest**: Candy gummy worms · Forest acorn-thief squirrels · Underwater sea snails.
- **SE05 Duck**: the same rubber duck under every biome's island (running gag), costumed per biome.
- **WO11 Catch**: each biome mascot catches in character (Mallow sticks to it, Chip grabs it, Puff inflates under it).
- **BL02 Ring**: Candy round cake tin · Underwater clam ring.
- **BL05 Pre-built pockets**: every biome's tier 2 pocket level (cake tin, hollow log, clams, icicles, gems, embers, gears, pixels, constellations).
- **BL07 Islands**: Neon twin towers.
- **M1 Reach the Sign**: every tier 5 tower (cake candles, treehouse, coral, igloo, stalagmite, obsidian, clock face, skyscraper, orbit sign).
- **M2 Plant the Picture**: every tier 6 picture (icing, bridge, necklace, snowman, crystal, marshmallow, pendulum, logo, mascot constellations).
- **GO04 Hold On**: every tier 8 survive (sugar rush, woodpecker, sinking ship, thin ice, cave-in, eruption, tick-tock, lag, zero-G).
- **AR09 + FT07 Packed Lunch**: every bonus box (Candy Box, Berry Basket, Treasure Chest, Present, Treasure Map, Forge, Music Box, Arcade, Hat Box).
- **CL01 Settle**: each biome's "settle" image (cake layers bake, ice freezes into the floe, embers cool to obsidian).

---

## 6. Contradictions found and flags

Established = `design/levels/meadow.md` unless stated. **Nothing was changed to resolve these**; each lists a suggested fix and an owner.

| # | Conflict | Established | Suggested fix (owner) |
|---|---|---|---|
| C1 | biome-bible §2.1 Meadow story: biome-stories says the Miller tosses mushrooms; biome-stories beat 10 says he "winds up gusts, belt and mushrooms" | 10 = belt + gust + flip; mushrooms dropped (meadow.md, layout.md) | Update biome-stories beat 10 and mini-story line 3 (narrative-director) |
| C2 | biome-bible §2.2–2.10 casts, weathers and finales (Gumdrop / Sprinkle Shower, Kraken, "Pickaxe Pip" in Cave, Ice race, Forest escape...) vs biome-stories (Mallow / Gumdrop hail, Admiral Crab, Nugget, Ice escape, Forest transformation) | biome-stories (user decisions) + candy layout | Re-sync the biome bible (world-builder + narrative-director) |
| C3 | biome-bible §4 "Critter's ears", "Meadow critter" as a Candy/Forest visitor, Forest T1 "meadow critter cameo" vs "Mascots own their biomes; Pip is Meadow only" | biome-stories (user decision) | Strike the Meadow-critter visitor lines; WO02 visits need a narrative-director call |
| C4 | biome-stories running gag "the duck hides under **every** island" vs meadow.md "hidden in 01 and 02" | meadow.md for the Meadow | Collectible duck only in 01–02; whether a non-collectible duck appears elsewhere is open (narrative-director) |
| C5 | biome-stories bonus "Pip sits in the basket and dodges each drop; failure spills the picnic" vs meadow.md ants and 60 s clock | meadow.md | Update biome-stories bonus line (narrative-director) |
| C6 | biome-stories mini-story: Pip begs for "a bridge"; no Meadow level builds a bridge (H3's plank is dressing) | meadow.md | Drop "a bridge" or read it as H3's plank (narrative-director) |
| C7 | `level-data-definition.md` AC 9: meadow_10 has "Conveyor Floor, Wind and **Spawned Objects**" | meadow.md: Conveyor + Wind + **Gravity Flip** | Update AC 9 (game-designer) |
| C8 | `level-data-definition.md` AC 11: every Meadow level's median 5–15 min | meadow.md: 01, 02, 06, 08, B short on purpose | Update AC 11 (game-designer) |
| C9 | `block-art-sets.md` Sets table: "Meadow (gummy jelly, MVP)" vs the same file's theme-set table and review decision 4 (turf over soil) | the later decision in the same file (turf over soil); this brief follows it | Fix the Sets row (art-director; read-only here) |
| C10 | The brief asked for lore keyed by `mechanics-catalog.md` ids, but the catalog only maps a few of the Meadow's atoms (B3, B5, P2, §6 Trim; twists and M1–M4 live in other GDDs) | module atom ids are what the recipes and JSON use | §4 is keyed by atom id with the catalog id alongside. Confirm the database key (game-designer) |
| C11 | Not a contradiction, a readability risk: meadow.md calls 02 a "stone burrow", but its starter layers clear like blocks | rules: starter blocks are blocks | Starter blocks use the normal block look; the stone is the island body only (art-director) |
| C12 | layout.md names Pip's catch WO06 with an older trigger ("lock over a covered hole") | meadow.md: WO11, the refined trigger | Update layout.md (level-designer) |

**Flags (no contradiction, a decision is needed)**
- **F1 Day cycle** (§1): three-day arc vs a single day. Narrative-director.
- **F2 Flip presentation** (09, 10): does the diorama turn over (the underside needs dressing as a "second top", and the Miller and mill need an upside-down state) or only the stack? Game-designer + tech-artist; it changes the 09/10 asset list.
- **F3 Provisional mill mechanisms** (spores from the bellows, mist from the chimney, flour-paste dew, the lever rope): story-flavour only, no mechanical effect. Narrative-director approval.
- **F4 The Miller's hidden picnic blanket** (10): a story seed for his rematch. Narrative-director.
- **F5 Content skins (E5) belong to the biome kit, not the level scene**, so a mushroom looks the same in 04 and H2 and on player levels. Confirm with the tech lead that board-content looks come from `biomes/meadow.json`, not from the scene.
- No gameplay implications were introduced, so nothing goes to game-designer beyond C7, C8, C10 and F2.
