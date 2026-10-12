# UI theme: frames, fonts, icons, states

> **Status**: Draft (ux-designer, 2026-10-10) · **Scope**: every screen and the HUD. Values are tunable defaults, not rules.
> **Technical truth**: ADR-0016 §5 (one base Theme + per-biome frame-only overlay), §8 (UiPrefs). **Look**: `design/art/art-bible.md` §4.5, §7 (art-director owns the final look; this file fixes structure, states, sizes and accessibility).
> **User decisions (2026-10-10)**: painted-wood frames with a frame set per biome (Meadow first); free rounded fonts; custom painted icons; colourblind shapes on by default.
> Patterns: [interaction-patterns.md](interaction-patterns.md).

## 1. Structure (how the theme is built)

| Layer | File | Holds | Never holds |
|---|---|---|---|
| Base theme | `assets/ui/themes/wt_base.tres` (project theme) | Fonts, sizes, text colours, focus ring, every type variation (§4), fallback (Meadow) frames | Anything biome-specific beyond the fallback |
| Biome overlay | `assets/ui/themes/biomes/<biome>.tres` | **Only** the frame StyleBoxes for the same variations, plus optional accent colours (e.g. a biome tint on the tab underline) | Fonts, sizes, text colours, icons |
| Frame textures | `assets/ui/frames/<biome>/` | 9-slice painted frames (§2) | Text, icons |
| Icons | `assets/ui/icons/` | Painted icon sheet (§5), shared by every biome | Frames |
| Fonts | `assets/fonts/` | Font files + `OFL.txt` next to each family | n/a |

- A screen picks its look only with `theme_type_variation`; no per-node overrides (ADR-0016).
- Which overlay is active comes from `UiPrefs.biome` (biome data). Switching biome is one theme assignment at the `Screens`, `Dialogs` and `PlaySession/UI` roots.
- Plate **interiors are always parchment + ink** in every biome (art bible §7), so text reads the same everywhere. Only the frame around the parchment changes.

## 2. Painted-wood frames, one set per biome

Every biome's frames are **painted wood dressed for that biome** (user decision). The art bible §7 table (ice, stone, rune/neon, marble frames) predates this decision; art-director should update it (flagged).

### Frame set (every biome overlay must define all of these; a unit test checks it, ADR-0016)

| Frame | Used by variation | 9-slice notes |
|---|---|---|
| Plate frame | `PlateFrame` (HUD plates, island tags, info plates) | Rounded rect, chunky bevel, parchment insert |
| Sheet frame | `PanelSheet` (Settings, Pause, Profile select, Credits) | Large; trim on the outer edge only |
| Dialog frame | `DialogPanel` (confirm, save notices) | Heavier outer edge so it reads above a dimmed screen |
| Toast frame | `ToastPanel` | Thin, no trim (it sits near controls) |
| Pill frame | `PrimaryButton` | Pill shape (art bible: pill = action) |
| Round frame | `IconButton` | Circle-ish rounded square (not a pure circle: circle = item, art bible §3) |
| In-play frame | `InPlayButton` | Same as round frame, **no trim at all** (nothing decorative near the thumbs) |
| Tab frame | `TabButton` (proposed, §4) | Top edge only in P, left edge only in L |
| Card frame | `ProfileCard` (proposed, §4) | Rounded rect with a nameplate notch |

### Rules for all frames

- Trim (vines, nails, icicles, drips) stays under **10% of plate height**, points **away** from the board and the thumb zones, and never enters the parchment (art bible §7).
- Trim is drawn with the StyleBox **expand margins**, so it never shrinks the content area and **never counts toward a touch target** (P1).
- Every frame has a **dark neutral outer edge** (ink at about 80%), so it never vanishes into a same-colour backdrop.
- Frames never animate during play (art bible §7). In menus, a frame may play one settle bounce on pop-in only.
- One overlay loaded at a time (memory: one biome's frame textures, ADR-0016 Performance).

### Per-biome dressing (proposals for art-director; the 5 later biomes are named by designers)

| Biome | Wood | Trim | Watch for |
|---|---|---|---|
| **Meadow** (MVP) | Warm painted oak, visible brush grain, 2 brass nails per long edge | Clover and ivy vines on the top corners, one tiny daisy | Vine green vs. the lime piece; keep vines on frame corners only |
| Candy / bakery | Pastel-painted wood like a toy shelf | Icing drips (short, pointing outward), sprinkles | Pink and cyan sprinkles must not read as debuff/buff accents |
| Ice / snow | Frosted pale wood | Snow caps, short icicles pointing outward | Frame vanishing into snow: rely on the dark outer edge |
| Lava / volcano | Charred dark wood | Ember cracks, **painted, not glowing or animated** | Ember orange vs. hazard orange: keep embers dull, below 60% saturation |
| Underwater / reef | Driftwood | Barnacles, a strand of kelp | Teal water vs. buff cyan |

## 3. Colours (from the art bible; starting values)

| Role | Value | Use |
|---|---|---|
| Ink | `#2E2433` | All text, outlines, focus ring inner line |
| Parchment | `#FFF4DE` | Every plate and sheet interior (≥ 90% opacity in play; 100% in high-contrast mode) |
| White | `#FFFFFF` | Focus ring outer line, highlights, text on dark only |
| Reward gold | `#FFC83D` | Primary button face, stars; always paired with a star or sparkle shape |
| Meadow wood (proposal) | from the Grass palette: brick `#A88468` family, moss `#7E9C5E` vines | Meadow frames only |
| Buff / debuff / hazard | `#1FD3E6` / `#E62AA0` / `#FF6A13` | Rule-strip chevrons and triangle frames only (art bible §4.1); never decoration |
| Danger | `#F23A3A` | **Board only** (danger line). UI never uses danger red, not even for Delete (Delete uses the bin icon + ✖ shape) |
| Player colours | `#D93A4F` / `#3D7BE0` / `#4DB33D` / `#8A4FD6` | Multiplayer frames later; not used in the Meadow MVP UI |

**Contrast** (computed): ink on parchment ≈ 13.5 : 1, ink on gold ≈ 9.6 : 1. Both pass the 4.5 : 1 body and 7 : 1 HUD-number targets (hud.md readability). Any new text/background pair must be checked against the same targets before it ships.

## 4. Type variations and states

ADR-0016 lists the base variations: `PlateFrame`, `PanelSheet`, `PrimaryButton`, `IconButton`, `InPlayButton`, `ToastPanel`, `DialogPanel`, `GoalDigits`. This spec **proposes three more** for ui-programmer to confirm: `TabButton` (Settings tabs), `ProfileCard` (profile select), `ToggleRow` (a full-width settings row that toggles on tap).

### Button states (all button variations)

| State | Look | Non-colour cue (must exist) | Applies to |
|---|---|---|---|
| Idle | Frame + face (gold pill for Primary, parchment for the rest), ink icon/label | n/a | All |
| Hover (PC pointer only) | Lift 2 pt + face 6% lighter | Lift (shape/position) | Menus only; cosmetic, never moves focus (ADR-0016 §6) |
| Focused (keys/pad) | **Double ring**: 3 pt ink inside, 2 pt white outside, plus 2 pt lift | Ring shape | All; shown only after a key/pad input, hidden after a touch (P4) |
| Pressed | Press squash (below) + face 8% darker | Squash (shape) | All |
| Toggled on / selected | Filled knob or tab with a ✔ notch; tab gets a thick underline (P) or side bar (L) | ✔ notch, bar | Toggles, tabs, selected option chips |
| Disabled (menus) | 50% opacity + lock icon on the face | Lock icon | Menus only. **In play, unavailable controls are hidden, not disabled** (Touch rule 9) |
| Destructive | Parchment face, bin icon, ✖ shape | Bin icon | Delete profile, quit dialog ✔ |

### Panel states

| Panel | States |
|---|---|
| `PlateFrame` | Normal · **Warm** (danger state: plate edges darken warm; never a red fill; hud.md) · Dimmed (paused: 50% under the pause sheet) |
| `PanelSheet` / `DialogPanel` | Enter (pop-in) · Idle · Exit. A modal sheet dims what is below to 50% black |
| `ToastPanel` | Enter (slide 12 pt + fade) · Idle · Exit (fade). Never takes focus |
| `ProfileCard` | Filled · Empty ("+") · Active (thick ring + small ✔ badge) · Edit mode (✎ and bin chips appear) |

### Motion timings (all values go in `assets/data/ui/ui.json`, never script literals; ADR-0016)

| Motion | Default | Range | Reduced motion (follows the OS, ADR-0013 §7) |
|---|---|---|---|
| **Press squash** (full cycle) | **180 ms**: squash to 92% in the first 50 ms, spring back with a 105% overshoot, settle | **150–250 ms** (art bible §7, touch-controls Visual) | No scale: face darkens for 100 ms |
| Pop-in (plates, sheets, dialogs) | 200 ms, overshoot to 110% | 150–250 ms in play; menus up to 350 ms | 150 ms fade, no scale |
| Screen push / pop (menus) | 280 ms slide + fade | 200–350 ms | 150 ms cross-fade |
| Star stamp (results) | 250 ms per star, bounce | 200–350 ms | Instant, one soft sparkle frame |
| Toast | in 200 ms, stay 4 s, out 200 ms | stay 2–6 s | Fades only |

- **The squash never delays the action.** Menu buttons fire on release, in-play buttons on press (P2), whatever the animation is doing.
- **The squash scales a visual child (the button face), never the Control itself**, so the hit area never shrinks while pressed. This also keeps the 56 dp floor true during the animation.
- This replaces the "squash 80 ms" in `interaction-patterns.md` P2 and the "squash 80 ms" example in ADR-0016 §8 (resolved 2026-10-10: both now read 150–250 ms).

## 5. Fonts (free, rounded)

| Role | Recommended | Alternatives | Licence | Why |
|---|---|---|---|---|
| **Display** (titles, numbers, H1–H2, HUD digits) | **Fredoka** (variable, weight 300–700, width axis) | Baloo 2 (400–800); M PLUS Rounded 1c (Black) | SIL OFL 1.1 (all three) | Heavy, round, toy-like, matches the block bevel (art bible §7). One variable file covers H1–H3 |
| **Body** (menus, descriptions, credits, privacy note) | **Nunito** (variable, weight 200–1000) | Varela Round; M PLUS Rounded 1c (Medium) | SIL OFL 1.1 (all three) | Rounded terminals, very readable at 12–14 pt, wide language coverage for later locales |

- **Fixed-width digits** (`GoalDigits`, HUD clock, star counts): use the font's tabular figures (`tnum`) through a `FontVariation` with OpenType features. **Verification needed**: confirm Fredoka has `tnum`. If it does not, `GoalDigits` uses Nunito ExtraBold with `tnum` (to be verified too), or Baloo 2.
- Display text gets a 2–3 pt ink outline (theme `outline_size` + `font_outline_color`) where it sits on art (Title logo, skit bubbles). Text on parchment needs no outline.
- Import the display font as MSDF so text scale changes stay crisp (import option; ui-programmer to confirm cost on device).
- `OFL.txt` sits next to every font file, and the fonts are named in Credits (credits.md).

### Sizes at 100% text scale (art bible §7; floors from ADR-0016 §8)

| Level | Use | Font, weight | Size (pt) |
|---|---|---|---|
| H1 | Win/lose banner, screen titles | Display Bold (700) | 36 (32–40) |
| H2 | HUD numbers, timer, star totals | Display SemiBold, `tnum` | 24 (24–28; **never < 18**) |
| H3 | Labels, tab names, profile names | Display Medium or Body Bold | 16 (14–16) |
| Body | Settings rows, credits, privacy | Body SemiBold (600) | 14 (**never < 12**) |
| Small | Licence lines, version number | Body Regular | 12 (floor) |

Text scale 100 / 125 / 150% multiplies every size (ADR-0016 `ThemeScaler`). Labels autowrap; nothing clips. At 150% the HUD moves the clock and rule strip to a second row (hud.md GDD).

## 6. Painted icon sheet (MVP list)

Style: art bible §7 Iconography: painterly prop, one ink outline, two tones + highlight, readable as a silhouette at **32 px**; fitted to its container (round for buttons). No icon may look like a block piece. Every icon-only control also has an AccessKit name and an optional text label (P6).

| Group | Icons |
|---|---|
| Navigation | back ◀, close ✖, confirm ✔, next ▶▶, map (island), home/title, quit (door) |
| Play control | pause ❚❚, resume ▶, restart ↺, rules list (scroll) |
| In-play buttons | d-pad arrow (one, rotated ×4), **Turn ◀ / ▶** (flat curved arrow around a vertical post), **Flip ◀ / ▶** (upright curved arrow, front-to-back), **Roll ◀ / ▶** (arc around a dot, the view axis), hard drop (heavy down arrow + dust), soft drop (light down arrow), View ◀ / ▶ (eye with arc), corner view (square with one filled corner, ×4), hold (reserved, empty slot) |
| Status | lock, star filled, star outline, ! new flag, warning token (and broken token), clock, sparkle (more stars here), "soon" signpost |
| Goals | one per goal type in Level Goals (count, height, fill, survive, …): list taken from `level-goals-fail-states.md` when it is final |
| Settings tabs | speaker (Sound), screen (Screen), gamepad+hand (Controls), camera (Camera), accessibility figure (Access), ⓘ (Info) |
| Settings rows | music note, SFX burst, UI click, haptics (buzzing phone), mirror, layout editor (move arrows), keyboard, gamepad, touch, eye (reduced motion), shapes (colourblind aid), text size (Aa), button size, labels, gizmo rings, relaxed timing (snail), orientation lock (phone with padlock) |
| Profiles | add "+", edit ✎, delete (bin), dice (random name), 8 badges (§7) |
| Notices | save problem (cracked scroll), backup restored (scroll with ↺), update needed (scroll with ▲), saving (quill), loading (cloud wizard swirl), credits (heart), privacy (shield with a leaf) |

Rule-strip icons (twists, mechanics, buffs) come from the rule data and art bible §4.1 frames; they are not in this sheet.

## 7. Colourblind shapes (on by default)

Setting: Off · **Shapes** (default; costs nothing) · Shapes + high contrast (ADR-0013 `colorblind`; settings.md). UI-side rules; board-side ones (hatched ghost, dashed danger line, piece motifs) are ADR-0007 and hud.md.

| Information | Colour cue | Shape cue (always on, even with the setting Off) | Added by "Shapes" |
|---|---|---|---|
| Focus | White + ink ring | Double ring + lift | n/a |
| Selected / on | Gold face | ✔ notch, filled knob | n/a |
| Disabled | 50% opacity | Lock icon | n/a |
| Destructive | n/a (no red in UI) | Bin icon, ✖ | n/a |
| Confirm vs cancel | n/a | ✔ vs ✖ glyph, fixed positions (P3) | n/a |
| Stars earned | Gold | Filled vs outlined star shape | n/a |
| Island state | Saturation | Lock / ! / stars | n/a |
| Buff / debuff / hazard | Cyan / magenta / orange | Up chevron / down chevron / triangle | Thicker icon outline |
| Preview and hold pieces | Piece hue | Silhouette | Piece motif symbol (shape-symbol material, ADR-0007) |
| Profile identity | Profile colour | Badge (8 distinct silhouettes) | n/a |
| Danger state on plates | Warm edge tint | ! icons at the danger line ends (board) | Plate edge gets a stripe pattern |

**Shapes + high contrast** also: plates 100% opaque, ink outlines from 2 pt to 3 pt, all text at ≥ 7 : 1, decorative trim drawn at 50% so frames read as clean edges.

## 8. Edge cases

- **Biome overlay missing a frame**: falls back to the base theme's Meadow frame (ADR-0016 risk table); the overlay test fails in CI first.
- **Text scale 150% in a small plate**: the plate grows (containers), never clips; if a row cannot grow, the label wraps to 2 lines. Screenshot gate at 150% in P and L (ADR-0016).
- **Control scale 75% with in-play buttons**: the 56 dp floor wins; spacing and decoration shrink first (ADR-0012 §5).
- **Reduced motion changes while a squash plays**: the running tween finishes; the next press uses the new setting.
- **High contrast + Candy biome sprinkles**: trim at 50% keeps sprinkle colours from being read as accents.
- **Missing glyph** (a typed profile name with an emoji or a script the font lacks): the font's fallback chain (Nunito → Godot default font) draws it; never a blank box for Latin text. Emoji are stripped at name entry (profile-select.md).

## 9. Acceptance criteria

1. [U] Every biome overlay defines every frame variation in §2 (ADR-0016 test).
2. [U] Press squash: duration read from `ui.json`, within 150–250 ms; under reduced motion no scale tween runs.
3. [I] While a button is held mid-squash, its hit rect equals its idle rect (scale applies to the face child only).
4. [M] Greyscale screenshot of Title, Island map, Settings, HUD: focus, selected, disabled, destructive, stars, island states and Turn / Flip / Roll buttons are all distinguishable.
5. [M] Each icon in §6 reads as a silhouette at 32 px (art-director review sheet).
6. [I] At 100% text scale, no text is under 12 pt and no HUD number under 18 pt; at 150% nothing clips in P or L (screenshots in `production/qa/evidence/`).
7. [U] Contrast: each text/background pair used by a variation passes 4.5 : 1 (body) and 7 : 1 (HUD numbers).
8. [M] Fonts: `OFL.txt` present next to each font file; Credits lists each family.

## Open questions

- **Fredoka `tnum`**: verify before `GoalDigits` is built (§5).
- **Three new variations** (`TabButton`, `ProfileCard`, `ToggleRow`): ui-programmer to confirm or fold into existing ones.
- **Art bible §7 frame table**: art-director to update to "painted wood per biome".
