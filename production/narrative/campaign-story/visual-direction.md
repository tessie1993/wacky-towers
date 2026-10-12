# Campaign visual direction: "The Party Nobody Could Ask For"

> **Status**: Draft v1 (art-director, 2026-10-10), `/team-narrative` Phase 2, for user review
> **Canon read**: `production/narrative/campaign-story/brief.md` (story bible), `design/art/art-bible.md`, `design/art/block-art-sets.md`, `design/gdd/narrative/characters.md`, `design/gdd/ux/ui-theme.md`
> **User rulings applied (2026-10-10)**: the nine bosses appear as **finale-skit guests only**; the **Cave low point is softer**; side islands kept; 4 playables = cloud wizard, Lana (alpaca knitter), Boulder (pygmy hippo), Glim (bat architect); target = **flagship phones + PC, Godot Mobile renderer**.
> **Everything below is a flexible default.** Hexes, timings, counts and placements are starting points to tune by eye, in-engine and on device. Where a value overrides the art bible, run the art bible 4.7 check and note it. The user's per-biome reference sheets win wherever they differ from this file.

---

## 0. The three rules this file leans on

1. **Quiet World, Loud Board** (art bible P2). Every story element (Mizzle, flags, tables, bosses' gadgets) lives at the **rim and in the backdrop**, matte and lower saturation than the pieces. Story never enters the grid or its one-cube margin.
2. **Reserved colours stay reserved** (art bible 4.1, 4.3). Buff cyan `#1FD3E6` (186°), debuff magenta `#E62AA0` (322°), hazard orange `#FF6A13` (22°), reward gold `#FFC83D`, danger red `#F23A3A`. Story colours keep about 25° or more away, or separate by saturation and value when the hue can't move.
3. **The violet thread is the only violet story colour.** Mizzle's dusk violet is the player's "that's him" signal across ten biomes, so no biome makes violet its dominant backdrop hue (Drizzle Rock, his home, is the one stated exception).

---

## 1. Characters

### 1.1 Shared character kit (applies to all five below)

| Topic | Default |
|---|---|
| **Screen size** | 48-80 px tall on a phone at gameplay camera (art bible §5); skit close-ups up to about 30% of screen height. Every silhouette is checked at 48 px, black-filled, side by side |
| **Rig** | One shared **"toy biped" skeleton** (about 20 deform bones: root, hips, spine x2, neck, head, 2x arm chains, 2x leg chains) for the wizard, Mizzle, Lana, Boulder and Glim, plus per-character add-on chains (hat, ears, neck, tail, yarn, scarf). One animation library (idle bob, cast, cheer, dismay, shock, taunt, look-up, give) retargets to all five. Proportions differ by bone length, not by skeleton |
| **Face** | Eyes and brows on a small **swappable decal / UV-offset sheet** (about 8 eye states, 6 brow states), not blendshapes, so faces stay cheap on the Mobile renderer and read as cartoon at 48 px. Mouths only where no beard hides them |
| **Emotion carrier** | Every character has one big **silhouette-changing emotion part** (hat, ears, neck, tail) so mood reads at 48 px without the face |
| **Multiplayer identity** | Each playable carries the player colour on **one accessory** (wizard robe, Lana's yarn ball, Boulder's hard-hat band, Glim's blueprint ribbon) plus the hat emblem / screen corner / name label (art bible 4.6). Character body colours never change per player |
| **Skill VFX grammar** | Each friend's skill has its **own motif shape and its own neutral motif colour** (wool, dust, chalk). The gameplay result of a skill still uses the art bible accents: anything that is a buff on the stack shows the buff cyan rim + up-chevron badge; nothing a skill does uses debuff magenta or hazard orange. Motif VFX run 0.4-0.8 s and never cover the falling piece or ghost |

### 1.2 The cloud wizard (C1, reference only)

Unchanged from art bible §5 and `characters.md`: small round body, big cone hat, beard, wand, on one soft cloud. Silhouette = **triangle on a circle**. Per-biome costume touches stay on the hat band and neckerchief (Meadow daisy and gingham). The hat gains one keepsake per biome; after the Celestial finale the tip holds Mizzle's lit star.

### 1.3 Mizzle, the rival wizard (skits, backdrop and Scrapbook only; tournament chaos host after the finale)

| | Default |
|---|---|
| **Silhouette** | A **bent question mark**: tall, thin, drooping. About 1.5x the wizard's height but under half its width. The long hat continues the spine's curve, so hat + body read as one hooked line. Black-filled next to the wizard (triangle-on-circle), Pip (round + big ears + basket) and the Miller (big round + cap), all four are different at 48 px |
| **Peek test** | Only the **hat's bent tip and one spectacle lens** show when he hides behind a prop. That pair (hooked tip + one round lens glint) must read at 24 px, so the tip bend is exaggerated and the lens gets a bright two-pixel catchlight |
| **Shape language** | Long tapered curves and drooping lines (shy, unstable, gentle), against the wizard's upright circles (confident, stable). No sharp points anywhere, so he never reads as a threat (brief rule 4). As his arc rises (biomes 6-10) his posture straightens a few degrees each biome; at the finale he sits upright for the first time |
| **Palette** | Dusk violet robe `#7E6496` (about 271°, low saturation, mid-dark value); flag/ribbon violet `#8A6AAE` (slightly brighter so it reads at the rim); pale gold trim and spectacle rims `#E3D3A0`; unlit star `#B8A878` (dull, clearly not reward gold); scarf in an oatmeal cream `#E8DCC4`; boots warm grey-brown. **Why low saturation**: the hue sits near the lavender piece (about 258°) and player purple (about 266°), and can't move far without nearing debuff magenta. Separation comes from his dusky value and saturation, his pale gold pairing and his silhouette. Run the colour-vision check (4.7) |
| **Star payoff** | The unlit star is the one place pale gold becomes **reward gold** on purpose: at the finale it lights `#FFC83D` with a sparkle and flies to the wizard's hat. It's a reward moment, so the reserved colour is used honestly |
| **Signature props** | Satchel of parcels (violet ribbon on each), **violet cuffs** (oversized, the identifier in every hand-only glimpse: cuff = Mizzle, always), patched hat band, wand with a lopsided block doodle, spyglass (Underwater), glow-stick hat (Neon; worn over his own hat tip so the hook still shows) |
| **His cloud** | The wizard's cloud mesh, scaled to about 70%, stretched thin and pointier at the ends, grey-violet `#9C93A8`. **Mail-cloud**: the same mesh at about 30% with two dot eyes and a tiny satchel; violet tint a step lighter |
| **Expression rig notes** | Add-on chains: **hat (4 bones, the main mood carrier)**: droop = sad, tip twitch = nervous, tip lifts = hope, tip curls round = blush. **Sleeves (2 bones each)** for the long-cuff flop and the sleeve wipe. **Glasses**: one shared lens material with a view-space matcap "reflection"; for emphasis the lenses can swap to flat white (startled), two arcs (happy) or soft blue fill (the `tear` moments). Brows sit above the glasses and are bigger than the wizard's. Key poses: peek, glasses push, counting on fingers, chair straighten, wand doodle, flee (hat trails behind), sit |
| **Tells for animators** | Never squares up to the camera before the finale: he's always three-quarter, turned slightly away. Holds each pose about 30% longer than the wizard, so he feels hesitant. Never on the grid side of a prop |

### 1.4 Lana, the alpaca knitter (C2, joins at Ice)

| | Default |
|---|---|
| **Silhouette** | A **tall vertical bar with a long neck and a puff on top**: round wool body, long upright neck, fluffy topknot with **two knitting needles crossed in it** (an X on top). A **yarn line** trails from her to a ball. Reads as "tall + X + trailing line" at 48 px, distinct from the wizard's triangle and Mizzle's hook (she's straight where he droops) |
| **Shape language** | Soft cloud-like wool lumps (mothering, safe), straight calm neck. Few angles; the needles are the only straight accent |
| **Palette** | Cream wool `#F2E8D8` with a warm oatmeal shadow `#D8C6A8`; face and legs soft fawn `#C9A27E`; knitted cowl in sage `#9AB08A`; yarn ball and yarn trail in **dusty coral `#E38B76`** (about 10°, safely off magenta and hazard). In multiplayer the yarn ball carries the player colour |
| **Signature props** | Two needles in the topknot, a half-knitted scarf on her arm, a yarn ball that rolls when she's flustered |
| **Expression rig notes** | Add-on chains: neck (3 bones: stretches up = curious, curls down = worried), ears (2 bones each), topknot (1 bone, bounces). She knits when worried: one looping "knit" idle that runs in reactions and while waiting. Mouth visible (no beard), small and gentle |
| **Skill VFX: Stitch** | **Running-stitch motif**: a dashed wool thread sews itself around the stack's outline in a quick lap, then small cross-stitches pin each corner. Motif colour = her coral yarn; the "pinned" state on the stack is the buff cyan rim + up-chevron badge. While active, a soft knitted-texture overlay sits on the board edge only (not on pieces). Release: the thread unpicks and drifts off as one loose strand. Reduced motion: the outline appears complete in one 150 ms fade, no lap |

### 1.5 Boulder, the pygmy hippo (C3, joins at Lava)

| | Default |
|---|---|
| **Silhouette** | A **wide horizontal bean with a T on top**: barrel body, stubby legs, small ears, and an **oversized wooden mallet** held up so its head makes a T or rests on her shoulder as a big square. **Hard hat with a lamp**: a dome with a dot. The widest of the four, the opposite of Lana's tall bar |
| **Shape language** | Big squashy round masses (friendly, heavy, clumsy). The mallet is the one blocky shape, so it must **never** be cube-proportioned or glossy (art bible: block shape + gloss = a block). Make the mallet head a squat barrel with iron bands |
| **Palette** | Slate-rose skin `#8E7A82` with a warm pink belly `#D8A8A0`; hard hat in **butter cream `#EAD9A0`** with a navy band `#3A4A6A` (construction yellow kept low-saturation so it doesn't read as reward gold); lamp lens warm white; mallet raw pale wood `#C8A880` with grey iron bands. In multiplayer the hard-hat band carries the player colour |
| **Signature props** | Mallet, hard hat with lamp, a pencil behind one ear (she fixes what she breaks), a roll of tape on her belt |
| **Expression rig notes** | Add-on chains: mallet (prop bone, big swing arcs), ears (1 bone each, flick), cheeks (1 bone, puff for effort). Lots of squash on landing and swings. Mouth big and visible: the most open-mouthed of the cast |
| **Skill VFX: Smash** | **Dust donut + bonk ring**: anticipation (mallet raised, lamp flares white, 0.2 s), impact (one round dust ring at the chosen chunk, chunky wood-chip and pebble particles in neutral browns, a short comic "bonk" ring of white four-point stars, never gold). Removed cubes pop like a layer clear, in their own piece colours. Camera nudge only with motion enabled (2-3 px, 80 ms). Reduced motion: no nudge, no stars; the dust ring is a single 150 ms fade |

### 1.6 Glim, the bat architect (C4, joins at Cave)

| | Default |
|---|---|
| **Silhouette** | An **upside-down teardrop with two tall triangle ears at the bottom**: she hangs from a small drafting-board boom (a T-square handle) clipped to her cloud, wings folded like a cape. A rolled **blueprint tucked behind one ear** gives a horizontal stick. Reads as "inverted, two big ears, one stick" at 48 px. When she celebrates she flips upright and spreads her wings (a big outline change) |
| **Shape language** | Neat triangles and clean arcs (precise, fussy), ears as sharp but rounded-tip triangles; the most geometric of the friends, never jagged |
| **Palette** | **Warm cocoa-grey fur `#7A6A64`** (not purple: violet belongs to Mizzle), ear and wing-membrane insides dusty peach `#E3B49A`; blueprint in **deep navy `#2E4470` with white chalk lines** (navy sits far from buff cyan in value and saturation); a pencil in her paw; a small measuring tape. In multiplayer the blueprint's ribbon carries the player colour |
| **Signature props** | Blueprint roll, pencil, folding ruler, T-square perch. **No spectacles** (round glasses are Mizzle's identifier) |
| **Expression rig notes** | Add-on chains: ears (2 bones each: up and wide = excited, pinned back = annoyed by mess, one flicked = thinking), wings (2 bones each, cape fold to full spread). Rig is the shared biped with the root rotated 180° while hanging, so the shared animation library still applies; a dedicated "flip upright" transition for cheers |
| **Skill VFX: Redraw** | **Chalk blueprint motif**: a navy blueprint sheet slides in behind the next-piece plate (UI side), chalk lines sketch the re-rolled pieces, and on the board the perfect-fit spots get a **white dashed chalk outline** with a hand-drawn tick, not a cyan glow (the outline is guidance, not a buff). If the design treats Redraw as a buff, the HUD badge carries the cyan chevron; the board outline stays chalk white. Reduced motion: no slide, no sketching; the outlines appear in one fade |

### 1.7 Silhouette line-up check (sign-off test)

Black-fill the wizard, Mizzle, Lana, Boulder, Glim, Pip and the Miller in one row at 48 px and at 24 px: **triangle-on-circle / hook / tall bar with X / wide bean with T / inverted teardrop with ears / small round with huge ears and basket / big round with cap**. Any two that a tester confuses in under a second get their emotion part exaggerated first.

---

## 2. Mascots and bosses

### 2.1 Staging defaults (all biomes)

| Topic | Default |
|---|---|
| **Mascot scale and place** | Same screen size as the wizard (48-80 px). Lives on a **rim corner opposite the wizard's cloud**, on low-detail ground. Never inside the one-cube margin; checked from every rotate-view angle |
| **Boss scale and place** | About **one third of screen height**, in a dedicated **boss zone** in the backdrop behind and above the board's far edge (top-centre or top-far-side by default). The backdrop behind the boss is darker and simpler (art bible §6). The boss can be cropped by the frame edge; it never overlaps the grid's projected footprint from any view angle |
| **Boss surface** | Matte, painterly, rounded or irregular, dark neutral outlines. Only parts that are played as blocks get the block look (art bible §5); otherwise no cube-and-gloss shapes on bosses |
| **Gift and flag** | Every boss holds or wears its party gadget, and the gadget carries its **violet pennant** (one shared pennant mesh, §3.3). The flag is matte, rim-small, never animated faster than a slow flutter |
| **Telegraph wind-up (readability)** | Three layers, all in the same moment: **(1) a silhouette-changing wind-up pose** held 0.6-1.0 s by default (tunable 0.5-1.2; the twist GDDs own the real timing), **(2) the gadget anticipates** (inhale, glint, wind-back) with a soft rim light on the boss, **(3) a hazard marker on the board**: hazard-orange triangle icon plus diagonal stripes on the affected cells, lane or edge. Layer 3 is the gameplay truth; layers 1-2 are the story. The marker is the only hazard orange on screen during the wind-up. One wind-up at a time (brief rule 9) |
| **Bonk** | When a twist resolves or the player clears through it, the boss gets a comic bonk: flour, dust, splash or confetti puff. Never hurt, never dizzy for long |
| **Reduced motion** | Wind-up keeps the pose and the board marker; drops shakes, flashes and anticipation squash. Marker stripes don't scroll |

### 2.2 The ten biomes

| Biome | Mascot (silhouette hook) | Boss (silhouette at 1/3 screen) | Gadget + flag spot | Wind-up tell (pose + gadget) | Watch for |
|---|---|---|---|---|---|
| 1 Meadow | **Pip**, harvest mouse: huge round ears, curly tail, basket twice its size (existing) | **The Miller**, badger: big round, cap, white face stripe (existing) | Lever with a violet bow (close-ups only) | Existing crank/lever/bellows poses | Existing; additive bow only |
| 2 Candy | **Mallow**, marshmallow bunny: a soft cylinder with two long flopped ears; sticks and peels | **Madame Meringue**: a tall swirl-peak dome with a curled tip and two little arms, a tiara of sprinkles | Piping bag (ribbon on the bag) | Squeezes the bag back over her head, peak curls tight (inhale), then a forward lean | Meringue white vs. pale board: give her a warm cream shadow and a dark outline; sprinkles avoid pink and cyan |
| 3 Ice | **Pebble**, penguin: a smooth egg with a tiny bow-tie, flat flippers | **Big Sniffles**, yeti: a huge fluffy pear shape, red nose, scarf, drip | Party horn (flag on the horn) | Head tips back, nose swells, horn lifts to his mouth (the pre-sneeze "ahh"), then the sneeze | Snow-white yeti on snow: blue-grey fur shadows, a darker scarf, dark outline |
| 4 Underwater | **Puff**, pufferfish: a round ball with fins; inflates (spiky only as soft round nubs) | **Admiral Crab**: a wide low oval with two big mismatched claws, tiny admiral hat | Bottle (tag on its neck), kept in his treasure pile | One claw opens wide and rises, eye-stalks lean, the hat tips forward | Coral pinks off magenta (keep coral peach/salmon); his red off danger red (warm brick-red, matte) |
| 5 Lava | **Cinder**, fire salamander: a long low S-curve with a curled tail, warm spots | **Smolder**, baby dragon: round body, oversized head, stubby wings, refuses the bath | Bath-bomb set (flag on the gift box) | Cheeks puff, wings flare, tail lifts; a little smoke ring before the effect | Ember and magma vs. hazard orange: Smolder is plum-red and teal-grey (warm-cool contrast), never orange-dominant |
| 6 Forest | **Chip**, baby beaver: a pear with a big flat tail and two big front teeth | **Grandpa Oak**: a wide trunk with a bushy brow canopy, face in the bark, root feet | Wind chimes hung on a branch | Brows lower, branches rise and pull back (the yawn-stretch), leaves rustle up | Canopy green vs. the lime and mint pieces: a deeper olive canopy, autumn-tinged toward the finale; finale blossom is soft pink, not magenta |
| 7 Cave | **Nugget**, mole: a round lump with a pointed snout and a **headlamp** (a dot of light) | **Geode**, sleeping rock golem: a big round boulder body with two mitten-like fists and a sleepy face; hatches into a **crystal bird** (vain, upright, tail plume) | Lantern chain wrapped round him | Fists rise, eyes crack open, crystals on his back flicker; dust drifts from his shoulders | No cube-shaped head (art bible §5); crystals off cyan and off saturated violet: amber, rose-quartz, pale lilac-grey (§3.2 Cave) |
| 8 Clockwork | **Tock**, wind-up duck: a teardrop with a big **wind-up key** on its back | **Cuckoo Prime**: a tall clock house with a roof peak, a cuckoo bird on a spring, two hands as arms | Clock-stopper on the pendulum (flag on the pendulum) | Cuckoo door snaps open, the bird pops out halfway and holds; hands swing back | Brass vs. reward gold: aged brass `#A88A58`-family, never saturated |
| 9 Neon | **Glitch**, pixel cat: a cat outline with one stepped (pixelated) ear and tail tip; flickers | **DJ Mirrorball**: a round mirror ball on a DJ deck, two headphone cups as ears | Mixtape in the deck (flag on the cassette) | Arms over the deck, ball spins faster with travelling light specks on the backdrop only; one beat-count "nod" per beat | Specks and signs stay off cyan and magenta (§3.2 Neon); the speck flicker stays under 3 flashes per second |
| 10 Celestial | **Comet**, fox: a slim fox with a long sparkle-trail tail | **The Sleepy Moon**: a huge crescent with a nightcap and a pillow | Lullaby night-light (flag on its cord) | A huge slow yawn: the crescent tilts back, cap slides, the pillow fluffs | Moon pale yellow vs. reward gold: moon in pale cream-silver `#E6E0C8`; trim gold muted |

### 2.3 Side islands

| Island | Mascot | Boss | Gadget / wink | Wind-up tell | Watch for |
|---|---|---|---|---|---|
| Tumble Fair | **Bounce**, baby elephant: round body, big ears, a short trunk up | **Baron Balloon**: a round hot-air balloon with a moustache, a basket as a "collar" | His own ribbon-tied sandbag; the wink is a violet pennant hidden in the fair bunting | Inflates and rises, the moustache twirls, the basket swings back | Fair bunting is warm red/yellow/cream stripes only, so the single violet pennant pops as the wink |
| Dune Bazaar | **Tuft**, meerkat: a tall thin stick-figure standing on hind legs | **Madame Sphinx**: a reclining cat-sphinx, headdress stripes, a raised paw | Riddle tablet (pictograms only, no text) | Paw lifts, eyes narrow, the headdress glints | Sand gold vs. reward gold: sand in pale ochre-beige, low saturation |
| Boo Hollow | **Wisp**, little ghost in a too-big sheet: a puddle-bottomed blob with the sheet dragging | **Sir Sheet-a-lot**: a tall bedsheet ghost with a knight's plume and a cardboard sword | A theatre curtain; the wink is a violet cuff behind a pumpkin | Sheet arms rise wide, plume puffs, he leans forward on tiptoe | Never scary: round eyes, no teeth, no sharp shadows; see §3.4 on purple |
| Drizzle Rock | **The mail-cloud**: a tiny cloud with a satchel and dot eyes | **Crumb**, the clanking butler: a tall thin wind-up robot with a tray arm and a tea-cosy hat, lopsided | The long table itself | Tray arm swings round, gears tick visibly on his back, he tips forward to "set" | His tin is warm pewter; his lopsidedness echoes Mizzle's tower |

### 2.4 Finale guests (Celestial; user ruling: the nine bosses appear as **finale-skit guests only**)

- The nine bosses stand on the hat's brim in a **line-up**, scaled down to about 1.3x mascot size (a "curtain call" scale), reusing each boss's own skit model and a shared set of three guest poses (look at gadget, look at Mizzle, sheepish wave). No new boss rigs.
- Each holds its flag; the flags join into **one bunting mesh** with the 10 panel textures in order.
- Order on the brim, left to right, is the biome order, so the bunting reads as the campaign route. The Miller stands nearest the wizard and Mizzle.
- Outside this skit, bosses appear only in their own biome (and tournament cameos only if the user later re-opens it; this ruling reads as "finale guests only", so tournament cameos are parked).

---

## 3. Biomes and side islands

### 3.1 Shared defaults

- **Island**: top (flat grid, ≤ 1/5 cube height), body (strata in the biome material), underside (the biome signature). Personality lives in the body and underside (art bible §6).
- **Palette**: backdrop ≤ about 40% saturation, one temperature per biome, a clear value gap between board and pieces.
- **Block material set**: the primaries from `block-art-sets.md` (theme sets from the user's references), unchanged here. Every set keeps the reserved colours off pieces.
- **Painted-wood frame per biome** (user decision, `ui-theme.md` §2): every biome's frames are **painted wood dressed for that biome**. Parchment interior and ink stay identical everywhere; trim under 10% of plate height, pointing away from the board and thumbs, painted (never glowing or animated in play), dark neutral outer edge. **This replaces the art bible §7 frame table** (ice, stone, rune/neon, marble), which predates the decision; art bible update flagged.
- **Light journey**: every biome's presets are built from **eight shared archetypes** (§5.3) plus a biome tint, so a "preset" is a small parameter set, not new content. The art bible's mood states (danger, layer clear, win, game over) layer on top in every biome.
- **Diorama composition**: board centred; the **mascot rim corner** opposite the wizard; one **background landmark**; the **boss zone** top-back; a **thread spot** (where Mizzle's clue appears) at a rim corner or mid-ground island, never behind the wizard or the boss and never over the grid. Change across the 10 levels (art bible §6): the landmark gets closer or the island changes, so progress shows without words.
- **Mizzle clue rules**: at most one clue per level, at most 1.5 s, never during a warning, never over the grid (brief §6). The **violet pennant** is the recurring clue prop; each biome also has one **thread tableau** (window, snowman ring, table) that sits in the backdrop as ambient set dressing on the levels where its density allows.

### 3.2 The ten biomes

#### 1. Meadow: Pip's Picnic (done; additive only)

| | Default |
|---|---|
| **Palette** | Existing (art bible 4.4 Grass): sky `#8F9AD8`, moss `#7E9C5E`, brick `#A88468`. Warm-neutral |
| **Block set** | Lush Grass / Budding Clover turf over soil, Wild Flowers add-ons (existing) |
| **Frame** | Warm painted oak, brush grain, brass nails, clover and ivy vines at the top corners, one daisy (existing, `ui-theme.md`) |
| **Light journey (7, existing)** | morning, noon, afternoon, golden, dawn-fog, sunrise, interior-candle; three days to golden hour |
| **Diorama + props** | Existing mill landmark, picnic hill, pond |
| **Mizzle clues** | Violet bow on the Miller's lever (close-ups 05 and 10 only). Post-10 map: a pennant on the mill roof beside the windmill; Mizzle's crooked tower as a **speck on the far map edge** (a 6-8 px stack of mismatched blocks with a hooked-hat dot on top) |

#### 2. Candy: Mallow's Birthday Cake

| | Default |
|---|---|
| **Palette** | Warm-pastel: sky butter-peach `#F2D8C0`, cake sponge `#D9B48A`, icing cream `#F4ECDC`, chocolate shadow `#7A5A4E`, mint-sage accents `#A8C8A8`. Pinks stay peach-coral (≤ about 15°) or rose-brown, never toward magenta |
| **Block set** | Gummy Candy / Gummy Jelly (primary) |
| **Frame** | Pastel-painted toy-shelf wood (soft cream with a peach edge), short icing drips pointing outward, a few sprinkles in lemon, peach and chocolate only (no pink or cyan sprinkles) |
| **Light journey (5)** | L1-3 **steamy morning** (B, soft bloom haze far planes only), L4-6 **late morning** (B+), L7-8 **afternoon** (D), L9-10 **golden window** (E, warm rim on the cake), Bonus **bakery interior** (H, oven glow) |
| **Diorama** | The board sits on a cake-tier island (sponge strata, jam layer, icing underside with short drips). Landmark: the **bakery shop with a lit window** and Granny's party table behind it. Props: candles (unlit until the finale), cherries, sugar cubes at the rim corners (rounded, never cube-gloss) |
| **Thread spot** | The **bakery window** (mid-ground, upper right): a droopy hat silhouette behind a lace curtain (L-late), a violet cuff takes one slice from the sill (one level, 1.2 s). Finale: the flag is the ribbon on the piping bag; a tiny thank-you star pops by the window (white four-point star, not gold) |

#### 3. Ice: Pebble's Egg Escape

| | Default |
|---|---|
| **Palette** | Cool: sky `#C3D5E6`, tiles `#A9B6C4`, snow `#EEF2F6` (art bible 4.4), plus a warm counter-accent for life: igloo-brick butter `#E6D8B8`, scarf reds and yarn coral. Ice glints stay pale blue-white, **never cyan glow** |
| **Block set** | Frosted Glass / Glacial Ice (primary). Board contrast risk ("ice pieces on ice board", art bible P2): board tiles a step darker and greyer than the pieces; pieces keep their full palette |
| **Frame** | Frosted pale birch with snow caps on the top edge and short icicles pointing outward; the dark outer edge does the separation work |
| **Light journey (5)** | L1-3 **cool dawn** (A, blue-lilac), L4-6 **overcast rolling clouds** (B, flat, slow cloud shadows on the backdrop only), L7-8 **whiteout** (I, backdrop fog density up; board and pieces stay clear), L9-10 **bright noon** (C, crisp snow glitter on far planes), Bonus **igloo interior** (H, warm lamp in a cool room) |
| **Diorama** | Glacier island with blue strata and an icicle underside. Landmark: the mountain with Sniffles' cave. Rim props: snow lumps, a sled, Pebble's egg nest |
| **Thread spot** | The **snowman ring** on a mid-ground ledge: snowmen each holding a cup, one empty chair (the "one more chair" motif). **Lone boot prints** lead from it into the mountain. The first `tear` is shown as a single **drip from an off-screen source above the frame** landing in the snow next to the empty chair (no face shown). Post-finale: every snowman wears one of Lana's scarves (coral, sage, cream) |

#### 4. Underwater: Puff's Pearl

| | Default |
|---|---|
| **Palette** | Teal shifted **toward green-teal (about 160°) or toward deep blue (about 210°)**, never 186° buff cyan; backdrop water ≤ 35% saturation. Sand `#E8D8B8`, coral peach `#F0A890` and salmon `#E08878`, kelp olive `#7A8A5A`, shell cream. Sunset amber stays brown-amber, not hazard orange |
| **Block set** | Deep Sea Gems with bubbles (build 1) / Coral Overgrowth |
| **Frame** | Driftwood: sun-bleached grey-tan, a few barnacles, one strand of kelp hanging from a top corner (outward) |
| **Light journey (5)** | L1-3 **noon caustics** (C; caustic pattern on the island body and seabed only, never on the grid), L4-5 **kelp shade** (I, green-dim), L6-7 **afternoon green-gold** (D), L8-10 **amber sunset** (E, the surface glows amber above), Bonus **clam grotto** (H, soft pearl glow) |
| **Diorama** | Reef island with coral strata and a clam grotto underside. Landmark: Admiral Crab's **treasure pile** with a sunken rowboat. The **water surface** is visible at the top of the frame with a cloud above it |
| **Thread spot** | The **far surface cloud**: a tiny grey-violet cloud with a spyglass glint. One level: the player's light finds it and Mizzle **ducks** (hat tip vanishes last). The bottle with its pennant tag sits on the treasure pile as ambient. Finale: Puff carries the bottle up; a violet cuff takes it |

#### 5. Lava: Cinder's Snack

| | Default |
|---|---|
| **Palette** | Hot: obsidian `#3A2F35`, ash `#6E625F`, magma `#B5542E` (art bible 4.4). **Magma stays brick-red and dull**, below about 60% saturation and darker than hazard orange; add cool teal-grey smoke `#5E6E70` as the counter-colour so warm danger isn't the only temperature |
| **Block set** | Obsidian Glass (glowing seams allowed per the reference; settled-piece glow faint) |
| **Frame** | Charred dark wood with painted ember cracks (dull, not glowing), iron corner straps |
| **Light journey (5)** | L1-3 **red dusk** (F), L4-5 **ash-haze dusk** (F + backdrop smoke), L6-8 **early night ember** (G, warm underlight from the crater), L9-10 **crater night** (G deep, the eruption finale), Bonus **forge interior** (H). Danger state reads by backdrop darkening and the danger line, not temperature (art bible §2) |
| **Diorama** | Basalt-column island with magma veins in the body and drips underneath. Landmark: the **volcano crater rim**. Rim props: a bathtub half-built (for the spa duel), rubber-duck stand-in socket, marshmallow sticks |
| **Thread spot** | **The Rosetta** on the crater rim (the strongest clue so far): the Miller holds flag 5, then the **leaf card and the star-stamped card** from his pocket (each card about 20% of his height, the violet star clearly drawn), then points at the wizard. Rim spot only, on the opposite side from the boss. Elsewhere: Mizzle walks along a far ridge under a **tower of parcels**, his hat tip poking out on top. Finale: flag 5 hung as a towel on the tub |

#### 6. Forest: Chip's Bridge

| | Default |
|---|---|
| **Palette** | Warm green: deeper olive and moss for foliage `#6E7E4A`, bark warm brown `#7A5A40`, stream blue-grey `#8AA0A8`, lantern warm `#E8C080` (muted). Foliage stays duller and more olive than the lime and mint pieces |
| **Block set** | Forest Bark (primary) / Moss & Stone |
| **Frame** | Mossy log wood with bark-rough edges, one tiny mushroom cluster and a fern curl at the top corners (Meadow is clean oak; Forest is rough log, so they differ) |
| **Light journey (5)** | L1-3 **late-afternoon green** (D, dappled leaf light on the backdrop), L4-6 **golden dapple** (E), L7-8 **lantern dusk** (F, warm lanterns on the bridge), L9 **firefly night** (G, for the firefly twist), L10 **blossom dusk** (F + pink bloom for the finale), Bonus **berry-glade morning** (B) |
| **Diorama** | A mossy stump island with root strata and a hanging-root underside. Landmark: **Grandpa Oak** across the stream, the half-built **branch bridge** between islands (the island link). The campaign's breather: lower prop density, slower ambient motion |
| **Thread spot** | **First contact** at the bridge post (rim, mid-right): the acorn falls, a violet cuff and the wizard's wand reach in, he flees, the **tiny crooked block** stays on the post. The crooked block is matte, mismatched, visibly lopsided, not glossy (it must not read as a playable piece). Post-finale it stays on the post as a permanent prop |

#### 7. Cave: Nugget's Light (softened low point, user ruling)

| | Default |
|---|---|
| **Palette** | The darkest biome, but **never black**: deep blue-slate `#2E3442`, warm lantern amber `#E0A860` (muted), glow-moss sage `#8AA88A`, crystals in **amber, rose-quartz `#D8A8A8` and pale lilac-grey `#B8B0C8`**. Not cyan (buff), not saturated violet (Mizzle), not magenta. Dark-biome rule (`block-art-sets.md`): piece outlines lighter than the backdrop or a thin rim light |
| **Block set** | Slate with crystal clusters (primary). Crystal tints on pieces follow the same off-cyan rule |
| **Frame** | Old mine timber: dark stained planks with iron brackets and two small **painted** crystal studs at the corners (not glowing) |
| **Light journey (5)** | L1-2 **entrance spill** (D cool daylight from an opening above), L3-5 **lantern** (H, warm pools), L6-7 **crystal glow** (G, crystal fill light), L8-9 **lantern circle** (I, for the darkness twist: darkness affects only the backdrop and island body; the grid keeps a minimum lit level), L10 **crystal-bird bloom** (the brightest the cave gets, warm), Bonus treasure-map lantern (H) |
| **Diorama** | A geode-cut island: crystal strata in the body, stalactite underside. Landmark: the **minecart rail loop** and Geode asleep in an alcove. The crystal wall behind is the shadow-puppet screen |
| **Thread spot (softened)** | **Shadow puppets** on the crystal wall show a small hooked-hat figure playing with friends (warm, slightly funny). The bats flap off and the group laughs at the bat gag; the puppet figure **pauses, his hat droops, and the crooked tower behind him tilts and is propped up with his wand**; he **walks off slowly into a lantern glow**, cuffs dangling, no sleeve wipe, no collapse, no `tear` on screen. A small **lantern is left behind, still lit** (a hopeful note for the player). Recommended because the user asked for softer; the brief's collapse + `tear` version stays the fallback only if the user re-opens it. **Map change** adjusts to match: the tower on the horizon is **leaning and propped**, not a heap, with one new floor. Flagged to narrative-director |

#### 8. Clockwork: Tock's Midnight

| | Default |
|---|---|
| **Palette** | Sepia night: warm umber `#4A3A30`, aged brass `#A88A58` (kept muted, under reward gold's saturation), lamp cream `#E8D4A8`, a cool slate-blue night `#3A4458` as counter-colour. The **clock face is the moon**: pale cream, large, upper backdrop |
| **Block set** | Clockwork Gears on the sheet `_16` cube kit (primary). Gold-coloured pieces stay brass-muted (reserved gold rule) |
| **Frame** | Polished walnut with brass corner plates, two rivets per corner, a thin engraved border line (painted) |
| **Light journey (5)** | L1-3 **sepia evening** (F), L4-6 **lamp-lit night** (G, warm street lamps), L7-9 **clock-face moonlight** (G cool, long shadows on the backdrop), L10 **midnight strike** (one warm bell bloom on the backdrop at the finale; no full-screen flash), Bonus **music-box interior** (H) |
| **Diorama** | A wind-up-town island on a gear: gear strata visible in the body, a slowly turning gear underside (slow; off in reduced motion). Landmark: the clock tower with **Cuckoo Prime** as its face. Conveyor streets as island links |
| **Thread spot** | A **window with a table set for twelve** in the town (mid-ground). One small figure waits; **each time the clock tries to strike, his chair is straightened** (a tiny movement, 0.5 s). The **mail-cloud** delivers the parcel in one intro (L8 or L9). Finale: the clock face opens on the table; the wizard places one cup |

#### 9. Neon: Glitch's Gig

| | Default |
|---|---|
| **Palette** | Saturated night, but the **signs use blue, warm amber, lime-green and soft red-orange-brown**, never cyan or magenta: indigo-black sky `#1E2038`, sign blue `#5A7AF0`, sign amber `#F0B860`, sign lime `#A8E070`, warm sign red `#E07060`. This overrides the reference sheet's cyan and magenta (flagged in `block-art-sets.md` as open; art bible 4.7 check). Backdrop signs sit dimmer than the pieces |
| **Block set** | Neon Glass (glowing edges) on the off-cyan, off-magenta palette (`block-art-sets.md` Rune/Neon row) |
| **Frame** | Painted plywood stage flats (black-lacquered wood) with **painted** neon-tube trim in amber and blue; tubes look lit but never animate or glow in play. Parchment interior kept (art bible §7) |
| **Light journey (5)** | L1-2 **blue hour** (F), L3-5 **night signs** (G), L6-7 **pixel rain** (I, rain on the backdrop only), L8-9 **stage show** (moving spot beams on the backdrop and crowd, beat-synced, ≤ 3 flashes per second), L10 **headliner** (warm stage wash), Bonus **arcade interior** (H). Reduced motion: beams static, no beat pulse |
| **Diorama** | A rooftop stage island: speaker strata, cable underside, lit signs on far skyline cards. Landmark: the stage with DJ Mirrorball. The crowd as a low-detail silhouette band (cheap cards) |
| **Thread spot** | **Mizzle in the crowd** with a glow-stick hat over his hooked tip, dancing alone (L-late); the crowd forms a circle; he flees; the **wand-glint star** follows him (white four-point star with the wizard's wand sparkle). Finale: the glow-stick hat left on a speaker |

#### 10. Celestial: Comet's Bedtime (the Hat Reveal)

| | Default |
|---|---|
| **Palette** | Cool dark: indigo `#2C2B5E`, nebula `#54488A`, marble `#D6D0E3`, trim `#A8915C` (art bible 4.4). Nebula leans blue-indigo rather than red-violet, so **Mizzle's violet and the 10 flags stay the brightest violets on screen** |
| **Block set** | Purple cosmic (Cosmic Dust / Starry Glow / Nebula Swirls). Gold accents on pieces stay muted (reward-gold rule); flagged in `block-art-sets.md` |
| **Frame** | Midnight-blue painted wood with muted gold-leaf filigree and tiny sun-and-moon ornaments at the corners (painted, not shiny) |
| **Light journey (6)** | L1-3 **indigo night** (G), L4-5 **nebula** (I, slow nebula drift on the backdrop), L6-7 **eclipse** (I dark, rim light on board), L8-9 **pre-dawn** (A cool, horizon brightening), L10 **first sunrise** (A to E warm, the only dawn of the campaign; the hat reveal), Bonus **hat-box interior** (H) |
| **Diorama** | A marble-stair island with star strata and a starlit underside. Landmark: the **Sleepy Moon** on its pillow and the growing tower that becomes **the wizard's hat**. Mizzle's crooked tower stands on a far marble step |
| **Thread spot (finale)** | Brief §1 steps 1-6. Staging in §4.3 |

### 3.3 Mizzle's flag set (one prop, ten panels)

- **One pennant mesh** (a triangular ribbon flag on a short cord), violet ribbon `#8A6AAE`, a cream painted panel `#F2E8D4` with a hand-drawn ink pictogram. No text, no letters, no numbers.
- **Panels in order (default)**: 1 a small figure with a hooked hat, waving; 2 a crooked tower of blocks; 3 a long table; 4 a row of chairs; 5 a cake with candles; 6 a music note; 7 a string of lanterns; 8 a clock at twelve; 9 dancing figures; 10 everyone round the table, with a small cloud and cone hat at its end. Read together: "come to my tower, there's a long table, everyone's invited". The finale reads left to right.
- **Sizes**: in-level the pennant is about 12-20 px on a phone (identity by shape and colour only); in close-ups and the Scrapbook the panel art reads at full size.
- **Map bunting**: the same mesh repeated along a curved cord between islands; each won biome adds its pennant.

### 3.4 Side islands

| Island | Palette | Block set | Frame | Light journey (default) | Diorama + wink |
|---|---|---|---|---|---|
| **Tumble Fair** | Warm evening: striped tent red-brick `#C8604A` and cream, butter yellow `#EAD48A`, sky peach-lilac. Stripes warm only | **Candy Stripes** theme set (Candy biome's alternate, already referenced) | Red-and-cream striped painted wood, pennant cord trim, a tiny ticket stub at one corner | (3) warm evening (E), string-bulb dusk (F), fair night (G, ferris-wheel bulbs on the backdrop) | Floating fairground island with the **ferris wheel** landmark (it doubles as the board-rotate twist's visual). **Wink**: one violet pennant among the warm bunting, one level |
| **Dune Bazaar** | Hot gold: pale ochre sand `#E0C89A`, terracotta `#C07850`, awning teal-green `#6A9A88` (well off cyan), lantern amber muted | **Desert** set (glazed terracotta, already specified in `block-art-sets.md`) | Sun-bleached cedar with brass lantern hooks and a woven rug-fringe edge | (3) hot noon (C, mirage shimmer on far planes), gold afternoon (E), lantern night (G) | A mesa island with sand strata and a lantern underside. Landmark: **Madame Sphinx** and the market awnings. **Wink**: a violet cuff takes a lantern at a stall |
| **Boo Hollow** | Cosy spooky, **not purple-dominant**: deep blue-teal dusk `#2E3E4E`, moss-green `#5E7050`, pumpkin **brown-orange** `#C0784A` (darker and duller than hazard orange), candle cream. **Why**: the brief's "purple dusk" would swallow the violet-flag wink and blur Mizzle's colour. Recommended blue-teal and moss dusk with only a hint of plum in the far sky | **plush_felt** party set (fat, stitched seams; cosy, not scary) | Weathered grey-green fence wood with a cobweb in one corner and a tiny candle stub | (3) candle dusk (F), moonlit (G), haunted-house interior (H) | Pumpkin-patch island with root strata and a lantern underside. Landmark: the **cute haunted house** with round windows. **Wink**: a violet cuff behind a pumpkin |
| **Drizzle Rock** (epilogue) | His home, the one violet-dominant place: grey-violet rock `#8A8296`, dusky violet sky `#6E6488`, warming over the island to peach-gold `#F0C8A0`. Pieces stay their own palette; the board keeps its value gap | **Patchwork** set: each piece family uses the material of one earlier biome set (he built from blocks he found). Zero new materials; per-family material assignment only. Fallback: Toy Box set | Mismatched painted planks, one per edge, each in a different biome's frame wood (reuses earlier frame textures) | (3, the warming journey) L1-2 **dusky violet** (F), L3-4 **warming dusk** (E), L5 + bonus **party lanterns** (H) | Lone rock island with the **leaning half-tower** and the **long table for twelve** as the landmark. Finale: the table fills with guests (reusing mascot and friend models at rim size) |

---

## 4. Skit cinematics

### 4.1 Tone

**Toy theatre, not film.** Characters act like puppets on a diorama stage: clear held poses, small hops between them, props popping in. The camera behaves like a person leaning closer to a shelf, never like a film crew. Comedy comes from timing and silhouettes, sadness from stillness and distance.

### 4.2 Camera and framing defaults

| Topic | Default |
|---|---|
| **Base camera** | The gameplay diorama camera. Skits start and end on it, so the hand-off to play is seamless |
| **Moves** | At most **2 moves per skit**: a slow push-in toward the rim spot (up to about 15-20% closer) and a return. Ease in-out, about 0.4-0.6 s each. No orbit, no roll, no handheld shake |
| **Shots** | 1-3 per skit. A "shot" is a pose change or a push, not a cut. Cuts only in the biome finale and only as a 150 ms soft cross-fade |
| **Framing** | The acting characters fill about 20-35% of the frame height in the push-in. The **subject sits on the rim spot**; the board stays in frame (blurred only by the painted far-plane haze, no real-time depth of field) |
| **Readability** | Each story pose held at least 0.5 s (Mizzle 0.65 s). One action at a time: the eye goes to one character, then the next. Light leads the eye: a soft warm pool on the acting character, the rest of the scene dims about 15% (a mood-state parameter, no extra lights) |
| **Aspect ratios** | Key action composed inside a **16:9 safe frame**; backdrops and islands extend to 20:9 (flagship phones) and 21:9 (ultrawide PC). Nothing story-critical in the extended margins or under notches (safe-area rules, art bible §7) |
| **Intro skit (≤ 3 s, countdown)** | Static camera or one small push to the mascot; ends on the hand-off (mascot looks up, wand glints, first piece spawns) at the base camera |
| **Payoff skit (≤ 5 s)** | One push to the rim spot, the pose sequence, the return |
| **Clue beat (≤ 1.5 s)** | **No camera move**: lit by a soft spotlight pool, so the player's view of the board never shifts |
| **Biome finale (6 s first play)** | Up to 3 shots: the boss bonk, the gift/flag reveal, the keepsake to the hat. Replays show the last 2 beats |
| **Friend join (4 s)** | One push to the friend's join pose, a silhouette-to-colour **unlock card** (silhouette black-fill, colour fills from the bottom in 0.4 s), return |

### 4.3 The Celestial finale (the one big staging)

1. Moon yawn: the camera holds wide; Mizzle's tower tips into a soft heap (a slow, cushioned topple; he lands on top, unhurt, a little drizzle cloud above).
2. Keepsake 10 seats: a slow **pull-back** (the one large move of the campaign, about 1.5 s): the tower is the wizard's hat; mascots pop out.
3. The nine bosses on the brim unroll their flags; the bunting joins; a slow pan along the 10 panels (left to right, about 0.25 s per panel).
4. The Miller waves. Close push on Mizzle: `dots`, then `blush` (glasses go to happy arcs).
5. The wand glint sends a block that becomes a **chair** beside the wizard. Mizzle sits upright for the first time.
6. The grumpy cloud turns pastel. His star lights reward gold, flies to the wizard's hat tip; **first sunrise** warms the scene.

### 4.4 Reduced-motion variant (follows the OS setting and the in-game toggle)

- **No camera moves**: each "push" becomes a hard hold on the base camera, or (in the finale only) a 150 ms cross-fade to the close framing.
- **Poses kept, motion dropped**: characters snap pose-to-pose with a 100 ms fade between, and every pose is held about 30% longer, so total skit time stays within its cap (drop the least important pose if needed).
- No shake, no confetti, no squash-and-stretch, no bouncing bubbles (static emote bubbles), no flashes (a steady warm light change instead), no scrolling hazard stripes.
- The finale pan along the bunting becomes **the full bunting shown at once**, held 2 s.
- Everything stays tap-to-skip. Flash limit (≤ 3 per second) applies in every mode.

---

## 5. Asset reuse plan (keeping the build sane)

### 5.1 What is shared across everything

| Asset | Shared as | Per-biome cost |
|---|---|---|
| **Character rig + animation library** | One toy-biped skeleton, one library (§1.1), face decal sheets | Per character: model, textures, add-on chains, a few unique poses |
| **Wizard cloud mesh** | Wizard's cloud, Mizzle's cloud (scaled, pointier via shape key), mail-cloud (scaled + eyes), grumpy cloud (existing), side-island mascot (the mail-cloud) | None |
| **Pennant mesh** | All 10 flags, map bunting, Tumble Fair bunting, finale bunting | One 256 px panel texture per flag (10 total) |
| **Party furniture kit** | One table (long, tileable), chair, cup, cake, candle, lantern | Recoloured per biome via material parameters: Ice snowman ring, Cave lantern, Clockwork table, Drizzle Rock table, finale, Scrapbook |
| **Crooked tower** | One scene built from existing block meshes (patchwork materials), with floor variants 1-10 toggled by progress | None per biome; the map shows the current floor |
| **Island kit** | Top tiles (one mesh, biome material), body modules (a few strata shapes, biome texture swap), underside (**the one unique piece per biome**) | Underside + 3-5 signature props + landmark |
| **Sky** | One sky-gradient shader (top/horizon/sun colours per preset) and painted backdrop cards | Backdrop cards per biome |
| **Light presets** | **Eight archetypes**: A dawn, B morning, C noon, D afternoon, E golden, F dusk, G night, H interior, plus I "special" (fog, whiteout, caustics, darkness) built as one parameter set. Each biome preset = archetype + biome tint + one or two overrides | A small `.tres` per preset (about 50 campaign presets total, all parameter-only) |
| **Frames** | One 9-slice **template per frame type** (§2 of `ui-theme.md`), fixed slice margins and the parchment insert. A biome = **repaint the wood layer + one trim layer** | One frame atlas per biome (one loaded at a time, ADR-0016) |
| **VFX** | One shared particle library: confetti, dust puff, sparkle (white four-point), bubble, snow, ember, leaf, flour, pixel. Palette-swapped by parameters | None or one texture tint |
| **Emote bubbles** | Existing shared sheet (`emote-bubbles.md`), plus `gift` and the violet-star `invite` variant | None |

### 5.2 Per-biome unique budget (default target)

1 mascot, 1 boss + gadget, 1 island underside, 1 landmark, 3-5 rim and body props, 1 thread tableau (built mostly from the party furniture kit), 1 frame repaint, 1 backdrop card set, 4-6 light presets (parameters), 1 block set (already planned). Anything beyond that is a scope addition for the producer.

### 5.3 Side-island reuse (they ride on main-biome work)

| Island | Reuses |
|---|---|
| Tumble Fair | Candy Stripes block set, pennant mesh, Candy's warm presets with a red tint, Neon's string-bulb props |
| Dune Bazaar | Desert block set (specified), Lava's hot-light archetypes (warmer, brighter), Clockwork's brass lanterns |
| Boo Hollow | Forest island kit (bodies, roots) recoloured, Cave lantern lighting, plush_felt party set |
| Drizzle Rock | Patchwork block set (no new materials), patchwork frame from earlier frames, party furniture kit, mascot and friend models as guests |

### 5.4 Build order suggestion

1. Shared rig + animation library on the wizard, then Mizzle (he appears in the most biomes).
2. Pennant mesh + party furniture kit + crooked tower floors (they serve every biome).
3. Lighting archetypes and the sky shader parameters (each new biome then only tints).
4. Frame templates; then each biome = repaint.
5. Per biome: underside, landmark, mascot, boss in biome order.

---

## 6. Open items and flags

| # | Item | Owner |
|---|---|---|
| 1 | Art bible §7 frame table still lists ice/stone/rune/marble frames; update to "painted wood per biome" (§3.1 here) | art-director (next art-bible pass) |
| 2 | Cave low point softened (no collapse, no on-screen `tear`; tower tilts and is propped; a lit lantern left behind). Brief §1 beat 7, §3.7 and the Cave map change need matching edits | narrative-director |
| 3 | Boo Hollow: recommend blue-teal and moss dusk instead of the brief's purple dusk, to protect the violet thread | user decision |
| 4 | Neon: signs and the Neon block set move off cyan and magenta (a 4.7 override of the reference sheet) | user decision; open in `block-art-sets.md` |
| 5 | Mizzle's violet sits near the lavender piece and player purple; separated by low saturation and dark value. Needs a colour-vision simulator check, especially when he's the tournament chaos host next to player purple | technical-artist + art-director |
| 6 | Tournament boss cameos (brief §6) read as parked under the "finale guests only" ruling; confirm | user |
| 7 | Glim hangs from a drafting-board boom on her own cloud (a new small prop); confirm she rides a cloud like the wizard | user / game-designer |
| 8 | Patchwork block set for Drizzle Rock breaks "one look per set" on purpose; fallback is the Toy Box set | user |
| 9 | Boss fight shapes (which parts are played as blocks) remain a game-design decision (art bible §5) | game-designer |
