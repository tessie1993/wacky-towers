# CH-177 Level intro card + countdown overlay

**MB task:** MB-035 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-165, CH-171; GDD ux/level-intro-countdown
**Files:** new `src/ui/screens/level_intro/level_intro.tscn` + `.gd`, `src/ui/common/snapshots/level_intro_snapshot.gd`, `src/ui/hud/countdown_number.gd` (Label that shows 3-2-1 from `HudSnapshot.countdown_n`); delete `src/ui/_staging/level_intro/`

## API
```gdscript
class_name LevelIntroSnapshot extends RefCounted
var level_number: int; var name_key: String; var goal_icon: StringName; var goal_target: int
var rule_icons: Array[StringName]; var best_stars: int; var star2_ms: int; var star3_ms: int
var skip_card: bool
class_name LevelIntro extends UiScreen    ## &"level_intro", back_rule &"pop"; intents PLAY, BACK; rule icon tap expands one line
```

## Behaviour
- Card: bottom sheet (P, 60%) / right panel (L, 45%): number + name, goal icon + digits, <= 3 rule icons with two-word names, best stars, star times as clock icon + digits, Play 72 pt. No sentence text except rule names.
- Countdown is the HUD's state (CH-062); `CountdownNumber` shows the big number, centred on the board rect, H1 x 2 with ink outline; touches during it do nothing.
- New-control spotlight: dims HUD except named buttons with a pulsing ring (static ring with reduced motion); shown first play only (flag in snapshot `spotlight: Array[StringName]`).
- `skip_card` true on retry and first-ever meadow_01.

## How the integrator sees it working
Scratch scene: card for meadow_01 (goal layers x4, star times 2:25 / 1:45). ADR-0016 rules: root extends `UiScreen`; one node tree for portrait + landscape via `OrientationLayout`; text only as `UI_*` keys added to `assets/i18n/strings.csv`; menu buttons fire on release; all targets >= 48 dp; inside the safe area; no state kept (render from the snapshot). Move/replace the matching file in `src/ui/_staging/` (written before the ux docs: reuse ideas, delete the old file when done).
Resize the window (godot-ai) to 390x844 and 844x390; screenshots to `production/qa/evidence/MB-035/`: P and L; Play -> countdown 3-2-1 for 3000 ms +- 1 frame on the scratch HUD; keyboard/pad reach Play, rule icons, back.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
