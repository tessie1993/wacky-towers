# Local Multiplayer Setup

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Comeback Energy; Readable Chaos

## Summary

Friends play together in two ways: **each on their own device** (2–4 phones or tablets joined over the same local network), or **two players sharing one tablet** in split screen, facing each other. Each player always keeps their own full board and controls; opponents appear as small boards along the top.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Touch Controls, Camera & Rotate-View`

## Overview

The systems index flagged local multiplayer as a risk: four players on one phone is too cramped (art bible §7). The chosen answer is **both** of two setups. **Device-per-player** (2–4 players): one device hosts, the others join over the local network; every device runs its own board at full phone layout, and the host keeps the shared things in sync — tournament seed, round picks, round start, round results — while attacks (debuffs) travel as messages. **Shared tablet** (2 players): the screen splits into two halves, one per player, each rotated to face its player across a table, each with its own controls; only allowed when each half still passes the board readability check (Board F5). Each player has a player colour (art bible: red, blue, green, purple) plus a shape badge, shown on their island rim and HUD frame. Opponents' boards appear as mini-boards in the top band (HUD reserved slot) so a player can see who's leading and who is in danger. This serves *Comeback Energy* (everyone sees the race and can strike the leader) and *Readable Chaos* (no one's board is shrunk below the readability floor). All values are starting defaults.

## Detailed Design

### Core Rules

**Device-per-player (2–4)**
1. One device **hosts** a lobby; others **join** from a list of nearby hosts on the same local network. The networking technology is an implementation choice → ADR after `/setup-engine` (Bluetooth support depends on the engine; Wi-Fi LAN is the baseline).
2. Each device simulates **its own board only**. Boards are independent, so no lockstep is needed.
3. The **host is authoritative** for: tournament settings and seed, round picks and re-rolls, round start time, round results (who reached the goal first, by host-received time), and pause.
4. Messages between devices: progress updates (goal progress, stack height, score) at `sync_hz` (default 4 per second), events (item used with target, junk sent, player out, goal reached) as they happen.
5. An attack applies on the target device when it arrives (it is never rolled back). Goal-reached messages carry the sender's round clock; the host compares clocks and breaks exact ties by message arrival.
6. **Pause** by any player pauses all devices (host relays); resume needs the pausing player or the host.
7. **Disconnect**: a device silent for `timeout_ms` (default 5 000) is out for the round (Tournament Flow edge case) and may rejoin next round.

**Shared tablet (2)**
8. The screen splits into two halves (left/right on a landscape tablet). Each half is a full layout — board, HUD, controls — rotated 180° for the far player, so players can sit opposite each other.
9. Allowed only when each half passes Board F5 (cube edge ≥ 20 px) for the round's board (F1); phones are allowed only if they pass (usually only small boards), otherwise the option is hidden.
10. Touches are routed by which half they start in; each half's touch zones follow Touch Controls in that half's orientation.

**Both setups**
11. Player identity: colour (red, blue, green, purple) plus a shape badge (circle, square, triangle, star), never colour alone; shown on the island rim and HUD frame (art bible §7).
12. **Opponent mini-boards**: top band, one per opponent, showing their stack silhouette, danger state and goal progress; updated at `sync_hz`.
13. Items' debuff targeting uses standings from progress updates (Items rule 8).

### States and Transitions

**Lobby (host / join) → Ready check → In Tournament (rounds) → Results → Lobby**. Per remote player: **Connected ⇄ Lagging (no message for 1 s) → Disconnected (5 s)**.

### Interactions with Other Systems

Touch Controls (per-player input, split zones), Camera & Rotate-View (each player has their own camera), Tournament Flow and Mode / Minigame Randomizer (host authority), Items and Buffs & Debuffs (attack messages), Level Goals (results, ties), HUD (mini-boards, player frames), Save & Profile (player names), Board / Grid F5 (split readability).

## Formulas

### F1. Split-screen cube size

The split_cube_size formula is defined as:

`cube_px = min( f_h × S_half_h / (n + board_height), f_w × S_half_w / (2 × n) )`, valid when `cube_px ≥ 20`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| S_half_h, S_half_w | int | px | device | Height and width of one half (half of the landscape width) |
| n | int | 4–12 | data file | Larger footprint side |
| board_height | int | 7–20 | calculated (Board F4) | Layers drawn |
| f_h, f_w | float | 0.575 / 0.45 | constant (Board F5, HUD) | Board share of height and width |

**Output Range:** px per cube; below 20 the split option is hidden. **Example:** an 11" tablet 2388 × 1668: each half is 1194 × 1668 (6 × 6 round, board_height 14): height term 0.575 × 1668 / 20 ≈ 48 px; width term 0.45 × 1194 / 12 ≈ 45 px → 45 px, fine. The reference phone 2532 × 1170 halves to 1266 × 1170: height term 0.575 × 1170 / 20 ≈ 34; width term 0.45 × 1266 / 12 ≈ 47 → 34 px, also passes for 6 × 6 rounds (but controls are tight; see Open Questions).

### F2. Sync traffic

`bytes_per_s ≈ sync_hz × players × update_bytes` (≈ 4 × 4 × 64 ≈ 1 KB/s): negligible on a LAN.

## Edge Cases

- **If the host's app is backgrounded**: everyone pauses; after `timeout_ms` the tournament ends with current standings.
- **If two goal-reached messages carry equal clocks**: arrival order at the host decides.
- **If an attack arrives after the target finished the round**: it is dropped.
- **If a split-screen tablet is rotated**: layout locked to landscape for the round.
- **If a device's clock drifts**: round clocks start from the host's start message and count locally; drift over 3 minutes is negligible for tie-breaks.
- **If the same player name joins twice**: the second gets a suffix.

## Dependencies

**Upstream:** Touch Controls, Camera & Rotate-View (Hard), Board / Grid (Hard: F5).
**Downstream:** Tournament Flow, Items (Hard), HUD (Hard: mini-boards), Save & Profile (Soft).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| sync_hz | 2–10 | 4 |
| timeout_ms | 2 000–10 000 | 5 000 |
| split min cube | 20–28 px | 20 |

## Visual/Audio Requirements

Lobby with player cards (colour + badge + mascot costume); mini-boards as simple stack silhouettes in each player's colour; incoming-attack arrows from the attacker's mini-board. Audio: `player_joined`, `player_left`, `attack_incoming`.

## Game Feel

Joining should take under 30 seconds; during play, opponents should feel present (their mini-boards move) without distracting from your own board.

## UI Requirements

Lobby (host/join/ready), mini-boards, player frames, split-screen layout. 📌 **UX Flag — Local Multiplayer Setup**: `/ux-design` for lobby, mini-boards and split layout.

## Cross-References

`design/art/art-bible.md` §4, §7 (player colours, cramped 4-player phone warning), `design/gdd/board-grid.md` F5 (readability), `touch-controls.md` (zones, mirror), `camera-rotate-view.md` (per-player camera), `hud.md` rule 4 (reserved mini-board slot), `tournament-flow.md`, `items.md`, `systems-index.md` (risk).

## Acceptance Criteria

1. [I] **GIVEN** 4 devices on one LAN, **THEN** they join a host lobby and start a tournament in under 30 s.
2. [I] **GIVEN** the same tournament, **THEN** every device plays the same round with the same piece sequence (shared mode).
3. [I] **GIVEN** a Junk Rain sent, **THEN** the target's stack rises on arrival and the attacker's arrow shows on the target's mini-board.
4. [U] **GIVEN** two goal messages with clocks 92.30 s and 92.45 s, **THEN** the first wins.
5. [I] **GIVEN** a device silent for 5 s, **THEN** it is out for the round and can rejoin next round.
6. [U] F1: the tablet example gives 45 px; a board/device pair below 20 px hides the split option.
7. [M] **GIVEN** a 2-player shared-tablet playtest, **THEN** players can play facing each other without accidental touches in the other half.

## Open Questions

- **Networking stack** (Wi-Fi LAN, Bluetooth, platform services) → ADR.
- **Shared phone split**: F1 passes for 6 × 6 rounds, but two sets of thumb controls on one phone may be too tight — test before enabling on phones.
- **Online play**: out of scope (local only) for now.
- **4 players on one tablet**: not supported; revisit with a 4-way layout prototype.
