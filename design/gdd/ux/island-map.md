# Island map

> The MVP's only menu hub: the **cloud wizard** (the player) floats over the Meadow's 10 level islands (shapes from `design/levels/meadow.md` §1) and the bonus island. Replaces main menu, world map and level select (see README). Patterns: [interaction-patterns.md](interaction-patterns.md).

## States

| Island state | Look | Non-colour cue | Tap |
|---|---|---|---|
| Locked | Desaturated, in cloud, small | Padlock icon | Lock wiggle + clunk |
| Open (new) | Full colour, Pip waving, bobbing | ! flag | Wizard flies → Level intro |
| Finished | Full colour | 1–3 stars under it (filled vs outlined star shapes) + best time | Wizard flies → Level intro |
| Bonus locked | Cloud island with picnic basket | Padlock + "★ 20" counter (e.g. `★ 14 / 20`) | Wiggle + bubble showing the counter |
| Bonus open | Basket island, ants | ! flag | → Level intro |
| Next-biome bank | Cloud bank at the end of the path | "★ 15" gate + needs-10 flag | Wiggle + bubble |

| Screen state | Enters | Leaves |
|---|---|---|
| Idle | Arrive; wizard hovers over the last played (or newest open) island | Tap |
| Flying | Tap an open island; wizard flies (≤ 500 ms, tap again to skip; reduced motion = cut) | Arrive → Level intro |
| Unlock reveal | Returning from a win that opened something | Cloud puffs away from the new island (≤ 1.5 s, tap skips); chime |

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Path | Winding **vertical** path, 01 at the bottom, 10 at the top; scrolls vertically; 4–5 islands visible | Winding **horizontal** path, 01 left, 10 right; scrolls horizontally; 5–6 visible |
| Bonus island | Floats off the path beside 07–08 | Floats above the path near 07–08 |
| Top bar (safe area) | ◀ back (Title) left · biome star total `★ 17 / 30` centre · ⚙ right | Same |
Each island hit area ≥ 72 pt round; labels: level number on a parchment tag (digits), stars + time under it. Auto-scroll centres the wizard's island on entry.

## Interactions

| Input | Result |
|---|---|
| Tap open island | Fly → Level intro (taps-to-play: island 1, Play 2) |
| Drag / swipe | Scroll the path (no inertia beyond the ends) |
| Tap locked island / bank | Feedback only, no navigation |
| Keys / pad | ◀ ▶ (L) or ▲ ▼ (P) step along islands in order, bonus reached by the perpendicular direction from 07–08; A/Enter = open |
| Back | Title |
| ⚙ | Settings overlay |
Drag vs tap: a touch that moves > 12 pt is a scroll, never a tap (Touch F2 dead zone).

## Edge cases

- **All 10 finished, < 15 ★**: bank bubble shows `★ 12 / 15` and the islands still under 3★ get a small sparkle (where to earn more; Campaign edge case).
- **15 ★ and 10 finished in MVP**: bank shows "soon" signpost (no next biome built).
- **Bonus reaches 20 ★ during a results screen**: reveal plays on the next map visit, once.
- **Hard track H1–H3**: not in MVP; hidden.
- **Orientation change**: path re-lays out; the focused/wizard island stays centred.
- **Level missing / Draft (dev)**: island hidden, path skips it (Menus edge case).

## Acceptance criteria

1. [I] Fresh save: 01 open, 02–10 locked, bonus locked showing `★ 0 / 20`.
2. [I] Finishing 03 with ★★ opens 04 with a reveal; 03 shows 2 filled star shapes and best time.
3. [I] At 20 meadow ★ the bonus opens; bonus stars do not count toward the 15★ bank gate.
4. [I] Any open island → Level intro in 1 tap; Play in 2.
5. [I] P and L: every island ≥ 72 pt hit area, nothing outside the safe area; state readable in greyscale (lock, !, star shapes).
6. [I] Keyboard-only and gamepad-only can reach every island, bonus, back and ⚙.
7. [I] A 20 pt drag on an island scrolls and does not open it.
