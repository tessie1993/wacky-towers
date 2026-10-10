# ADR-0016: UI Architecture (Screens, Navigation, Theming, Portrait/Landscape Layouts)

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user), ui-programmer (author); to be checked by godot-specialist (engine validation), ux-designer (spec fit) and art-director (theme and frames)

## Summary

Every screen is its own Control scene under `src/ui/`. Each one is pushed and popped by `AppFlow`'s `ScreenStack` (ADR-0010) and implements one small `UiScreen` contract. Screens sit on fixed CanvasLayers (HUD < screens < pause < dialogs < toasts < loading cover). Each screen has **one node tree with two layout profiles** (portrait and landscape), swapped on `size_changed` by toggling container direction and anchor presets. There are not two layout scenes. One base `Theme` carries type variations, and each biome adds a small overlay Theme that only swaps the painted-wood frame StyleBoxes. All text is a translation key. Focus order is declared for keyboard and gamepad. Text scale, control scale, colourblind shapes and reduced motion come in as one `UiPrefs` value. The UI is a stateless projection: it renders from snapshots and signals passed in by `game/`, and it sends player intents back out as signals. It never writes sim, save or settings state.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | UI (Control, Theme, CanvasLayer, focus, translation, accessibility) |
| **Layer** | Presentation |
| **Knowledge Risk** | HIGH: 4.5 added AccessKit and recursive mouse/focus disable. 4.6 split mouse/touch focus from keyboard/gamepad focus. `docs/engine-reference/godot/modules/ui.md` was last verified on 4.6 and has no 4.7 section |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/ui.md`; ADR-0010 §3 (Back, focus after push/pop); `architecture-modular-layout.md` (the `ui` import row); `project.godot` (`window/stretch/mode="canvas_items"`, `aspect="expand"`, no translations registered yet); `assets/i18n/strings.csv`; `src/ui/_staging/` (prototype theme `wt_theme.tres`, `ui_kit.gd`, screens) |
| **Post-Cutoff APIs Used** | 4.6 dual focus (`grab_focus()` sets keyboard/gamepad focus only); 4.5 AccessKit names on Controls; `Control.auto_translate_mode` (4.3, replaces `auto_translate`); OS reduced-motion query (see verification item 3) |
| **Verification Required** | (1) 4.6/4.7 dual focus: after `grab_focus()` the focus ring shows for keyboard/gamepad and is hidden after a touch, with no extra code. If not, use the fallback in §6. (2) The AccessKit property names on `Control` in 4.7.2 (expected `accessibility_name` / `accessibility_description`). Probe them headless before any scene sets them. (3) Is there an OS reduced-motion query on 4.7.2 (expected `DisplayServer.accessibility_should_reduce_animation()`)? Does Android "remove animations" reach it? Probe headless, then test on device. If it is missing, the Settings toggle is the only source (§8). (4) A Theme set on an ancestor Control overrides the project theme for the same type and variation, and swapping it at runtime restyles the whole subtree in one frame. (5) `DisplayServer.get_display_safe_area()` on Android in both orientations, including with a notch in landscape. **Not verified yet**: every item above. None of them comes from the engine-reference files |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0010 (Accepted): `AppFlow`, `ScreenStack`, `back()`, pause and process modes, focus after push/pop. ADR-0001 (Accepted): `SimEvent` stream, and the view never blocks the sim |
| **Soft Depends On** | ADR-0012 input pipeline (GUIDE `menu` context drives the `ui_*` actions, and the last-device signal drives focus visibility). ADR-0013 save/profile/settings (source of the `UiPrefs` values, persistence). ADR-0014 camera/orientation and safe area (orientation-change signal, board screen rect). ADR-0015 audio and feedback (UI click events). The contracts this ADR needs from them are listed in §10 |
| **Enables** | Every screen and HUD story: Title, Profile select (4 save profiles in MVP, ADR-0013), Island map, Level intro, HUD, Pause, Results, Settings, Quit dialog, toasts, loading cover |
| **Blocks** | Meadow MVP plan step 4 (menus + flow) and GP-5 HUD (`src/ui/hud/*.tscn`) |
| **Ordering Note** | `UiScreen`, `OrientationLayout` and the base Theme come first, before any screen leaves `src/ui/_staging/`. ADR-0010 must be Accepted before a story that references this ADR can start |

## Context

### Problem Statement

The UX specs (`design/gdd/ux/`) give every screen a portrait and a landscape layout and a shared set of patterns (P1–P8). The HUD GDD makes the HUD display-only with same-frame updates. ADR-0010 owns the screen stack and Back, but nothing says what a screen *is*, how overlays stack, how a layout follows orientation, how the per-biome painted-wood frames are themed, or how accessibility settings reach the widgets. The `_staging` prototypes each solve these their own way, with a hand-built theme and positions set twice.

### Constraints

- Layering (`architecture-modular-layout.md`): `ui` may import only `core/model` value types and `SimEvents` constants. It must never import `game`, `data`, `view` internals or `mechanics`, so UI cannot call `AppFlow` or the settings store directly.
- ADR-0010: only `AppFlow.request_pause()` sets `tree.paused`. Only the Quit dialog's confirm quits. Screen ids are `StringName` constants.
- Android and PC/Steam ship together. MVP input is touch, keyboard/mouse and gamepad, so every screen must be fully usable with each one alone.
- All UI text goes through translation keys (English only for now). No analytics.
- Flagship phones and PC. Mobile renderer. Stretch is `canvas_items` / `expand`.
- Values are data. Sizes and timings come from the UX specs or a UI data file, never from literals in scripts.

### Requirements

- One screen = one scene. Overlays (Settings, Rules, dialogs) return to the screen below with its state intact (TR-menus-level-select-001).
- Back always goes exactly one screen back, and goes through `AppFlow.back()` (TR-menus-level-select-002).
- The HUD is display-only and updates in the same frame as its event (TR-hud-001). It stays inside the safe area and off the board rect. It has mirror and scale variants (TR-hud-003). The rule strip is driven by rule events (TR-hud-004).
- Both orientations work everywhere. Menus re-lay out instantly and keep focus. Play pauses, then re-lays out (P7, TR-camera-rotate-view-006).
- Painted-wood frames, one set per biome (Meadow first). Free rounded fonts. Custom painted icons.
- Text scale 100/125/150% (ACC-33). Control scale 75–200% with a hard floor of 56 dp for in-play buttons (decision sheet; see Deviations). Colourblind shapes (ACC-30/31). Reduced motion that follows the OS setting (ACC-40). Button labels (P6). Keyboard and gamepad focus on every screen (P4, ACC-15).

## Decision

### 1. Screens: one scene per screen, one contract

- Folders: `src/ui/screens/<screen>/<screen>.tscn` (+ `.gd`) for full screens and overlays, `src/ui/hud/` for the HUD, `src/ui/dialogs/` for the confirm/quit icon dialog, `src/ui/common/` for shared scripts and widgets. Prototypes in `src/ui/_staging/` move here one at a time and are deleted when moved.
- Every screen root extends `UiScreen` (`src/ui/common/ui_screen.gd`, `class_name UiScreen extends Control`):
  - `enter(is_resume: bool)` / `exit()`. ADR-0010's stack calls these. `is_resume = true` skips entry animations and skits.
  - `bind(snapshot)` renders the whole screen from one value object (§7). It is safe to call at any time and again after a rotation.
  - `default_focus() -> Control` is the control that gets focus on enter (P4: primary action; never a destructive one).
  - `back_rule: StringName` is read by `AppFlow.back()`: `&"pop"` (default), `&"resume"` (Pause), `&"to_map"` (Results), `&"quit_dialog"` (Title). This lists in data what ADR-0010 §3 already decides. Screens never handle `ui_cancel` themselves.
  - Intents are signals, e.g. `intent(id: StringName, args: Dictionary)`. Ids are constants in `UiIntents`. `game/` connects them when the screen is pushed.
- Sub-states that the spec treats as one Back step (Pause → Rules list, Pause → Confirm, Settings → layout editor) are separate stack entries, not hidden panels. This way Back stays one rule.
- Screens are instanced once and cached by `AppFlow` while they are on the stack. A popped overlay is freed. A screen uncovered by a pop keeps its nodes, so scroll position and the focused control survive (Island map, Settings).

### 2. Overlay layering: fixed CanvasLayers

| Layer | `layer` | Owner | Process mode | Contents |
|---|---|---|---|---|
| World | (3D) | `PlaySession/Stage` | PAUSABLE | Board, diorama, skits |
| HUD | 10 | `PlaySession/UI/Hud` | PAUSABLE (dims while paused) | Top band, thumb controls, countdown number |
| Screens | 20 | `AppFlow/Screens` | ALWAYS | Title, Profile select, Island map, Level intro, Results, Settings |
| Pause | 30 | `PlaySession/UI/PauseLayer` | WHEN_PAUSED | Pause sheet, Rules list, rotated-pause |
| Dialogs | 40 | `AppFlow/Dialogs` | ALWAYS | Confirm and Quit icon dialogs (only one at a time, ADR-0010) |
| Toasts | 50 | `AppFlow/Toasts` | ALWAYS | Non-modal notes (load error, unlock chip text). They never take focus |
| Cover | 60 | `AppFlow/Cover` | ALWAYS | Loading cover (ADR-0010 §4) |

- The layer numbers are constants in `UiLayers` (`src/ui/common/ui_layers.gd`), never literals in scenes.
- An overlay is parented to the CanvasLayer of the screen that opened it and draws above that screen. For example, Settings opened from Pause is a child of the Pause layer (so it also runs while paused), and Settings opened from Title is a child of Screens. The order of the CanvasLayers stays fixed.
- A modal layer sets `mouse_filter = STOP` on a full-rect backdrop so input never falls through to the HUD or the board. The 4.5 recursive disable is used on the covered screen to take it out of focus traversal.
- Toasts queue in order and show one at a time. Their duration is a value in `assets/data/ui/ui.json` that ux-designer sets (open question).

### 3. Navigation and the Back rule

- `AppFlow` and `ScreenStack` (ADR-0010) own push, pop and Back. This ADR adds only the `UiScreen` contract and `back_rule`. The on-screen ◀ and ✖ buttons emit `intent(&"back")`, which `game/` routes to `AppFlow.back()`. That is the same path as Android Back, Esc and gamepad B.
- After every push or pop, `AppFlow` calls `top.default_focus().grab_focus()`, but only while the input mode is keyboard/gamepad (§6).
- Results ignores input for 300 ms after its buttons appear (`results.md`). This is a screen-local input gate, not a stack rule.

### 4. Portrait/landscape: one tree, two layout profiles (chosen over two layout scenes)

- Each screen has **one node tree**. Its root gets an `OrientationLayout` helper (`src/ui/common/orientation_layout.gd`). The helper holds two `LayoutProfile` resources, `portrait` and `landscape`. Each profile is a list of `(NodePath, anchor preset, offsets, BoxContainer.vertical, size flags, visible)` entries for the few nodes that move. Everything else reflows through containers.
- Switching is driven by the root viewport's `size_changed`, checking `width >= height`. A hysteresis-free aspect test is fine because the aspect flips only on a real rotation or a PC window resize. The helper applies the profile in the same frame. ADR-0014 owns the play-time version: it pauses first, then the HUD applies its profile.
- The safe area comes from `DisplayServer.get_display_safe_area()`. It is turned into margins on a root `MarginContainer` in every screen and in the HUD (P7, TR-hud-003). A notch on one side gives asymmetric margins.
- The left-hand mirror is a third switch on the same helper. It flips the left and right groups (BoxContainer order / `layout_direction`) and keeps the rule strip centred. It is not a third layout.

**Why one tree and not two layout scenes:**
- The specs require focus to be kept across a rotation (title, island map, settings). With one tree, the focused control, the scroll position, a half-moved slider and a running tween all survive. With two scenes, every piece of that state has to be copied across and focus found again by name.
- Two scenes mean every new button is added twice, and the copies drift apart. P7 already says "nothing is hand-positioned twice".
- The P/L differences in the specs are mostly direction changes (bottom sheet ↔ right panel, row ↔ column, vertical ↔ horizontal path). Container direction plus a few anchor presets covers them.
- Trade-off: a screen whose two layouts truly differ in structure would need conditional nodes. If one ever does, that screen alone may use two child sub-trees under one `UiScreen` with shared widgets. This is a per-screen exception logged in its story, not a new rule.

### 5. Theming: one base Theme, per-biome frame overlays

- Base theme `assets/ui/themes/wt_base.tres` is set as the project theme (`gui/theme/custom`). It holds the fonts (free rounded fonts, `assets/fonts/`, licences next to the files), font sizes, colours, focus ring and every **type variation**: `PlateFrame`, `PanelSheet`, `PrimaryButton`, `IconButton`, `InPlayButton`, `ToastPanel`, `DialogPanel`, `GoalDigits` (fixed-width display digits). Scenes use `theme_type_variation` and never set theme overrides per node. This migrates `src/ui/_staging/theme/wt_theme.tres` and `ui_kit.gd`.
- Biome overlay themes, `assets/ui/themes/biomes/<biome>.tres` (Meadow first), contain **only** the frame StyleBoxes (`StyleBoxTexture` 9-slices from `assets/ui/frames/<biome>/`: wood with vines for Meadow) for those same variations, plus optional accent colours. The overlay is set on `AppFlow/Screens`, `Dialogs` and `PlaySession/UI` roots. Godot's theme lookup checks ancestor themes before the project theme, so anything the overlay leaves out falls back to the base. Changing biome is one assignment (verification item 4).
- Which biome is active comes from biome data (ADR-0005) through `UiPrefs.biome`. No screen names a biome.
- Icons are painted textures in `assets/ui/icons/`, referenced by theme icon entries or by `TextureRect`, never drawn in code. Frames never animate during play (art bible §7).

### 6. Focus, keyboard and gamepad (PC and Android with a pad)

- Menus use Godot's built-in `ui_accept`, `ui_cancel`, `ui_up/down/left/right` and `ui_focus_next/prev`. ADR-0012's GUIDE `menu` context injects or remaps them, so the UI never reads devices directly.
- Every screen declares its focus order (P4: top-left → bottom-right, primary first) through container order. Explicit `focus_neighbor_*` is set only for wrap-around and for profile-specific jumps (`LayoutProfile` entries may set neighbours). A gdUnit test walks each screen's focus chain in both profiles and fails on a dead end or an unreachable button.
- Focus visibility: "shown only after a key/pad input; first touch hides it" (P4). The plan is to rely on 4.6+ dual focus (verification item 1). Fallback: a `UiInputMode` value (`&"touch"` | `&"pointer"` | `&"keys"`) taken from ADR-0012's last-device signal swaps the `focus` StyleBox in the base theme to an empty one in touch mode.
- Menu buttons fire on release and in-play buttons fire on press (P2). This is set once in the variations' script (`InPlayButton` uses `action_mode = ACTION_MODE_BUTTON_PRESS`).
- Mouse hover is cosmetic only. Hover never moves keyboard focus (4.6 split).

### 7. UI is a stateless projection

- The UI owns **no game, save or settings state**. Each screen renders from a snapshot value built by `game/`:
  `TitleSnapshot`, `IslandMapSnapshot`, `LevelIntroSnapshot`, `ResultSnapshot`, `SettingsSnapshot`, `HudSnapshot`. These are `RefCounted` value types in `src/ui/common/snapshots/`, filled by `game/` from the profile, catalog and `LevelResult` (ADR-0010).
- The HUD gets its first `HudSnapshot` on Countdown entry, then gets `SimEvent`s forwarded by `BoardController` in the same frame (TR-hud-001, TR-hud-004). The HUD may keep the last values it drew so it can diff them and play pop-ins. That cache is rebuilt from a fresh snapshot on resume or rotation and is never read back by anything else.
- Out: intents only (`&"back"`, `&"play"`, `&"open_island"`, `&"retry"`, `&"next"`, `&"pause"`, `&"hold"`, `&"set_pref"` with `{key, value}`, …). `game/` turns them into `AppFlow` calls, `BoardController.push_command()` or settings writes (ADR-0013). Then it calls `bind()` again with the new snapshot, so a settings row shows the stored value, not the slider's guess.
- Test seam: every screen can be built in a test with a hand-made snapshot, without `AppFlow` or the sim. Intents are asserted with signal watchers.

### 8. Accessibility hooks

`UiPrefs` (value type in `src/ui/common/ui_prefs.gd`) is part of every snapshot. `game/` re-pushes it to every live screen (`apply_prefs(prefs)`) whenever settings change.

| Pref | UI effect | Source |
|---|---|---|
| `text_scale` 1.0/1.25/1.5 | `ThemeScaler` builds a scaled copy of the base and biome themes, multiplying font sizes (floors: 12 pt body, 18 pt HUD digits at 100%), and assigns it at the theme roots. Labels autowrap (`AUTOWRAP_WORD_SMART`). The HUD moves the clock and rule strip to a second row at 150% (HUD edge case) | ACC-33 |
| `control_scale` 0.75–2.0 | Multiplies `custom_minimum_size` of `InPlayButton` / `IconButton` widgets. Clamped so no in-play button goes below 56 dp and no menu target below 48 dp (ACC-14). `UiMetrics.dp_to_px()` converts using the screen scale | decision sheet, ACC-14 |
| `colourblind` off / shapes / shapes+contrast | UI-side shape cues: preview and hold plates use the shape-symbol material variant (ADR-0007 owns the shader), and the lock, star and ! icons already use shape. The danger line is board-side (ADR-0007) | ACC-30/31 |
| `reduced_motion` | `UiMotion.tween(...)` is the only tween helper in `ui/`. With reduced motion it gives instant changes or fades of 200 ms or less, with the same timing gates. Pulses become static rings. Default = the OS setting (verification item 3), overridable in Settings | ACC-40, decision sheet |
| `button_labels` menus/play | Shows or hides the text label next to icon-only buttons | P6 |
| `mirror` | `OrientationLayout` mirror switch (§4) | HUD rule 3 |
| AccessKit names | Every icon-only control sets an accessibility name from a translation key (`UI_A11Y_*`). Full TalkBack support is ACC-37 LATER | P6 |

Animation durations and easing come only from the UX specs or `assets/data/ui/ui.json` (e.g. squash 80 ms, pop-in 150–250 ms, resume beat 600 ms), never from script literals.

### 9. Text and translation keys

- Every visible string is a key in `assets/i18n/strings.csv` (`keys,en`; exists). It is registered under `internationalization/locale/translations`. Keys are `UI_<SCREEN>_<NAME>` (e.g. `UI_TITLE_CONTINUE`, `UI_PAUSE_RESUME`) and `UI_A11Y_<NAME>` for accessibility names.
- In scenes, `Label.text` / `Button.text` hold the key and `auto_translate_mode` is left on (inherit). Text built in code uses `tr("UI_RESULT_TIME").format({...})`. Digits (stars, times, progress) are formatted by one `UiFormat` helper and are never concatenated in screens.
- A gdUnit lint test scans `src/ui/**/*.tscn` and fails on any `text = "..."` that is not a key in the CSV. Level names come from level data as keys too (ADR-0005).

### 10. Contracts needed from sibling ADRs

| From | Needed |
|---|---|
| ADR-0012 input | `last_device_changed(mode)` signal; GUIDE `menu` context drives `ui_*` actions; remap screen API |
| ADR-0013 settings | Typed settings read for `UiPrefs`; write by key; `settings_changed` signal; text/control scale and reduced-motion override persisted |
| ADR-0014 camera/orientation | Orientation-change signal during Play (pause first); board screen rect for the HUD no-overlap check |
| ADR-0015 audio | UI click and feedback events. Widgets emit `intent(&"ui_sfx", {id})` and never play sounds themselves |

### Architecture Diagram

```
Main
 └ AppFlow ─ ScreenStack (ADR-0010) ── push/pop ─▶ UiScreen.enter/exit · default_focus · back_rule
     ├ Screens  (CanvasLayer 20, theme = biome overlay)  Title · ProfileSelect · IslandMap · LevelIntro · Results · Settings
     ├ Dialogs  (40)  Confirm / Quit       ├ Toasts (50)       └ Cover (60)
     └ World/PlaySession
          ├ Stage (3D)
          └ UI ├ Hud (10, PAUSABLE)  ◀── HudSnapshot + SimEvents (same frame) from BoardController
               └ PauseLayer (30, WHEN_PAUSED)  Pause · Rules · Confirm · Settings

game/ ── bind(snapshot) / apply_prefs(UiPrefs) ──▶ ui/        (read-only projection)
ui/   ── intent(id, args) ───────────────────────▶ game/      (AppFlow.back · push_command · set_pref)
project theme wt_base.tres ◀── fallback ── biomes/meadow.tres (frames only) ◀── ThemeScaler (text_scale)
OrientationLayout: viewport.size_changed ─▶ apply(portrait | landscape) + mirror + safe-area margins
```

### Key Interfaces

```gdscript
class_name UiScreen extends Control             # src/ui/common/ui_screen.gd
signal intent(id: StringName, args: Dictionary)
@export var screen_id: StringName
@export var back_rule: StringName = &"pop"      ## &"pop" | &"resume" | &"to_map" | &"quit_dialog"
func enter(is_resume: bool) -> void
func exit() -> void
func bind(snapshot: RefCounted) -> void         ## full re-render; idempotent
func apply_prefs(prefs: UiPrefs) -> void
func default_focus() -> Control

class_name OrientationLayout extends Node        # child of a screen root
@export var portrait: LayoutProfile
@export var landscape: LayoutProfile
func apply(is_landscape: bool, mirrored: bool, safe_margins: Rect2i) -> void
signal layout_applied(is_landscape: bool)

class_name LayoutProfile extends Resource        # list of per-node layout entries
class_name UiPrefs extends RefCounted            # text_scale, control_scale, colourblind, reduced_motion,
                                                 # button_labels_menu, button_labels_play, mirror, biome
class_name ThemeScaler extends RefCounted
static func scaled(base: Theme, factor: float) -> Theme
class_name UiMotion extends RefCounted
static func tween(node: Node, reduced: bool) -> Tween   ## bound to the tree, pause mode per layer
class_name UiLayers                               # const HUD := 10, SCREENS := 20, PAUSE := 30, ...
class_name UiIntents                              # const BACK := &"back", PLAY := &"play", ...
```

### Implementation Guidelines

- `ui/` must never import `game/`, `data/`, `mechanics/` or view internals. The existing layering test covers this.
- A screen must never call `get_tree().paused`, `get_tree().quit()`, a save or settings write, or `BoardSim`. It emits an intent.
- Never hardcode a visible string, a size, a colour or a duration in a scene or script. Use keys, theme variations and `ui.json`.
- Never position a node twice for P and L. Only `LayoutProfile` entries differ.
- Never set per-node theme overrides for frames or fonts. Use `theme_type_variation`.
- Never create a raw `create_tween()` in `ui/`. Go through `UiMotion`, so reduced motion is one switch.
- Every screen ships with screenshots of P and L at 100% and 150% text scale in `production/qa/evidence/`.

## Alternatives Considered

### Alternative 1: Two layout scenes per screen (`<screen>_p.tscn`, `<screen>_l.tscn`)
- **Pros**: Each layout is free-form. Easy to see in the editor.
- **Cons**: State and focus are lost or copied on every rotation. Every widget exists twice and drifts. Twice the scenes to review and screenshot.
- **Rejection Reason**: Conflicts with "focus kept" and with P7. It doubles the maintenance for differences that are mostly container direction.

### Alternative 2: Separate Theme per biome (full copies)
- **Rejection Reason**: Every font or size change has to be made N times. An overlay with frames only plus fallback to the base gives the same look with one source of truth.

### Alternative 3: UI reads sim/profile directly (screens hold references to `BoardController`, profile store)
- **Rejection Reason**: Breaks the `ui` import row, makes screens untestable without the full game, and lets UI drift into owning state.

### Alternative 4: Single CanvasLayer with z-index ordering
- **Rejection Reason**: Pause and dialog process modes and input blocking are cleaner per layer. Fixed layer numbers make "what draws above what" one table.

### Alternative 5: Scale UI via `Window.content_scale_factor`
- **Rejection Reason**: It scales everything uniformly, including the board area and the HUD band. Text scale and control scale are separate prefs with separate floors (ACC-33, ACC-14).

## Consequences

### Positive
- One contract for every screen. Back, focus and orientation behave the same everywhere.
- A new biome's look is one small Theme plus frame textures.
- Screens are unit-testable from hand-made snapshots. Intents are observable signals.
- Accessibility prefs are applied in one place each (`ThemeScaler`, `UiMotion`, `OrientationLayout`, widget scale).

### Negative
- `LayoutProfile` resources are a custom format that has to be edited per screen. An editor helper may be needed later.
- Snapshot types add boilerplate for each screen.
- A scaled theme copy is rebuilt on every `text_scale` change (rare, settings-time only).

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Dual focus does not hide the ring after touch on 4.7.2 | Medium | Low | Fallback focus StyleBox swap from `UiInputMode` (§6) |
| No OS reduced-motion query on 4.7.2 or Android doesn't report it | Medium | Medium | Settings toggle stays authoritative. First-run picker offers it (ACC-02) |
| 150% text overflows plates in P | Medium | Medium | Autowrap, second HUD row, screenshot gate at 150% in both profiles |
| Biome overlay misses a variation and falls back to the Meadow-less base | Low | Low | Test that asserts every frame variation exists in each biome overlay |
| AccessKit property names differ from expected | Medium | Low | Probe headless first (verification item 2). Names set from one helper |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| menus-level-select.md (TR-menus-level-select-001) | Screen state machine, overlays return to the screen below | One scene per screen + `UiScreen` contract on ADR-0010's stack; uncovered screens keep their nodes (§1) |
| menus-level-select.md (TR-menus-level-select-002) | Back returns exactly one screen | All Back sources → `intent(&"back")` → `AppFlow.back()`; `back_rule`; sub-states are stack entries (§1, §3) |
| menus-level-select.md (TR-menus-level-select-003) | Resume mid-level shows pause | Pause layer WHEN_PAUSED; HUD re-binds from snapshot on resume (§2, §7) |
| menus-level-select.md (TR-menus-level-select-006) | Settings persist | Settings screen is a projection; writes via `set_pref` intent to ADR-0013; re-bind shows stored value (§7) |
| hud.md (TR-hud-001) | Display-only; same-frame updates; never writes state | Snapshot + forwarded `SimEvent`s; intents out only (§7) |
| hud.md (TR-hud-003) | Safe area, off the board rect, mirror and 150% variants | `OrientationLayout` safe-area margins + mirror switch; `text_scale` second row; board rect from ADR-0014 (§4, §8) |
| hud.md (TR-hud-004) | Rule strip from rule start/end/blocked events | HUD consumes forwarded rule `SimEvent`s in the same frame (§7) |
| camera-rotate-view.md (TR-camera-rotate-view-006) | P and L; rotation mid-level pauses and re-lays out | `OrientationLayout` on `size_changed`; Play path pauses first via ADR-0014 (§4) |
| touch-controls.md (TR-touch-controls-007) | Scale, mirror, reduced motion persist | `UiPrefs` from ADR-0013 settings; applied by `apply_prefs` (§8) |
| ux/interaction-patterns.md P2–P7 | Buttons, Back/confirm, focus, wordless labels, orientation | §1–§6, §8 |
| accessibility-requirements.md ACC-14, 15, 30, 31, 33, 40, 37 | Targets, keyboard/pad, colourblind shapes, text scale, reduced motion, AccessKit | §6, §8 |

## Deviations from the UX specs (flagged for ux-designer)

- **Control scale range**: the UX specs say 100–150% (`interaction-patterns.md` P1, `settings.md`). The binding decision sheet (2026-10-10) says 75–200% with a 56 dp floor. This ADR follows the decision sheet. The floor makes 75% a no-op on in-play buttons that are already at the minimum. `settings.md` should be updated to match.
- **Text scale** stays 100/125/150% (ACC-33). It is a separate pref from control scale.
- **Reduced motion default**: the specs default it to Off. The decision sheet makes it follow the OS setting. This ADR follows the sheet.

## Performance Implications
- **CPU**: negligible. Re-layout runs only on rotation or resize. The HUD does same-frame diffs on events, not per-frame polling.
- **Memory**: cached screens on the stack (≤ 4 in MVP), one scaled theme copy, biome frame textures (one biome loaded).
- **Load Time**: screens are small scenes. Island map art is prefetched with the biome.
- **Network**: none.

## Migration Plan

No production UI exists yet. Changes when this ADR is accepted:
- Move `src/ui/_staging/*` into `src/ui/screens/`, `src/ui/hud/` and `src/ui/common/` one screen at a time, onto `UiScreen`. Move `wt_theme.tres` → `assets/ui/themes/wt_base.tres`.
- `project.godot`: `gui/theme/custom = res://assets/ui/themes/wt_base.tres`; register `assets/i18n/strings.en.translation` under `internationalization/locale/translations`.
- `architecture-modular-layout.md`: replace `ui/menus/` with `ui/screens/`, and add `ui/common/` and `ui/dialogs/`.
- `tr-registry.yaml`: point TR-menus-level-select-001/-006, TR-hud-001/-003/-004 at ADR-0016 (as co-owner with ADR-0010 for -001).
- `settings.md`: control scale range (see Deviations).

**Rollback plan**: the contract is a thin base class. Screens can drop `OrientationLayout` for per-screen code, or the theme overlay can be merged into the base, without touching `game/` or the sim.

## Validation Criteria

- [ ] [U] `ScreenStack` + `UiScreen`: every screen's `back_rule` produces exactly one step. Results → Map, Pause → resume, Title → Quit dialog.
- [ ] [U] Every screen binds from a hand-made snapshot with no `AppFlow` or sim present. Each button emits its intent id.
- [ ] [U] Focus walk: in both profiles every button is reachable by `ui_up/down/left/right`. The default focus is never destructive.
- [ ] [U] Lint: no non-key `text` in `src/ui/**/*.tscn`. Every key exists in `strings.csv`.
- [ ] [U] `ThemeScaler`: at every `text_scale`, body text is ≥ 12 pt and HUD digits ≥ 18 pt × the scale factor. `control_scale` 0.75 never gives an in-play button under 56 dp.
- [ ] [U] Every biome overlay defines every frame variation.
- [ ] [I] Rotate on Title, Island map and Settings: the same control keeps focus and the scroll position is kept. Rotate in Play: pause first, then the HUD re-lays out.
- [ ] [I] Reduced motion on: no `UiMotion` tween is longer than 200 ms or uses overshoot. Timing gates (300 ms Results, 600 ms resume beat) are unchanged.
- [ ] [I] Keyboard-only and gamepad-only: title → meadow_01 win → results → map, with no touch input.
- [ ] [M] Screenshots of every screen in P and L at 100% and 150% on the reference phone, in `production/qa/evidence/`. Nothing outside the safe area, and the HUD is off the board rect at all 12 yaws.
- [ ] [M] Android: the OS "remove animations" setting turns reduced motion on when the user has not overridden it (verification item 3).

## Related
- ADR-0010 (depends on: stack, Back, pause, process modes), ADR-0001 (SimEvent stream), ADR-0005 (biome data, level-name keys), ADR-0007 (shape-symbol materials, danger line)
- ADR-0012 input, ADR-0013 save/profile/settings, ADR-0014 camera/orientation/safe area, ADR-0015 audio/feedback (sibling contracts, §10)
- `design/gdd/hud.md`, `design/gdd/menus-level-select.md`, `design/gdd/ux/*.md`, `design/accessibility-requirements.md`, `design/art/art-bible.md` §4, §7
