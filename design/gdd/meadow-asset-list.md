# Meadow MVP Asset List: Pip's Picnic

> **Status**: Draft v1 (art-director, 2026-10-10), for creative-director sign-off (MVP plan phase 1)
> **Owned By**: art-director. Built by technical-artist in live Blender (MCP), reviewed by art-director (phase 2)
> **Sources**: `production/orchestration/meadow-mvp-plan.md`, `design/levels/meadow.md` (wins every conflict), `production/levels/meadow/world-and-scenes.md` §2–3 (kit ids B/I/C/E/A), `production/levels/meadow/scene-build-sheets.md` (role names, positions), `design/art/art-bible.md`, `design/art/block-art-sets.md`, `design/gdd/piece-set.md` (face motifs), `assets/source/blender/SPEC.md`, `SPEC_looks.md`, `LICENCES.md`, `assets/data/credits.json`
> **MVP scope**: title + island map + Meadow 01–10 + bonus. H1–H3 assets are listed only where they reuse MVP items; anything H-only is out of scope.

**Every entry, number and source below is a tunable default**, not a rule. Swap a source, merge two ids or drop a "should" item whenever it helps; log the change in §10.

---

## 0. How to read this list

### 0.1 Naming (SPEC.md, art bible §8)
`prefix_scope_name_variant` + optional map suffix (`_alb`, `_nrm`, `_msk`). Prefixes: `blk_`, `env_meadow_`, `prp_meadow_`, `chr_`, `ui_`, `vfx_`. One Blender `EXPORT` child collection per id; the collection name is the file name. Additions used here:
- `prp_shared_` for props reused across biomes (rubber duck, picnic basket).
- `chr_meadow_` for Meadow-only critters; `chr_pip`, `chr_miller`, `chr_wizard` are unique game-wide.
- Animation clips live inside the character `.glb` as glTF actions named `<clip>` (e.g. `idle`, `cheer`), not as separate files.
- Export folder: `assets/models/meadow/` (plan phase 2); characters in `assets/models/characters/`; UI in `assets/ui/meadow/`; VFX in `assets/vfx/`. Folder layout is the technical-artist's call.

### 0.2 Columns
| Column | Meaning |
|---|---|
| **Used in** | Level numbers (01–10, B), **Map** (island-map menu / title), **Skit** (intro/payoff skits) |
| **Pri** | **M** = MVP must (the level, story beat or screen does not read without it; world-and-scenes **[G]**). **S** = MVP should (charm; ship a proxy if late; **[P]**) |
| **Source** | **PH** Poly Haven (CC0) · **PP** Poly Pizza (CC0 or CC-BY, per model) · **BK** BlenderKit add-on (per-asset licence) · **G3D** Blender MCP `generate_3d` · **HM** hand-model in Blender · **R** render/derive from another id · **SH** shader/procedural (no source file) |
| **Search** | Terms to type into that library first; second term is the fallback |
| **Restyle** | What to change beyond the standard pass **R0** (below) |
| **Tier** | Budget tier (§0.4) |
| **Anim** | Clips, or `—` |
| **Licence** | What to log (§0.5) |

### 0.3 R0, the standard restyle pass (applies to every imported model)
1. **Scale and pivot**: 1 Blender unit = 1 cell; base on z = 0; transforms applied (SPEC spatial contract).
2. **Cute proportions**: inflate and round: bigger heads, shorter limbs, thicker stems, soft bevels, no thin spikes. Bring props in line with the cute reference style.
3. **Simplify**: merge parts, decimate flat regions, delete hidden faces and interior geometry.
4. **Hand-painted albedo only**: strip PBR maps (roughness/metal/normal stay at most as a bake input). Bake soft top-down light + AO into the albedo (art bible §8 trade-off 5); low-frequency strokes, quieter near the board.
5. **Palette**: Grass biome palette (sky `#8F9AD8`, moss `#7E9C5E`, brick `#A88468`), world ≤ about 40% saturation. Never use the reserved hues on world or props: buff cyan 186° ±25°, debuff magenta 322° ±25°, hazard orange `#FF6A13`, reward gold `#FFC83D`, danger red `#F23A3A`.
6. **Matte**: no gloss window, no bevel-plus-cube-size combination (that look belongs to blocks; art bible §3).
7. **Outline**: dark neutral (not hue-tinted). Live inverted hull on large island meshes and characters only; painted outline elsewhere (art bible §8 trade-off 4).
8. **Log the licence** before export (§0.5).

### 0.4 Phone budget tiers (guide targets, not gates)
The art bible removed hard budgets on 2026-10-09 ("build for the look first; profile on device"). These are **starting guides** for Android mid-range (Adreno 6xx / Mali-G7x, Mobile renderer, 60 fps) so the technical-artist has a target; on-device profiling overrides them.

| Tier | Use | Tris (guide) | Texture (guide) | Rig (guide) |
|---|---|---|---|---|
| **H** hero character | wizard, Pip, Miller | 4–8k | 1 × 1024² albedo, shared toon ramp | ≤ 40 bones, + shape keys for face/hat |
| **C** critter | friends, frog, owl, birds, snail, bees | 0.3–2k | shared critter atlas 2048² (≈ 256² slot each) | ≤ 10 bones, or transform-only bob/flap |
| **L** landmark | mill near / mid / far | near 3–6k · mid ≤ 1.5k · far = card | 1024² | sails as separate nodes (no skinning) |
| **I** island | one per level | 2–6k body + tiles | shared Meadow terrain atlas 2048² + 512² tile set | — |
| **P** prop | rim and level props | 50–800 | shared Meadow prop atlas 2048² | — or node transform |
| **K** card | sky/hill/cloud cards, far mill | 2–20 (quads) | 1024×512 painted PNG with alpha | — |
| **U** UI | icons, frames | — | 256² painted source, shipped 128² in an uncompressed UI atlas (art bible §8 trade-off 6) | — |
| **V** VFX | particle textures, flipbooks | — | 128–512² greyscale (tinted in shader), flipbook ≤ 4×4 | — |

**Scene guide**: ≤ about 150k tris on screen, ≤ about 100 draw calls, ≤ about 60 MB VRAM for one level. Atlas everything that sits in the same level. Mesh LOD: off on blocks (art bible §8), on for islands/props if profiling needs it.

### 0.5 Licence handling
| Source | Licence | Must do |
|---|---|---|
| PH | CC0 | Row in `assets/source/blender/LICENCES.md`. Credit optional; add to `assets/data/credits.json` anyway (goodwill, traceability) |
| PP CC0 (e.g. Quaternius, Kenney) | CC0 | LICENCES.md row; credits.json entry recommended |
| PP CC-BY | CC-BY 3.0/4.0 | LICENCES.md row **and** a credits.json entry with `author`, `licence`, `source` URL, `files` = shipped path. The in-game credits screen must show "Title by Author (CC-BY), via Poly Pizza". Modifications allowed; note "modified" |
| BK | BlenderKit Royalty Free (free or paid plan) | LICENCES.md row with asset_base_id + author. Ship only our **own bake/export**, never the raw .blend or texture files (SPEC_looks rule). **Reject "Editorial" licence assets.** |
| G3D | Generator provider's terms | LICENCES.md row: provider, prompt/image, date, account. **Confirm commercial rights for the account tier before shipping** (open question 1) |
| HM, R, SH | Ours | No external entry |

`credits.json` entry shape (existing schema): `{"name", "author", "licence", "source", "files": [...]}`.

---

## 1. Characters

| Id | What | Used in | Pri | Source | Search | Restyle (beyond R0) | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `chr_wizard` | **Player avatar**: small kindly wizard on a cloud; cone hat, big beard, wand. Base for every biome costume and multiplayer robe/emblem | all levels, Map (cursor), Skit, results | M | **HM** (kitbash primitives: cone hat, metaball cloud, beard blob, wand). Optional BK cloud as a sculpt start | BK: "cartoon cloud", "stylized cloud" | Two shapes must read at 48 px. Hat and robe on separate material slots (player colour, emblem decal). Beard hides the mouth; brows + eyes carry emotion. Cloud is one soft matte shape | H | idle bob, cast (drop a piece), cheer, dismay, shock, float-travel (map), point (map hover), win stamp; hat droop/perk shape keys | ours |
| `chr_wizard_meadow` | Meadow costume: straw hat band + daisy on the hat; slot for the keepsake | all levels, Map | S | **R** of `chr_wizard` (material/accessory variant) | — | Accessory nodes only; silhouette unchanged | H | shares `chr_wizard` | ours |
| `prp_meadow_keepsake_windmill` | Tiny windmill ornament for the wizard's hat (Meadow keepsake) | 10 payoff, Map, results | M | **R** from `env_meadow_mill_near` (decimated) or **HM** | — | ≤ 0.25 of the hat height; sails spin slowly | P | sail spin loop | ours |
| `chr_pip` | **Pip the harvest mouse**: tiny, brave, round, oversized ears, long tail | 01–10, B, Map (cameo), Skit | M | **G3D** from a painted front/side concept (image-to-3D preferred over text), then retopo + rig. Fallback **HM** kitbash (sphere body, disc ears, cone snout) | Fallback PP: "mouse", "rat" (Quaternius CC0) for proportions only | Bigger head (≈ 45% of height), short limbs, warm harvest-mouse orange-brown kept ≥ 25° off hazard orange and desaturated. Hands able to hold the basket. Retopo to clean quads for squash and stretch | H | idle, point, catch (leap, ≈ 300 ms), cheer, cover-eyes, sneeze, stuck (taffy feet), hang (from root), climb, water, bounce, dig, pat, tiptoe, shrug, "nope" wobble, sit-on-lid, somersault, ears-flat shape key | G3D (Q1) |
| `prp_shared_picnic_basket` | Pip's picnic basket, twice Pip's size | 01, 07, 10, B, Skit | M | **PP** | PP: "picnic basket", "basket" | Chunky wicker painted, not modelled strands; lid as a separate node; chequered cloth tuft | P | lid open/close (node) | per model |
| `chr_miller` | **The Miller**: flour-dusted badger, apron, cap; smug but secretly lonely | 03–10 (backdrop → boss), Skit, Map (on Mill Hill) | M | **G3D** from a painted concept, retopo + rig. Fallback **HM** kitbash | Fallback PP/BK: "badger" for proportions | Pear body, stripe mask readable at 48 px (silhouette + stripe). Two looks via vertex colour/material param: normal and **floured** (white, ears to tail). Lonely beat needs a readable sad pose (droop, small) | H | crank, lever pull (giant), cheer, sulk, laugh, dance (roof), bonk (fall into flour), shake fist, stomp off, nap, bellows pump, **lonely** sit, **invited** (perk up, accepts) for the end-of-Meadow redemption | G3D (Q1) |
| `chr_miller_silhouette` | Tiny Miller cut-out for far/mid mill views | 03–09 | M | **R** render of `chr_miller` poses to cards | — | Flat dark-neutral silhouette, 3–4 pose cards (crank, lever, laugh, nap) | K | card swap | ours |
| `chr_meadow_friend_vole` · `_shrew` · `_hedgehoglet` | Three sleepy friends in nightcaps (species provisional) | 02, 10 payoff picnic, Skit | M | **PP** (CC0 animal packs) then kitbash; else **G3D** (one call each) | PP: "hedgehog", "mouse", "hamster"; BK: "cute hedgehog" | Three clearly different silhouettes (round / long-snout / spiky) at phone size. Same eye style as Pip so they read as one cast | C | sleepy idle, lie-in-bed, snore (breathing scale), stretch | per model |
| `prp_meadow_nightcap` | Nightcap (×3 colour variants, desaturated) | 02 | M | **HM** (cone + pompom) | — | Hangs on pocket edges outside the play cells | P | droop wiggle (node) | ours |
| `chr_meadow_frog` | Pond frog on a lily pad | 04 | S | **PP** | PP: "frog" | Wide eyes, matte green kept ≥ 25° off lime piece hue; desaturate | C | idle blink, flinch, croak | per model |
| `chr_meadow_owl` | Half-asleep owl on a stump | 07 | S | **PP** | PP: "owl" | Round, half-lidded eyes | C | doze bob, one-eye-open | per model |
| `chr_meadow_mother_bird` | Mother bird fussing at empty nests | 09 | S | **PP** | PP: "bird", "robin" | Plump, stubby wings | C | fuss hop, flap | per model |
| `chr_meadow_sparrow` | Sparrows on sacks; scatter on flip | 09, 10 | S | **R** of `chr_meadow_mother_bird` (smaller, brown) | — | — | C | perch idle, scatter fly | per model |
| `chr_meadow_snail` | Snail with a shiny trail (trail = decal) | 08 | S | **PP** | PP: "snail" | Shell spiral painted, not modelled | C | slow slide (transform) | per model |
| `chr_meadow_bee` · `_butterfly` · `_dragonfly` · `_kite_bird` | Ambient backdrop life | 01, 03, 04, 05, 06 | S | **PP** | PP: "bee", "butterfly", "dragonfly", "bird flying" | Tiny; backdrop only (≥ 8–10 cells from the board); wings as flat cards | C (≤ 300 tris) | flap loop + path follow | per model |
| `chr_meadow_ant` · `chr_meadow_ant_scout` | Ants with tiny forks; scout whistles. The ant line is the bonus level's visible clock | B (H2 reuse) | M | **PP** then kitbash a fork | PP: "ant", "insect" | Ant line is instanced (MultiMesh), so keep ≤ 300 tris; fork as a separate node | C | walk loop, bonk, carry-basket (B fail), scout whistle | per model |
| `prp_shared_rubber_duck` | Hidden rubber duck collectible (SE05); tap target | 01, 02 (underside socket), Map (collectible counter) | M | **PP** | PP: "rubber duck", "duck toy" | Classic yellow, desaturated enough to stay off reward gold; a tiny squeak squash | P | squash on tap, collect hop | per model |

**Why these sources**: the wizard is two primitives and is the identity asset reused in every biome and by four players, so a clean hand-built mesh with controllable material slots beats a generated one. Pip and the Miller are organic, expressive and unique, which is where `generate_3d` saves the most time (plan default); both still need a manual retopo and rig, because generated meshes do not deform well for squash and stretch. Small critters are well covered by CC0 low-poly packs on Poly Pizza.

---

## 2. Islands (10 + bonus)

Every island is assembled from the shared kit (§3: tiles, body strata, underside, rim props) plus the unique pieces in its row. Positions and clear zones are in `scene-build-sheets.md`. The island mesh itself is **HM**, built from the kit modules; textures start from the PH ground textures already in `LICENCES.md` (`leafy_grass`, `brown_mud_02`, `moss_wood`) used as relief only, then repainted.

| Id | What (unique parts) | Used in | Pri | Source | Search (for the unique parts) | Restyle | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `env_meadow_island_01_seedplot` | Round soil plot (radius ≈ 6), turf only on the rim ring; underside duck socket (−x) | 01, Map | M | HM + kit | PH texture: "brown mud", "soil" | Bare soil inside the clear zone is ≈ 15% lighter/cooler than the turf (R1) | I | — | PH CC0 (logged) |
| `prp_meadow_seed_mound` | Seed mound with 5 growth stages (mound, 1–4 leaves) + `prp_meadow_sunflower` payoff | 01, H1 reuse | M | HM (mound) + **PP** sunflower | PP: "sunflower", "flower" | Mound ≤ 0.8 cell high; sunflower petals desaturated yellow, ≥ 25° off reward gold; basket hook on the stem | P | stage swap; sunflower shoot-up (scale) | per model |
| `env_meadow_island_02_burrow` | Cut-away burrow: stone-and-root chamber walls on −x, −z, +x (≤ 1.5 cells high, ≥ 4 cells from board); round `burrow_window` (3 cells) in the back wall | 02, Map | M | HM + **PH** rock texture | PH: "rock", "cobblestone"; BK: "stylized stone wall" | Stone is island body only; starter blocks stay normal blocks (world-and-scenes C11). Warm candle interior must not tint the board | I | — | PH CC0 |
| `prp_meadow_root_arch` · `prp_meadow_candle` | Root arches on the back wall; candle on a wall shelf | 02 | S | **PP** (candle), HM (roots) | PP: "candle" | Candle flame is a VFX card (`vfx_candle_flame`), no real transparency | P | flame flicker (VFX) | per model |
| `env_meadow_island_03_lane` | Long 8×4 lane, uphill −x rising 0→2 cells from x −14..−5; flat board; low `prp_meadow_stone_fence` (1 cell) on +x | 03, Map | M | HM | PP: "stone wall", "fence stone" | Uphill rise starts at x < −8 so it never cuts the yaw-3 view | I | — | per model |
| `env_meadow_island_04_pondring` | Ring islet around a 3×3 lily pond; `prp_meadow_pond_water` at y −0.4; `prp_meadow_lily_pad` ×3; `prp_meadow_reed_clump`; `prp_meadow_stepping_stone` | 04, Map | M | HM + **PP** (lily pad, reeds) | PP: "lily pad", "reeds", "cattail" | Water: desaturated blue-green, clearly not a piece hue and not buff cyan (stay ≤ 170° or ≥ 211°, low saturation); glitter is a shader | I | water ripple (SH) | per model |
| `prp_meadow_bellows` | Bellows on the mill's side (decor) | 04 | S | **PP** / HM | PP: "bellows", "accordion" | — | P | pump (node) | per model |
| `env_meadow_island_05_hilltop` | Small bare hill (radius ≈ 6.5); lots of sky; `prp_meadow_sign_post` 2 cells high | 05, Map | M | HM | PP: "sign post", "wooden sign" | The goal sign ribbon is `prp_meadow_goal_sign` (§3); the post stays outside the board's x range | I | sign sway (node, light) | per model |
| `prp_meadow_spyglass` · `prp_meadow_giant_fan` | Pip's spyglass; the Miller's giant fan seen through it (payoff reveal) | 05 Skit | S | **PP** | PP: "telescope", "spyglass"; PP: "fan", "windmill fan" | Fan only in the skit shot; can be a card | P / K | fan spin | per model |
| `env_meadow_island_06_gardenbed` | Tidy 8×8 garden bed; `prp_meadow_wood_edging` frame (0.3 high) | 06, Map | M | HM + **PH** wood texture | PH: "wood planks"; BK: "stylized wood plank" | Bed soil plain; flower-outline overlay is a decal (§3), not scene geometry | I | — | PH CC0 |
| `prp_meadow_flower_bush` · `prp_meadow_watering_can` · `prp_meadow_vase` · `prp_meadow_bouquet` | Rim flower bushes (≤ 1 cell, corners); watering can; empty vase; payoff giant bouquet | 06, Skit | S (bush, can, vase) / M (bouquet = payoff) | **PP** | PP: "flower bush", "watering can", "vase", "bouquet" | Bush flowers desaturated pinks/yellows so they never read as target cells | P | bouquet pop-up (scale) | per model |
| `env_meadow_island_07_hollow` | Damp dip; `prp_meadow_moss_bank` ring rising 0→1.5 cells from radius 7 to 10; `prp_meadow_stump` | 07, Map | M | HM + **PH** moss texture | PH: "moss"; PP: "tree stump" | Moss banks < 1.5 cells; fog banks are VFX cards (§7) | I | — | PH CC0 |
| `prp_meadow_moss_clump` · `prp_meadow_dew_cluster` | Moss clumps; small dew droplet clusters | 07, 08 | S | HM | — | Dew is opaque with a painted glint (no transparency) | P | glint (VFX) | ours |
| `env_meadow_island_08_lawn` | Small glittering lawn (radius ≈ 7); `prp_meadow_dewdrop_big` (Pip stuck) | 08, Map | M | HM | — | Dew sparkle shader on the rim only, never in the clear zone | I | dew sparkle (SH) | ours |
| `env_meadow_island_09_tree` | Islet with `prp_meadow_nesting_tree` (≈ 5 cells, trunk radius ≤ 1, crown above y 5) at (−8, −8); `prp_meadow_nest_empty` ×4; `prp_meadow_branch_pile`; `prp_meadow_fallen_leaf`; **flip-state underside** (pending F2) | 09, Map | M | HM + **PP** tree as a start | PP: "tree", "oak tree"; PH: "bark" texture | Tree crown simplified into 3–5 painted blobs; nests readable as empty bowls. **No egg props** (eggs are board content). If F2 = whole diorama flips, the underside gets a flat soil cap and roots dressed as a "second top" | I | crown sway (SH), flip (scene) | per model |
| `prp_meadow_lever_rope` | Rope from the mill lever to the islet | 09 | S | HM (curve) | — | Thick, cartoon rope | P | tug wiggle | ours |
| `env_meadow_island_10_millyard` | Mill yard on Mill Hill: packed-earth tiles, yard 6 cells past the board, mill footprint on +x; **flip-state underside** (pending F2) | 10, Map (as Mill Hill) | M | HM | PH: "dirt path", "gravel" textures | Packed earth lighter than the belt; the belt is `prp_meadow_mill_belt` (§3) | I | flip (scene) | PH CC0 |
| `prp_meadow_flour_sack` · `prp_meadow_crate` · `prp_meadow_cart` · `prp_meadow_miller_blanket` | Yard dressing; hidden one-badger blanket on the roof | 10 | S (M: sacks frame the yard) | **PP** | PP: "sack", "flour bag", "crate", "cart", "wheelbarrow" | Crates must not look like blocks: rounded, matte, not cube-sized, plank texture painted | P | — | per model |
| `env_meadow_island_bonus_picnic` | Tiny islet under a chequered `prp_meadow_picnic_cloth`; the 4×4 board is the open `prp_meadow_hamper` (rim 0.4 high at the margin edge, lid separate) | B, Map (hidden until 20 stars) | M | HM (cloth, hamper) | PP: "picnic", "basket" | Cloth checker < 10% value difference; board floor plain | I | lid slam (node) | per model |
| `prp_meadow_plate` · `_fork` · `_sandwich_crumbs` · `_thermos` | Picnic dressing at the rim (≥ 5 cells out) | B, 10 payoff | S | **PP** (Kenney Food Kit or similar CC0) | PP: "plate", "fork", "sandwich", "thermos" | Low, rounded, desaturated | P | — | per model |
| `prp_meadow_picnic_cloth` | Chequered cloth: Pip's picnic cloth in 04 (floating), 10 (rolling on the belt), B (island cover) | 04, 10, B, Skit | M | HM (plane + cloth sim baked to 2–3 poses) | — | Low-contrast checker; desaturated red/cream, ≥ 25° off danger red at full | P | float bob, roll (shape keys) | ours |

---

## 3. Shared Meadow props kit

Ids follow world-and-scenes §3 kit numbers (I, E). The board content skins (E5) are **biome-kit** assets read from `biomes/meadow.json`, not level-scene props (world-and-scenes F5), so a mushroom looks the same in 04, H2 and player levels.

### 3.1 Blocks
| Id | What | Used in | Pri | Source | Search | Restyle | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `blk_meadow_budding_clover_<shape>` | The Meadow block set: turf over a soil band, pastel tint per piece, one hero prop (sprout/flower) on one cube's top face. Full 67-shape bank; MVP needs at least the 12 Meadow shapes (I O T L S Tripod Screw-L/R Big Cube Chair Duo Tri-Corner) | all levels | **M** if Meadow ships its own set (Q4), else S | existing `SET_meadow_budding_clover` in `blocks.blend` (copy of the default set) | already sourced: PH `leafy_grass`, `brown_mud_02` | Per block-art-sets: reserved hues off pieces, 5–6 greyscale lightness steps, face motif kept clean at the face centre | — (MultiMesh) | landing squash (shader) | PH CC0 (logged) |
| `blk_motif_atlas_msk` | Face-motif mask atlas (see §6.3), shared by every set | all levels | M | HM (2D, painted) | — | Embossed in the piece's own tone; same atlas feeds the UI symbols | U | — | ours |

### 3.2 Island kit (I1–I4)
| Id | What | Used in | Pri | Source | Search | Restyle | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `env_meadow_tile_turf` · `_soil` · `_packed_earth` · `_burrow_floor` | Flat board tiles (≤ 1/5 cube height) with grid lines; work for any mask (square, lane, ring) | all levels | M | HM + **PH** textures as relief | PH: "leafy grass", "brown mud", "dirt" | ≈ 15% lighter/cooler-neutral than the surrounding turf (R1). Grid lines thin, dark neutral | I (512² set) | — | PH CC0 |
| `env_meadow_body_edge` · `_corner` · `_inner_corner` | Body strata modules: turf lip, soil band, pebble band; organic edges | all islands | M | HM | — | Irregular, organic silhouette; dark neutral live outline on the island hull | I | — | ours |
| `env_meadow_underside_roots` · `env_meadow_underside_duck_socket` | Underside: roots, dangling clover, a soil drip; socket variant for the duck | all islands; socket 01, 02 | M (socket) / S (roots) | HM + **PP** roots as a start | PP: "roots", "tree roots" | Roots chunky, few; clover as cards | I | clover dangle sway (SH) | per model |
| `prp_meadow_daisy_clump` · `_clover_tuft` · `_grass_tuft` · `_dandelion_clump` · `_pebble` · `_fence_stub` | Rim props: low, rounded, corners only. **No mushrooms or eggs near the board** | all levels | S (M for 03 dandelions: they telegraph the gust) | **PP** (CC0 nature packs: Quaternius, Kenney) | PP: "daisy", "clover", "grass", "dandelion", "rock small", "fence post" | Heights ≤ 0.5 cell; dandelion heads < 0.5 cell; 2–3 variants each by rotation/scale, not new meshes | P | grass bend (SH, gust presenter E1) | per model |
| `prp_meadow_mushroom_backdrop` | Backdrop mushrooms (Pip bounces on them), ≥ 12 cells away | 04 | S | **R** of `prp_meadow_content_mushroom` without the face | — | Larger, desaturated, no face, so it never reads as board content | P | squash (node) | ours |

### 3.3 Event and content presenters (E1–E7)
| Id | What | Used in | Pri | Source | Search | Restyle | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `prp_meadow_content_mushroom` | SP19 mushroom with a face; fills one cell; squeaks on clear | 04 (H2) | M | **PP** then add face; or HM | PP: "mushroom" | Organic and matte with eyes (living object, art bible §5); fits inside one cell; not glossy, not cube-like. Cap colour off the piece palette and off hazard orange | C | pop-up (overshoot), grin, squeak squash, bow | per model |
| `prp_meadow_content_sprout` | SP22 growing sprout cube stack (stalk segment + leafy top) | 06 (H1) | M | HM | — | Stalk cube reads as plant, not block: matte, rounded, leaf top | P | grow one cube (scale overshoot) | ours |
| `prp_meadow_content_egg` · `prp_meadow_content_chick` | SP21 egg (cracking stages ×3) and the chick it hatches into | 09 | M | **PP** egg/chick + HM crack stages | PP: "egg", "chick", "baby bird" | Egg pale speckled, matte; chick round fluff ball with eyes; both fit one cell | C | wobble, crack (stage swap), hatch pop, chick hop | per model |
| `prp_meadow_content_puff_head` | SP28 dandelion seed-head hero prop on the puff piece's top cube | 03 | M | HM (sphere of seed cards) | — | ≤ 0.35 of a cube (block-art-sets hero-prop rule); white fluff, sparkle sparingly | P | burst on landing (VFX `vfx_seed_fluff`) | ours |
| `prp_meadow_content_ant` | SP31 ant content skin (H2 only) | H2 | out of MVP | **R** of `chr_meadow_ant` | — | — | C | munch | per model |
| (SP26 fog ghost) | Fog ghost is a **shader state** on the normal piece (mist dissolve), not a model | 07 | M | **SH** (technical-artist) + `vfx_fog_wisp` | — | Must stay a cube silhouette; mist on the surface only | — | mist drift | ours |
| `prp_meadow_goal_sign` | E6 wooden goal sign/ribbon at the goal layer (GO02) | 05 | M | HM | PP: "wooden sign" | Wood frame trim style (art bible §7); text-free plank with a flag | P | sway, "reached" bounce | ours |
| `vfx_meadow_flower_outline_decal` | E6 flower-outline target overlay (GO03) as a decal/shader on the bed | 06, B | M | **SH** + painted edge texture | — | Glow outline distinct from soil and bed flowers; not buff cyan, not reward gold | V | filled-cell bloom | ours |
| `prp_meadow_mill_belt` | E4 mossy drive belt surface with rollers (board floor in 10) | 10 | M | HM | PH: "moss" texture | UV-scrolled moss stripes show direction; rollers at the ends; belt colour distinct from packed earth and from pieces | I | UV scroll per shift (SH) | PH CC0 |
| `prp_meadow_story_stage` | E7 generic "advance one stage" hook | 01, 10 | — | **no asset** (logic node); it swaps the stage meshes listed above | — | — | — | — | — |

---

## 4. Sky and backdrop (B1–B5)

| Id | What | Used in | Pri | Source | Search | Restyle | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `env_meadow_sky` | Sky dome gradient drawn by a shader (no texture; avoids ETC2 banding, art bible §8 trade-off 6); per-preset top/horizon colours | all levels, Map, title | M | **SH** | — | ≤ 40% saturation; values from the build sheets per level | — | slow hue drift (off in reduced motion) | ours |
| `env_meadow_card_cloud_a…d` | 4 painted cloud cards | all, Map | M | **HM** (painted 2D) | ref only: Kazuo Oga gouache skies | Soft, low contrast, broad strokes; no hard edges; one top-left light | K | slow drift | ours |
| `env_meadow_card_hill_a…c` | 3 rolling-hill cards, distance-faded | all | M | **HM** (painted 2D) | — | Lowest saturation and contrast in the scene (eye-order rank 7) | K | — | ours |
| `env_meadow_islet_mid_s` · `_m` · `_l` | Mid-ground turf islets, desaturated | all, Map | S | **R** of island kit modules (decimated, baked) | — | Desaturate ≈ 30%, fade toward the sky colour | P | slow bob | ours |
| `env_meadow_mill_near` | Full windmill on Mill Hill: three **detachable** sails (boss health), door, shutter, roof perch, giant lever socket, chimney | 09, 10, Map (centre), Skit | M | **PP** windmill as a start, then HM | PP: "windmill", "mill"; BK: "stylized windmill" | Squat, cute, slightly crooked; painted wood + plaster; sails on separate nodes (`sail_1..3`); roof flat enough for the Miller; floured-door dust patch | L (near) | sail idle / spin / gust spin-up, sail knock-off (×3), shutter slam, door puff, (F2) upside-down state | per model |
| `env_meadow_mill_mid` | Mid-distance mill (decimated near, baked) with Miller silhouette slot | 03, 04, 06, 07, 08, B | M | **R** of `mill_near` | — | ≤ 1.5k tris, single atlas; silhouette slot node | L (mid) | sails spin | ours |
| `env_meadow_mill_far` | Far mill as a card + separate sail card | 01, 02 (through window), 05 | M | **R** render of `mill_near` | — | Flat card, distance-faded; sails a second card rotating | K | sail card spin | ours |
| `prp_meadow_giant_lever` | The Miller's giant lever (flip trigger) | 09, 10 | M | **PP** / HM | PP: "lever" | Oversized, chunky handle, readable at distance | P | pull (node) | per model |
| `env_meadow_light_<preset>` | Lighting presets: morning, noon, afternoon, golden, dawn-fog, sunrise, interior-candle (Godot `Environment` + light `.tres`) | all | M | **SH** (Godot resources; build sheets give values) | — | Art-bible mood states layer on top; count depends on F1 (Q3) | — | sunrise rise (08) | ours |
| (lookdev) | HDRI for Blender lookdev only; never shipped | Blender | — | **PH** (already logged: `studio_small_08`); optional PH outdoor sky | PH: "kloofendal", "meadow" HDRI | Lookdev only | — | — | PH CC0 |

---

## 5. Island-map menu art (title + Meadow map)

The map is a **diorama** (art bible §6: menus get high prop density, no play to protect). The cloud wizard floats between islets. **Two layouts**: the islet path must frame in portrait (vertical scroll) and landscape (horizontal pan), so the path winds on a diagonal S-curve and the camera pans, rather than placing islets for one aspect ratio.

| Id | What | Used in | Pri | Source | Search | Restyle | Tier | Anim | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `env_meadow_map_millhill` | Central Mill Hill with `mill_near`, the Miller on the roof (grumpy until Meadow is done, then at the picnic) | Map, title | M | **R** of `island_10` + `mill_near` | — | Higher density allowed; warm indoor/toy-shelf light (art bible §2 Menus) | I | sail spin, Miller idle swap | ours |
| `env_meadow_map_islet_01…10` · `_bonus` | 11 miniature islets, one per level, each a decimated bake of its level island with its signature prop (seed mound, burrow window, fence, pond, sign, bed, fog, dewdrop, tree, mill yard, hamper) | Map | M | **R** of each `env_meadow_island_*` (decimate + bake into one atlas) | — | ≤ 1.5k tris each; recognisable at ≈ 120 px; story-progress states: before/after (e.g. sunflower grown after 01 is won) | P | gentle bob; "unlocked" pop | ours |
| `prp_meadow_map_path_cloud` | Stepping-cloud path pieces between islets | Map | M | **R** of `chr_wizard` cloud mesh (small) | — | Puffs light up as levels are cleared | P | puff-in on unlock | ours |
| `ui_map_node_<state>` | Level node pin above each islet: locked, open, current, cleared, 1–3 stars | Map | M | **HM** (2D painted) or **R** (3D render) | — | Circle = item in the UI grammar, so use a **rounded-plate pin**; star = reward gold only | U | pop-in, current-level bounce | ours |
| `ui_map_lock` · `ui_map_star_gate` | Lock badge; "20 stars" gate badge for the bonus (number is HUD text, icon is a star + lock) | Map | M | **R** / HM | — | — | U | shake on tap while locked | ours |
| `env_title_backdrop` | Title screen: wizard on cloud over the Meadow cluster | title | M | **R** of map scene (same assets, different camera) | — | Logo space kept clear | — | slow orbit | ours |
| `ui_title_logo` | "Wacky Towers" logo: chunky stacked-block letters | title, store | M | **HM** (Blender 3D letters rendered to PNG, or 2D painted) | — | Letters may use the block look (it is not on the playfield); ink outline; two lockups (portrait stacked, landscape wide) | U (1024–2048 wide) | squash-drop intro | ours (font licence: Q5) |
| `ui_meadow_frame_*` | Wood frame 9-slice (plate, button pill, panel, banner) with grain, nails and short vine trim (≤ 10% of plate height); parchment insert | Map, HUD, results, settings | M | **HM** painted, **PH** wood as relief | PH: "wood planks" | Art bible §7: trim points away from the board and controls; dark neutral outer edge; parchment `#FFF4DE` interior, ink `#2E2433` | U | press squash (UI anim) | PH CC0 |

---

## 6. UI icon set

**Style rule for all icons** (art bible §7): small painterly prop, one ink outline, two tones + highlight, readable as a silhouette at ≈ 32 px, fitted to its container (circle = item, chevron = buff/debuff, triangle = hazard/warning, star = reward, pill = button). Icons avoid block shapes. Source for every row: **HM**, either painted 2D or (recommended) modelled as tiny Blender props and **rendered** with one shared toon light and outline, so icons match the 3D world exactly (Q6). Base silhouettes may be taken from CC0 packs (Kenney "Game Icons", CC0); CC-BY packs only with a credits entry. Tier **U** for all. Priority M unless marked.

### 6.1 Emote speech bubbles (wordless skits; icons, no text)
In-world billboards above Pip, the Miller and friends; sized ≥ 48 px on a phone; pop with a 110% overshoot.

| Id | Meaning / use | Who |
|---|---|---|
| `ui_emote_bubble_speech` · `_thought` · `_shout` | Bubble frames: speech (rounded), thought (cloud puffs), shout (jagged, **not** the hazard triangle) | all |
| `ui_emote_heart` | Love, thanks, friendship (10 redemption) | Pip, friends, Miller |
| `ui_emote_exclaim` | Surprise / "look!" | Pip |
| `ui_emote_question` | Confused / "where?" (07 basket) | Pip |
| `ui_emote_idea` | Bulb: "I know!" (05 draws the tower) | Pip |
| `ui_emote_zzz` | Sleeping (02 friends, 06 Miller nap, 07 owl) | friends, Miller, owl |
| `ui_emote_music` | Happy humming, snoring tune | Pip, friends |
| `ui_emote_anger` | Steam puff / scribble: grumpy | Miller |
| `ui_emote_laugh` | Laughing (squinting eyes + tears of joy; no text "HA") | Miller |
| `ui_emote_sweat` | Nervous drop (warning, Close Call) | Pip |
| `ui_emote_tear` | Sad | Pip, Miller |
| `ui_emote_star_eyes` | Amazed (wins, the sunflower) | Pip |
| `ui_emote_dizzy` | Spiral stars (09 flip payoff) | Pip, chicks |
| `ui_emote_lonely` | Tiny rain cloud over one small figure: the Miller's secret loneliness | Miller |
| `ui_emote_invite` | Picnic-blanket card / envelope: the invitation that redeems the Miller | Pip → Miller |
| `ui_emote_basket` · `_seed` · `_bed` · `_flower` | Object-wish icons for intro skits ("I want a…") | Pip |
| `ui_emote_wind` · `ui_emote_flour` | Gust swirl; flour cloud (the Miller's mischief) | Miller |

### 6.2 HUD, goals and event warnings
| Id | Use | Pri |
|---|---|---|
| `ui_icon_pause` · `_resume` · `_retry` · `_next` · `_map` · `_home` | Pause/results buttons (pill containers) | M |
| `ui_icon_star_empty` · `_full` · `ui_icon_star_stamp` | Star slots and the results stamp (reward gold) | M |
| `ui_icon_goal_layers` · `_height` · `_shape` · `_survive` | Goal plate icons: layers to clear, reach the sign, fill the outline, survive (sun dial) | M |
| `ui_icon_timer` · `ui_icon_sundial` · `ui_icon_ant_clock` | Timer; 08 sun dial; bonus ant clock | M |
| `ui_icon_warning` | Close Call / height warning (triangle) | M |
| `ui_icon_event_gust` · `_flip` · `_fog` · `_mushroom_spark` · `_belt` | Event telegraphs: arrow + wind, flip arrows + countdown ring, fog, sparkle, belt arrow | M |
| `ui_icon_pip_catch` | Pip's catch available / used (1 per level) | M |
| `ui_icon_duck` | Duck collectible found/not found | S |
| `ui_icon_tap_solid` | Fog-ghost "tap to make solid" hint | M |

### 6.3 Colourblind block symbols (face motifs)
The face motif is the colourblind backup and stays on every face at every difficulty (piece-set.md). One painted set feeds both the block mask atlas `blk_motif_atlas_msk` and the UI (settings preview, tutorial cards). Motifs from piece-set.md:

| Id | Motif | Shape | Pri (Meadow uses it?) |
|---|---|---|---|
| `ui_motif_bar` | bar | I | M |
| `ui_motif_ring` | ring | O | M |
| `ui_motif_cross` | cross | T | M |
| `ui_motif_halfmoon` | half-moon | L | M |
| `ui_motif_wave` | wave | S | M |
| `ui_motif_triangle` | triangle | Tripod | M (note: not the hazard triangle; embossed, in the piece's tone, never in a warning container) |
| `ui_motif_spiral_ccw` · `_cw` | spirals | Screw-L / Screw-R | M |
| `ui_motif_diamond` | diamond | Chair | M |
| `ui_motif_square_in_square` | square in square | Big Cube | M |
| `ui_motif_pips_2` · `ui_motif_pips_3l` | 2 pips; 3 pips in an L | Duo; Tri-Corner | M |
| `ui_motif_hourglass_l` · `_r` · `_step` · `_corner` · `_chevron3` · `_pips_1` · `_pips_3` | remaining motifs | Twist-L/R, Staircase, Tall Corner, Big Tripod, Mono, Tri-Straight | S (not in Meadow levels) |
| `ui_pattern_<family>` | Optional colourblind **pattern** overlay per family (stripes, dots, checks…) for the accessibility toggle | all families | S (Q7: is the motif enough, or do patterns ship in MVP?) |

### 6.4 Controls and settings (accessibility MVP)
| Id | Use | Pri |
|---|---|---|
| `ui_icon_rotate_spin` · `_tilt` · `_roll` | Rotation axes (3D arrows around a non-block shape, e.g. a ball) | M |
| `ui_icon_drop_soft` · `_drop_hard` | Drop buttons | M |
| `ui_icon_cam_left` · `_cam_right` · `_cam_mode` | Camera snap and camera-control type | M |
| `ui_icon_settings` · `_controls` · `_remap` · `_button_size` | Settings entries; control-scheme customisation; remap; button size | M |
| `ui_icon_colourblind` · `_reduced_motion` · `_haptics` | Accessibility toggles | M |
| `ui_icon_vol_music` · `_vol_sfx` · `_vol_ambience` · `_vol_master` | Separate volume sliders | M |
| `ui_icon_orientation` · `_lefthand` | Portrait/landscape hint; left-handed mirror | S |
| `ui_slider_knob` · `ui_toggle_on` · `_off` | Wood-and-parchment controls (frame family §5) | M |

---

## 7. VFX textures

All greyscale (tinted in the particle/shader), tier **V**, source **HM** (painted) unless marked; flipbooks ≤ 4×4. Particle counts per art bible §8 (≈ 150 confetti per clear, ≈ 500 alive). Reduced-motion mode must have a calmer variant (fewer particles, no flashes).

| Id | Use | Used in | Pri | Notes |
|---|---|---|---|---|
| `vfx_confetti_atlas` | Layer-clear confetti (tinted to the cleared pieces' colours); petal and leaf shapes mixed in for the Meadow | all clears | M | 8 shapes in one atlas |
| `vfx_sparkle_star4` | Small white four-point star (never gold) | drizzle spawn, dew, puff, wins | M | block-art-sets sparkle rule |
| `vfx_clear_flash_band` | Warm white flash along the cleared layer (≈ 0.3 s) | all clears | M | shader + soft gradient strip |
| `vfx_puff_soft` | Soft round puff flipbook (dust, flour, landing, cloud poof) | landings, flour, map, Miller bonk | M | one flipbook, tinted white for flour |
| `vfx_flour_cloud` | Big flour burst (boss bonk) | 10 | M | reuse `vfx_puff_soft` scaled + extra sheet |
| `vfx_petal` · `vfx_leaf` | Gust petal stream; leaf pop per clear (01) | 01, 03, 10 | M | |
| `vfx_seed_fluff` | Dandelion seed fluff (gust, puff split) | 03, 10 | M | |
| `vfx_gust_streak` | Wind streak lines for the gust telegraph | 03, 10 | M | not buff cyan; white/cream |
| `vfx_fog_wisp` · `vfx_fog_bank` | Fog ghost surface mist; rim fog bank cards | 07 | M | soft alpha; keep overdraw low (few large cards) |
| `vfx_water_ripple` · `vfx_splash` | Pond ripples, clear splash | 04 | M | |
| `vfx_spore_spark` | Sparkle marking the next mushroom cell | 04 | M | shares `vfx_sparkle_star4` shape, different motion |
| `vfx_dew_glint` · `vfx_sticky_splat` | Dew glints; sticky landing splat decal | 08 | M | splat is a decal, fades |
| `vfx_shockwave_ring` | Ring for item/debuff hits and the flip "whump" | 09, 10 | M | ring mesh + shader, not particles |
| `vfx_countdown_ring` · `vfx_arrow_flip` | Flip warning ring and side arrows (E3) | 09, 10 | M | world-space |
| `vfx_danger_vignette` · `vfx_height_line` | Danger edge vignette, pulsing height line | all rescue levels | M | **SH**; danger red, pulsing |
| `vfx_landing_ghost` | Landing ghost surface | all | M | **SH** |
| `vfx_eggshell` · `vfx_chick_feather` | Hatch burst | 09 | S | |
| `vfx_pollen_mote` · `vfx_butterfly_card` | Ambient backdrop particles | all | S | low density, backdrop only |
| `vfx_candle_flame` | Candle flame card | 02 | S | flicker off in reduced motion |
| `vfx_drizzle_glint` | Block-drizzle sparkle at the spawn zone | all | S | |
| `vfx_star_burst` | Results star stamp burst; 3-star fireworks (05 spyglass) | results, 05 | M | reward gold allowed here (UI moment) |
| `vfx_motion_trail_soft` | Pip's catch leap trail | 01–03 | S | |

---

## 8. Build order for the technical-artist

Ordered by what unblocks the MVP plan phases (3 core loop on meadow_01, 4 menus, 6 levels in the order 01 → 02, 05, 09, 10 → 03, 04, 06, 07, 08 → B). Greybox/proxy first everywhere, final paint in the same wave only if it is cheap. Every item is copied from a default, never overwritten (asset-team rule).

1. **Look-check rig** (Blender + Godot): a 1×1 grid ref, phone-size camera at the four yaw snaps, portrait and landscape frames, greyscale and CVD preview. Every later review uses it.
2. **Blocks**: export `blk_meadow_budding_clover_*` (12 Meadow shapes first, then the rest) and `blk_motif_atlas_msk` (Q4).
3. **Island kit**: tiles, body modules, underside + duck socket, sky shader, cloud/hill cards, lighting presets. Then `env_meadow_island_01_seedplot` + seed mound stages + `prp_shared_rubber_duck`. → unblocks phase 3.
4. **`chr_wizard`** (hand-model, rig, idle/cast/cheer/dismay) and core VFX (`vfx_confetti_atlas`, `vfx_clear_flash_band`, `vfx_sparkle_star4`, `vfx_puff_soft`, landing ghost, danger line/vignette).
5. **`chr_pip`** via `generate_3d` → retopo → rig → helper poses (idle, point, catch, cheer, cover-eyes). In parallel the HUD icon basics (§6.2 pause/stars/goals/warning, §6.4 controls).
6. **Mill**: `env_meadow_mill_near` (detachable sails, lever) → derive `_mid` and `_far`. **`chr_miller`** via `generate_3d` → retopo → rig (crank, lever, laugh, sulk, bonk) + floured variant + silhouettes.
7. **Island map + title** (§5) from the assets so far, with placeholder islets for unbuilt levels; wood frame 9-slice; settings/accessibility icons (§6.4). → unblocks phase 4.
8. **Prototype levels**: 02 burrow (+ friends, nightcaps, candle) → 05 hilltop (+ goal sign, sign post) → 09 tree island (+ eggs/chick, nests, lever rope; flip underside after F2) → 10 mill yard (+ belt, sacks, picnic cloth, keepsake windmill) with their content skins and VFX.
9. **Remaining levels**: 03 lane (+ dandelions, puff head, gust VFX) → 04 pond ring (+ mushroom content, water, frogs) → 06 garden bed (+ sprout, outline decal, bouquet) → 07 hollow (+ fog VFX, owl) → 08 lawn (+ dew, splat, snails) → B picnic (+ hamper, ants, dressing).
10. **Skit-only and emote assets**: the remaining Pip/Miller clips per skit script (lonely, invited, stomp-off), §6.1 emote bubbles, spyglass/fan, payoff props.
11. **Map polish**: islet before/after states, path puffs, Miller-at-the-picnic state.
12. **All "S" items** (ambient critters, pollen, flower bushes, mid-ground islets), then a performance pass on device.

---

## 9. Art-director review checklist

Each asset is reviewed in the look-check rig before it is marked done; a failed line goes back to the technical-artist with one concrete fix.

**Readability (art bible §1–3, build sheets R1–R5)**
- [ ] At phone size (1080p, portrait and landscape) the board and pieces read before anything else; the asset sits at its eye-order rank.
- [ ] No world prop combines gloss + bevel + cube size (blocks own that look).
- [ ] No mushroom or egg props within 12 cells of the board; nothing inside the clear zone except flat tiles.
- [ ] From all four corner yaw snaps, no prop hides a cell or the danger line; tall props off the board diagonals inside 8 cells.
- [ ] At most one moving thing near the board (the level's disturbance); ambient motion ≥ 10 cells out.
- [ ] Board tiles ≈ 15% lighter/cooler than the surrounding turf.

**Colour (art bible §4)**
- [ ] World/backdrop ≤ about 40% saturation; backdrop is the lowest-contrast layer.
- [ ] No reserved hue on world, props or characters: buff cyan 186° ±25°, debuff magenta 322° ±25°, hazard orange, reward gold, danger red.
- [ ] Greyscale pass: pieces have 5–6 lightness steps and separate from the island.
- [ ] Colour-vision simulator (protan, deutan, tritan): every motif and event icon still tells its pair apart.

**Style**
- [ ] Hand-painted albedo, matte, soft top-down baked light + AO; no PBR noise; low-frequency strokes, quieter near the board.
- [ ] Cute proportions match the reference style (round, inflated, no thin spikes).
- [ ] Outlines: dark neutral on world and characters, tinted on blocks; constant screen width.
- [ ] Characters read as a silhouette at 48 px in every key pose; each pose changes the outline; the Miller's lonely pose reads without text.
- [ ] Icons read at 32 px; container shapes follow the UI grammar; no block shapes in icons; emotes are wordless.

**Technical**
- [ ] Name matches `prefix_scope_name_variant`; one EXPORT collection per id; nothing overwritten (copy first).
- [ ] 1 unit = 1 cell, base on z = 0, transforms applied, origin correct; imports into Godot without errors or warnings.
- [ ] Within its §0.4 tier guide, or the overrun is noted with a reason; atlas shared with its level.
- [ ] Animation clips named, loop cleanly, and have a reduced-motion-safe variant where they flash or shake.
- [ ] Flip-state geometry present for 09/10 if F2 needs it.

**Licence**
- [ ] Row in `assets/source/blender/LICENCES.md` (name, source, id, author, licence, used for).
- [ ] CC-BY: credits.json entry with author, licence, source URL and shipped files; appears on the credits screen.
- [ ] BlenderKit: Royalty Free (not Editorial); only our own bake is shipped.
- [ ] generate_3d: provider, prompt/image and date logged; commercial rights confirmed.

---

## 10. Open questions and change log

**Open (for the user / owners)**
1. **generate_3d rights**: which provider does the Blender MCP use on your account, and does that plan grant commercial use? If not, Pip and the Miller become hand-model kitbashes (≈ 2–3× the build time each).
2. **Flip presentation (world-and-scenes F2)**: does the whole diorama turn over in 09/10 (needs dressed undersides and an upside-down mill/Miller) or only the stack? Owner: game-designer + technical-artist.
3. **Day cycle (F1)**: three-day arc (7 lighting presets) or one sunny day (≈ 3 presets)? Owner: narrative-director.
4. **Meadow block set in MVP**: the build sheets use `candy_toy`; ship `blk_meadow_budding_clover` for the Meadow, or keep candy_toy for MVP?
5. **Fonts and logo**: which display/body fonts (licence must allow embedding, e.g. SIL OFL)?
6. **Icon method**: render icons from tiny Blender models (recommended: matches the 3D look) or paint them in 2D? May CC-BY icon packs be used as bases?
7. **Colourblind patterns**: is the face motif enough for MVP, or do per-family pattern overlays ship too?
8. **Meadow friends' species** (vole, shrew, hedgehoglet are provisional): narrative-director.

**Change log**
- 2026-10-10: v1 drafted (art-director).
