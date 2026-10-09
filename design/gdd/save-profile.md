# Save & Profile

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: (supports all; no player-facing pillar of its own)

## Summary

Progress is saved on the device and synced through the platform's cloud saves (iCloud / Google Play) when the player is signed in. A device holds up to 4 local profiles, so a family can share a tablet; each profile keeps its own progress, settings and name. Because progress only ever goes up, syncing merges by keeping the best of each record, so nothing is lost.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Campaign Structure, Scoring & Stars`

## Overview

Save & Profile stores everything that must survive closing the app: per-profile campaign progress (best stars, time and score per level, with the level version), unlocked pools (twists, mechanics, Specials), Arcade bests, tournament stats, and settings (control scheme, left-hand mirror, sensitivity, reduced motion, scale, audio). Later systems add points, shop purchases and characters. The save is written on meaningful events (a level result, a settings change), atomically, with the previous save kept as a backup. Cloud sync uploads the whole save file to the platform's saved-games service and, on conflict, **merges** rather than picking one side: best stars, fastest times and unlocks are combined, and settings take the newest. Up to 4 local profiles live in one save; the active profile is picked at launch (or remembered). All values are starting defaults; the storage technology is an ADR after `/setup-engine`.

## Detailed Design

### Core Rules

1. **Save file** contains: schema version; up to `max_profiles` (4) profiles; per profile: id, name (≤ 12 characters), player colour and badge preference, settings, per-level records `{best_stars, best_time_s, best_score, level_version}`, unlocked pools, Arcade best per biome skin, tournament stats (played, won), and later points, purchases, characters.
2. **When to save**: after every level or run result, settings change, profile change, and unlock; never during play.
3. **Atomic writes**: write to a temporary file, then replace; keep the previous file as `backup`. On load, a corrupt main file falls back to the backup.
4. **Schema versions**: each release with save changes adds a migration from the previous version; older saves are migrated on load, never discarded.
5. **Cloud sync** (when signed in to the platform): upload after saves (throttled to once per `sync_min_interval_s`, default 60) and on app background; download on launch. On conflict, **merge** (F1).
6. **Profiles**: create, rename, delete (with a confirmation that names what is lost); max 4. Deleting a profile removes it from the cloud copy at the next sync.
7. **Guest play**: a "Guest" in local multiplayer plays without a profile; nothing is saved for them.

### States and Transitions

**Loading → Ready ⇄ Saving**; cloud: **Offline ⇄ Syncing → Synced** (or **Conflict → Merged**).

### Interactions with Other Systems

Campaign Structure and Scoring & Stars (records), Arcade Mode, Tournament Flow (bests, stats), Level Data (level versions), Touch Controls, Camera, Onboarding & Accessibility (settings), Local Multiplayer Setup (profile names), Menus (profile select), Points System, Shop, Characters (later).

## Formulas

### F1. Merge rule

per level, keep the record with more stars; with equal stars, the faster time; `best_score = max(a, b)` independently; unlocks = `a ∪ b`; settings = the side with the newer `settings_changed_at`; profiles matched by id (new ids on either side are added, up to 4; extra ones are kept as hidden archives).

**Example:** device A has meadow_03 ★★ 400 s, device B has ★ 380 s → merged ★★ 400 s (more stars wins); A ★★ 400 s and B ★★ 390 s → ★★ 390 s.

### F2. Save size

`size ≈ profiles × (levels × 24 B + 2 KB)` ≈ 4 × (100 × 24 + 2 048) ≈ 18 KB: well within platform limits.

## Edge Cases

- **If both main and backup are corrupt**: start fresh and tell the player; the cloud copy (if any) is offered.
- **If the cloud is unavailable**: play continues offline; sync retries later.
- **If a 5th profile comes from a merge**: it is kept as an archive and can be restored by deleting another profile.
- **If the app is killed during a save**: the backup is intact (rule 3).
- **If a level version changes**: records keep their old version (Level Data).
- **If the player signs into a different platform account**: the local save is kept; they choose which to keep or merge.

## Dependencies

**Upstream:** Campaign Structure, Scoring & Stars (Hard); Level Data, Arcade Mode, Tournament Flow (Soft).
**Downstream:** Menus & Level Select (Hard), Onboarding & Accessibility, Points System, Shop, Characters & Perks (Hard, later).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| max_profiles | 1–6 | 4 |
| sync_min_interval_s | 15–300 | 60 |
| profile name length | 8–20 | 12 |

## Visual/Audio Requirements

A small cloud icon in menus showing sync state (synced / offline / syncing); no in-play indicator.

## Game Feel

Saving is invisible; a player should never lose progress or wait for a save.

## UI Requirements

Profile select and manage screens, sync status, conflict dialog (only if the platform reports one we can't merge). Covered by Menus & Level Select.

## Cross-References

`design/gdd/scoring-stars.md` (best results), `campaign-structure.md` (progress, unlocks), `level-data-definition.md` (versions), `arcade-mode.md`, `tournament-flow.md`, `local-multiplayer-setup.md` (guests, names).

## Acceptance Criteria

1. [U] **GIVEN** a level result, **THEN** the save is written within 1 s and the previous file is kept as backup.
2. [U] **GIVEN** a corrupt main file, **THEN** the backup loads.
3. [U] F1: the example merges to ★★ 400 s; unlocks are the union.
4. [U] **GIVEN** an old-schema save, **THEN** it migrates without losing records.
5. [I] **GIVEN** 4 profiles, **THEN** each keeps separate progress and settings; a 5th cannot be created.
6. [I] **GIVEN** no network, **THEN** play and saving work and sync resumes later.

## Open Questions

- Storage format and platform APIs → ADR.
- Kids' privacy: profile names stay on device and in the platform cloud only (no server).
