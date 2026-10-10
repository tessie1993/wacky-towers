# CH-176 Island map screen (cloud wizard over 10 islands)

**MB task:** MB-035 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-171; GDD ux/island-map; data `assets/data/campaign/meadow_map.json`
**Files:** new `src/ui/screens/island_map/island_map.tscn` + `.gd`, `island_node.tscn` + `.gd`, `src/ui/common/snapshots/island_map_snapshot.gd`; delete `src/ui/_staging/campaign/` when done

## API
```gdscript
class_name IslandMapSnapshot extends RefCounted
var islands: Array        ## per island: {id, number, state: &"locked"|&"open_new"|&"finished", stars: int, best_ms: int, pos: Vector2}
var bonus_state: StringName; var star_total: int; var star_max: int; var bank_gate: int
var wizard_at: StringName
class_name IslandMap extends UiScreen    ## &"island_map", back_rule &"pop"; intents OPEN_LEVEL {id}, OPEN_SETTINGS, OPEN_PROFILES, BACK
```

## Behaviour
- Winding path (vertical in P, horizontal in L), scrolls; 01 first; islands >= 72 pt round hit areas; level number on a tag; stars (filled vs outlined shapes) + best time under finished islands; locked = padlock + desaturate; open-new = "!" flag. Bonus island and next-biome bank per the state table.
- A touch that moves > 12 pt is a scroll, never a tap. Tap open island -> wizard flies (<= 500 ms, tap skips, reduced motion = cut) then intent OPEN_LEVEL. Locked tap = wiggle only.
- Wizard = placeholder sprite/Control. Positions come from `meadow_map.json`.
- Keys/pad step along islands in order; A/Enter opens. Focus and scroll survive rotation.

## How the integrator sees it working
Scratch scene with a snapshot (03 finished with 2 stars, 04 open, rest locked, bonus locked `14 / 20`). ADR-0016 rules: root extends `UiScreen`; one node tree for portrait + landscape via `OrientationLayout`; text only as `UI_*` keys added to `assets/i18n/strings.csv`; menu buttons fire on release; all targets >= 48 dp; inside the safe area; no state kept (render from the snapshot). Move/replace the matching file in `src/ui/_staging/` (written before the ux docs: reuse ideas, delete the old file when done).
Resize the window (godot-ai) to 390x844 and 844x390; screenshots to `production/qa/evidence/MB-035/`: P and L; a 20 pt drag on an island scrolls without opening; keyboard-only reaches every open island, back and settings.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
