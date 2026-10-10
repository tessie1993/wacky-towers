# Loading cover, toasts and save notices

> **Status**: Draft (ux-designer, 2026-10-10) · **MVP**: yes.
> **Technical truth**: ADR-0010 §4 (threaded loads, cover after 150 ms, load failure = toast + stay on map, Back ignored while loading), ADR-0013 §2–§3 (backup recovery, fresh start, read-only), ADR-0016 §2 (Toasts layer 50, Cover layer 60, Dialogs layer 40). Look: [ui-theme.md](ui-theme.md). Values are tunable defaults (`assets/data/ui/ui.json`).

Goal: saving and loading are **invisible** when they work, and when they fail the player always knows (a) what happened, (b) whether anything was lost, (c) what to do. No message blames the player. Messages are icon first + one short line (P6 allows words here: these are system notices, not play).

## 1. Loading cover

| Rule | Value |
|---|---|
| Shown | Only if a load takes longer than **150 ms** (ADR-0010) |
| Once shown, stays at least | **400 ms** (`cover_min_ms`), so it never flickers |
| Content | Biome backdrop colour, the cloud wizard stirring a swirl of blocks (loop), no text, no percentage |
| Reduced motion | Static wizard picture + three dots that fill one by one every 500 ms (no movement) |
| Input | All ignored, including Back (ADR-0010); focus is not moved |
| Audio | Current music keeps playing; no loading sound |
| Covers | Level load (tap island → intro), next-level prefetch miss, shader warm-up (ADR-0010) |

- **Load fails** (`THREAD_LOAD_FAILED`, bad level data): cover fades, the Island map stays, error toast "✖ Couldn't open this level" (`UI_TOAST_LEVEL_LOAD_FAILED`). The island stays tappable to retry.
- **Very slow load** (> 10 s): nothing changes in the MVP (ADR-0010 ignores Back during loads). Open question: offer a ◀ after 15 s?

## 2. Toasts

Non-modal, one at a time, queued in order, never take focus (ADR-0016 §2).

| Rule | Value |
|---|---|
| Position | P: bottom centre, above the thumb zones / bottom buttons; L: top centre under the top bar. Inside the safe area; never over the board rect |
| Size | Width ≤ 90% (P) / 50% (L); icon 32 pt + one line Body 14 pt; wraps to 2 lines at 150% text |
| Timing | In 200 ms, stay **4 s** (`toast_ms`, 2–6 s), out 200 ms; tap dismisses early |
| During play | Toasts queue and show only when not Playing (they wait for Pause, Results or menus) |
| Reduced motion | Fades only |
| Screen reader | Announced once via AccessKit live region (ACC-37 later; key only for now) |

## 3. Save notices

| Situation (ADR-0013) | What the player sees | When | Player action |
|---|---|---|---|
| Main file corrupt, **backup loaded** | Toast: scroll+↺ "Restored from backup" | Once, at the next menu | None. The last result may be missing; stars never go down |
| Main and backup corrupt → **fresh start** (`recovered = &"fresh"`) | **Dialog**: cracked scroll, "We couldn't read your saved progress, so you're starting fresh." Single ✔ | At boot, before Profile select / Title primary | ✔ |
| One profile's files corrupt → that profile fresh | Same dialog naming the profile ("Mia's progress couldn't be read…") | When that profile is loaded | ✔ |
| Settings file bad → defaults | Toast: "Settings reset" | Next menu | Open Settings if wanted |
| **Read-only** (save from a newer version) | Dialog once per launch: scroll+▲ "Update the game to keep saving. You can still play." ✔. Plus a small scroll+▲ badge on Title | At boot | ✔; nothing new is saved |
| A write fails (disk full, permission) | Toast: quill+✖ "Couldn't save. We'll try again." | After the failed write | None; retried at the next save point |
| Write fails 3 times in a row | Dialog: "Saving isn't working. Free some space on your device." ✔ | Once per launch | ✔ |
| Quit while a save is running | Nothing if `flush_blocking()` finishes in < 500 ms; else a cover with the quill icon until done | On the quit confirm / window close | Wait |

- **Dialog rules**: one at a time (ADR-0010), ✔ is the default focus (nothing destructive here), Back = ✔. They sit on the Dialogs layer and never stack two in a row; if fresh-start and read-only both apply, only fresh-start shows.
- **No save notice ever appears during play** (saves never run in Playing/Warning, ADR-0013 §3).
- All text keys: `UI_SAVE_*`, `UI_TOAST_*`.

## Edge cases

- **Index file unreadable** (index main + backup corrupt): see conflict below; the UX expectation is that profiles whose slot folders are still readable come back, not that they are deleted.
- **Fresh start on first launch** (no save at all): no dialog; that is a normal first run.
- **Orientation change** while a dialog or toast shows: re-lays out; toast timer keeps running.

## Flagged conflict (for engine-programmer / ADR-0013)

ADR-0013 §6 deletes slot folders the index does not list (orphans) at boot. If the **index itself** is recovered as fresh, every slot looks orphaned and all four profiles would be deleted. Recommendation: skip orphan cleanup when `index.json` was recovered fresh, and rebuild the index from the slot folders (each file carries its `profile_id`).

## Acceptance criteria

1. [I] A level load under 150 ms shows no cover; a 200 ms load shows it for at least 400 ms.
2. [I] Simulated load failure: toast shown, Island map stays, island tappable again.
3. [I] `MemorySaveIO` with both files corrupt: fresh-start dialog at boot, ✔ continues to Profile select / Title.
4. [I] Backup recovery: one toast at the next menu, none during play.
5. [I] Read-only: dialog once per launch, Title badge shown, no write happens.
6. [I] Toasts never take keyboard/gamepad focus and wait while Playing.
7. [M] Reduced motion on: cover shows no moving element; toasts only fade.
