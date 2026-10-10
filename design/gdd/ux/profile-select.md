# Profile select (create, rename, delete)

> **Status**: Draft (ux-designer, 2026-10-10) · **MVP**: yes (user decision 2026-10-10: 4 save profiles from the start).
> **Technical truth**: ADR-0013 §6 (4 slots, index is the single source of truth, create/rename/delete/switch order, `needs_profile_select()`), ADR-0016 (screen `&"profile_select"` on the Screens layer, intents only). Values are tunable defaults.
> Patterns: [interaction-patterns.md](interaction-patterns.md) · Look: [ui-theme.md](ui-theme.md).

## Purpose

Let up to 4 people share one device (a family tablet, a shared PC), each with their own stars, unlocks and personal settings (controls, camera, accessibility; ADR-0013 §7). A returning player with a remembered profile **never sees this screen** unless they ask for it (≤ 10 s launch to play, TR-menus-level-select-007).

## When it appears

| Trigger | Opens in | Back goes to |
|---|---|---|
| First launch (all 4 slots empty): Title → **Play** | **Create** directly (one slot, name pre-filled) | Title |
| Boot with `needs_profile_select()` true (last-used slot deleted, empty or unreadable) | List | Title |
| Player taps the **profile chip** on Title or the Island map | List, focus on the active card | The screen that opened it |
| The active profile was just deleted | List (no profile active) | Title |

The profile chip (badge + name, 48 pt tall, top-left inside the safe area) is new on Title and the Island map. `title.md` and `island-map.md` must add it (flagged; `title.md` currently puts a non-interactive cloud-sync icon there, which has nothing to show in the MVP because cloud is a null backend).

## States

| State | Shown | Leaves |
|---|---|---|
| **List** | 4 slot cards; ✎ Edit toggle; ◀ back | Tap a filled card → switch; tap "+" → Create; ✎ → Edit |
| **Create** (own stack entry) | Name field (pre-filled), 🎲 random name, colour row, badge row, ✔ | ✔ → profile made and active; ◀ → List (or Title if all empty) |
| **Edit** (mode of List, not a new screen) | Each filled card shows ✎ rename and bin chips; ✔ Done | Done / Back → List |
| **Rename** (own stack entry) | Same panel as Create, with the current name, colour, badge | ✔ saves; ◀ discards |
| **Delete confirm** (dialog, Dialogs layer) | Card picture, name, what is lost (`Mia · 23 ★ · 9 levels`), ✖ keep / bin ✔ delete | Either button; Back = ✖ |

Create, Rename and Delete confirm are separate stack entries, so Back is always one step (ADR-0016 §1).

## Slot cards

| Card | Shows | Tap |
|---|---|---|
| Filled | Badge on the profile colour (64 pt), name (H3, as typed, never translated), `★ 23`, small island icon + furthest level number | Switch to this profile → return to the opener (Title shows this profile's Continue) |
| Active | As filled + thick ring and ✔ badge | Return to the opener (no reload) |
| Empty | "+" on parchment | Create. The new profile always takes the **lowest empty slot** (ADR-0013), so the "+" shows only on that card; other empty slots show a faint dotted outline and do nothing |

Identity never relies on colour alone: the **badge silhouette** is the main cue (ui-theme.md §7).

- **Colours** (6): Lemon, Lime, Mint, Sky, Lavender, Peach (piece palette, art bible §4.2; fine here because menus are off the playfield). Stored as an id (`"sky"`).
- **Badges** (8 painted silhouettes): acorn, mushroom, snail, bee, daisy, leaf, cloud, wizard hat. Stored as an id (`"acorn"`). Two profiles may share a badge; the name tells them apart.
- New profile defaults: next unused colour and badge, so 4 profiles start distinct.

## Name entry

| Rule | Value (ADR-0013 knob `profile_name_length`) |
|---|---|
| Length | 1–12 characters after trimming |
| Allowed | Letters, digits, spaces, `-`, `'`; control characters and emoji stripped |
| Unique | Case-insensitive across the 4 slots |
| Pre-fill | A random friendly name from a translated list (`UI_PROFILE_NAME_*`, e.g. Pip, Clover, Bramble). Once saved it is stored as plain text |

- **Touch**: tapping the field opens the OS keyboard (`LineEdit` virtual keyboard). The pre-filled name means a child who cannot type taps ✔ and plays.
- **Keyboard**: type directly; Enter = ✔.
- **Gamepad only**: 🎲 picks another name (A on 🎲); colour and badge rows by d-pad. No custom on-screen keyboard in the MVP. On Steam (Big Picture / Deck) the field may open Steam's floating gamepad keyboard through GodotSteam (PC feature tag only; to be confirmed by ui-programmer).
- **Invalid name** (empty, duplicate): ✔ stays enabled; pressing it shakes the field once (reduced motion: outline only), shows ✖ icon + short line (`UI_PROFILE_NAME_TAKEN` / `UI_PROFILE_NAME_EMPTY`), and keeps focus in the field. Nothing is written.

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Top bar | ◀ back left · title "Who's playing?" (H1, icon + 2 words) · ✎ Edit right | Same |
| Cards | 2 × 2 grid, each ≥ 150 × 150 pt | 1 × 4 row, each ≥ 150 × 180 pt |
| Create / Rename panel | Bottom sheet: name field + 🎲 on top, colour row, badge row (2 rows of 4), ✔ full-width pill 64 pt | Right panel 55% width, same order; live card preview on the left |
| Delete dialog | Centred, ✔ (bin) at the bottom, ✖ above it | Centred, ✖ left, ✔ (bin) right |

All targets ≥ 48 dp × control scale (P1); colour and badge chips 56 pt. Inside the safe area (ADR-0014 `ScreenLayout`).

## Interactions

| Input | List | Create / Rename |
|---|---|---|
| Tap / A / Enter | Card: switch or create | Field: edit; chip: select; ✔: save |
| D-pad / arrows | Move between cards (wraps), then ✎ and ◀ | Field → 🎲 → colours → badges → ✔ |
| Back / Esc / B | One step back (table above) | Discard, back to List |
| Long press | Nothing (Edit is a visible toggle, not a hidden gesture) | n/a |

**Default focus**: the active card (List), the ✔ button (Create, so one press accepts the pre-filled name), the ✖ keep button (Delete confirm; the destructive button is never the default, P3).

## Delete safety

- Delete exists only in Edit mode, only on this screen, never while a level is running (ADR-0013 `ERR_BUSY`).
- One confirmation only (P3), but the bin ✔ is **inactive for the first 600 ms** after the dialog opens (`delete_arm_ms`, `ui.json`), so a double tap from the bin chip can never delete. It shows a filling ring while arming (reduced motion: the ring is static and just appears at 600 ms).
- The dialog names exactly what is lost (stars, levels). There is no undo.
- Deleting the active profile → no profile active → List. Deleting the last profile → Create.

## Feedback

| Event | Visual | Audio | Haptic |
|---|---|---|---|
| Switch | Card pops, ✔ badge moves to it | Soft chime | Light |
| Create | New card pops in with a sparkle | Chime | Light |
| Delete | Card puffs into a cloud, slot shows "+" | Soft poof | Double tick |
| Invalid name | Field shake + ✖ | Bonk | Double tick |
| Slots full | "+" absent; ✎ still works | n/a | n/a |

## Edge cases

- **All 4 slots full**: no "+" card; the 5th profile cannot be made (ADR-0013 AC). The player deletes one in Edit mode first.
- **A slot is unreadable** (both progress files corrupt): its card shows the name with a cracked-scroll icon; tapping it opens the fresh-start notice for that profile ([loading-and-save-error.md](loading-and-save-error.md)) and then plays it from fresh.
- **Save is read-only** (newer schema on disk, ADR-0013 §2): create, rename and delete are disabled with a lock icon and the update notice; switching still works.
- **Orientation change** in any state: re-lays out instantly; focus, typed text and chip choices are kept (one tree, ADR-0016 §4).
- **OS keyboard covers the field** (portrait, phone): the sheet scrolls so the field and ✔ stay above the keyboard.
- **Guest players** (local multiplayer, later): not shown here; guests never get a slot (ADR-0013).
- **Switch fails to load** a target profile: stay on List, error toast, the previous profile stays active.

## Acceptance criteria

1. [I] Fresh install: Title → Play opens Create with a pre-filled name; ✔ then the first-run picker (ACC-02) then meadow_01's intro; at most 3 presses from Title to the intro.
2. [I] With a remembered profile, launch → Title → Continue never shows this screen.
3. [I] 4 creates fill slots 0–3; then no "+" is shown and no 5th profile can be made.
4. [I] Rename to a name another slot has (any case) is rejected with the ✖ line; nothing is written.
5. [I] Delete: the bin ✔ ignores presses for 600 ms; ✖ is the default focus; deleting the active profile lands on List with no active profile.
6. [I] Keyboard-only and gamepad-only: create (using 🎲 on pad), switch, rename and delete are all reachable; focus never dead-ends (ADR-0016 focus-walk test, both layouts).
7. [M] P and L on the reference phone: cards ≥ 150 pt, chips ≥ 56 pt, nothing outside the safe area; greyscale screenshot tells 4 profiles apart by badge.
8. [I] Switching profile keeps device-wide audio and display settings and swaps per-profile controls, camera and accessibility settings (ADR-0013).

## Open questions

- **Name for a kid who can't read**: is the pre-filled random name + badge enough, or do we want badge-only profiles with no name? Default: name required (ADR-0013 1–12 characters).
- **Steam floating keyboard** for gamepad-only name typing on PC: in MVP or later?
- **Profile chip on Title / Island map**: placed on the Island map top bar (2026-10-10); title.md still to place it.
