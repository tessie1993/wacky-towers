# Bot Playtest — 2026-10-13

**Story type**: Integration (completability) | **Gate**: ADVISORY (review input, not a verdict)

**Tool**: `tools/qa/bot_playtest.gd` (per-biome, run in parallel) + `tools/qa/bot_playtest_report.py`. Engine 4.7.2-stable (official). Seeds [1729, 4242, 90001]. Wall runtime 900s.

> **Caveat.** WtBotPlayer is a deterministic tournament practice opponent: it waits 45 ticks to think and 6 ticks per input, uses only Y-spin, X/Z moves and hard drop, and does not reliably clear layers on 8x8 boards. Read these results as **completability signals only, not difficulty**. 'Never finished' means *review*, not proof of impossibility. A WIN is real (the sim granted it).

## Method
- 3 attempts per level (seeds above); the bot calls `update(sim)` and then `sim.step()`, with no rendering.
- Cap: 2 × the 3-star time (t3), at most 10 simulated minutes; `survive` and score-star levels use 10 min. Each attempt also has a 20 s wall-clock budget (`SLOW_SIM`).
- Kit (SELECTING) levels: the harness picks a seeded random shape, because the bot cannot pick.
- Assessed = goal in {clear_n, height, survive} and control verb `piece`. Other levels run anyway: a win counts, any other result is **NOT ASSESSED**.
- Loss reason: `time_limit` / `out_of_pieces` / `top_out_or_goal_fail`, reconstructed from sim state (the sim's `_finish` reason lives only in its event).

## Totals (142 levels)

| WON | LOST | TIMEOUT | NOT ASSESSED | LOAD FAIL |
|---|---|---|---|---|
| 13 | 27 | 2 | 100 | 0 |

Attempts: {'won': 23, 'lost': 111, 'timeout': 5, 'budget': 287}

## Per biome

| Biome | Levels | Won | Lost | Timeout | Not assessed | Flagged |
|---|---|---|---|---|---|---|
| meadow | 13 | 1 | 5 | 0 | 7 | 13 |
| candy | 14 | 4 | 2 | 0 | 8 | 12 |
| ice | 12 | 1 | 1 | 0 | 10 | 12 |
| underwater | 13 | 0 | 1 | 0 | 12 | 13 |
| lava | 14 | 0 | 2 | 1 | 11 | 14 |
| forest | 14 | 0 | 4 | 1 | 9 | 14 |
| cave | 9 | 0 | 2 | 0 | 7 | 9 |
| clockwork | 14 | 2 | 4 | 0 | 8 | 13 |
| neon | 14 | 3 | 3 | 0 | 8 | 13 |
| celestial | 12 | 1 | 0 | 0 | 11 | 12 |
| carnival | 13 | 1 | 3 | 0 | 9 | 12 |

## Flag list (review queue, highest weight first)

| Level | Status | Flags |
|---|---|---|
| ice_10 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost); **INSTANT_LOSS** lost with <=2 locks |
| lava_h3 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost); **SAME_INSTANT_LOSS** all 3 losses: top_out_or_goal_fail at locks [7] / [9]s |
| meadow_01 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| meadow_02 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| meadow_04 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| meadow_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [6] / [9]s |
| candy_01 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| candy_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: top_out_or_goal_fail at locks [6] / [8]s |
| ice_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [6] / [9, 10]s |
| underwater_06 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [9] / [13, 14]s |
| underwater_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: top_out_or_goal_fail at locks [7] / [10]s |
| lava_01 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| lava_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: top_out_or_goal_fail at locks [7] / [10]s |
| forest_01 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| forest_02 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| forest_03 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| forest_04 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| forest_06 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [6] / [9]s |
| forest_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [9] / [13, 14]s |
| cave_01 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| cave_02 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| cave_07 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [3] / [4]s |
| clockwork_01 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| clockwork_06 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [7] / [10]s |
| clockwork_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [7] / [10, 11]s |
| neon_02 | LOST | **NEVER_FINISHED** bot-capable level, 0/3 wins (lost) |
| neon_06 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [8] / [11]s |
| neon_h3 | WON | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 20646 ms); **TOO_EASY** won in 50.4s = 13% of 3-star time 375s |
| celestial_06 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [6] / [8]s |
| celestial_bonus | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [5] / [7, 8]s |
| carnival_06 | NOT_ASSESSED | **SAME_INSTANT_LOSS** all 3 losses: out_of_pieces at locks [8] / [11, 12]s |
| candy_09 | WON | **TOO_EASY** won in 26.6s = 6% of 3-star time 400s |
| meadow_03 | LOST | **SLOW_SIM** wall_budget: sim too slow (15600 ticks in 20581 ms) |
| meadow_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 22660 ms) |
| meadow_06 | WON | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20525 ms) |
| meadow_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 132065 ms) |
| meadow_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21243 ms) |
| meadow_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 22065 ms) |
| meadow_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4800 ticks in 21475 ms) |
| meadow_h1 | LOST | **SLOW_SIM** wall_budget: sim too slow (3600 ticks in 20401 ms) |
| meadow_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 21044 ms) |
| candy_02 | LOST | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20012 ms) |
| candy_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 22711 ms) |
| candy_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (8400 ticks in 21993 ms) |
| candy_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (12600 ticks in 20374 ms) |
| candy_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (1200 ticks in 20670 ms) |
| candy_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (15600 ticks in 20404 ms) |
| candy_h1 | WON | **SLOW_SIM** wall_budget: sim too slow (4800 ticks in 21078 ms) |
| candy_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (3000 ticks in 24480 ms) |
| candy_h3 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 21519 ms) |
| ice_01 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 20168 ms) |
| ice_02 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 21815 ms) |
| ice_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 20606 ms) |
| ice_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4800 ticks in 21096 ms) |
| ice_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 21161 ms) |
| ice_06 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4800 ticks in 23138 ms) |
| ice_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 46636 ms) |
| ice_08 | WON | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21137 ms) |
| ice_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20155 ms) |
| ice_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 21106 ms) |
| underwater_01 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (10200 ticks in 20193 ms) |
| underwater_02 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 22073 ms) |
| underwater_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 21453 ms) |
| underwater_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 20243 ms) |
| underwater_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7800 ticks in 21701 ms) |
| underwater_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 92820 ms) |
| underwater_08 | LOST | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20744 ms) |
| underwater_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20916 ms) |
| underwater_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 21064 ms) |
| underwater_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20661 ms) |
| underwater_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 20438 ms) |
| lava_02 | TIMEOUT | **SLOW_SIM** wall_budget: sim too slow (21000 ticks in 20521 ms) |
| lava_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (11400 ticks in 20258 ms) |
| lava_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21225 ms) |
| lava_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 21008 ms) |
| lava_06 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (10200 ticks in 20919 ms) |
| lava_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 91397 ms) |
| lava_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21280 ms) |
| lava_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 21861 ms) |
| lava_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 23236 ms) |
| lava_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 20177 ms) |
| lava_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 20150 ms) |
| forest_05 | TIMEOUT | **SLOW_SIM** wall_budget: sim too slow (10800 ticks in 21412 ms) |
| forest_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 20331 ms) |
| forest_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7800 ticks in 20383 ms) |
| forest_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 20676 ms) |
| forest_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 20459 ms) |
| forest_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 46517 ms) |
| forest_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (8400 ticks in 22075 ms) |
| forest_h3 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 20180 ms) |
| cave_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (13200 ticks in 20149 ms) |
| cave_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21237 ms) |
| cave_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20458 ms) |
| cave_06 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 21096 ms) |
| cave_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 105566 ms) |
| cave_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 100111 ms) |
| clockwork_03 | LOST | **SLOW_SIM** wall_budget: sim too slow (8400 ticks in 20250 ms) |
| clockwork_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (8400 ticks in 20504 ms) |
| clockwork_05 | WON | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20004 ms) |
| clockwork_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7800 ticks in 21487 ms) |
| clockwork_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7800 ticks in 21441 ms) |
| clockwork_09 | LOST | **SLOW_SIM** wall_budget: sim too slow (3600 ticks in 20455 ms) |
| clockwork_10 | LOST | **SLOW_SIM** wall_budget: sim too slow (13200 ticks in 20304 ms) |
| clockwork_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20240 ms) |
| clockwork_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20084 ms) |
| clockwork_h3 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20036 ms) |
| neon_03 | LOST | **SLOW_SIM** wall_budget: sim too slow (7800 ticks in 21083 ms) |
| neon_04 | LOST | **SLOW_SIM** wall_budget: sim too slow (9000 ticks in 20382 ms) |
| neon_05 | WON | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 20366 ms) |
| neon_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (10800 ticks in 20045 ms) |
| neon_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 20515 ms) |
| neon_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (3000 ticks in 20921 ms) |
| neon_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (11400 ticks in 21917 ms) |
| neon_bonus | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 20303 ms) |
| neon_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21474 ms) |
| neon_h2 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 21916 ms) |
| celestial_01 | WON | **SLOW_SIM** wall_budget: sim too slow (11400 ticks in 20305 ms) |
| celestial_02 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (5400 ticks in 20683 ms) |
| celestial_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 22074 ms) |
| celestial_04 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 21195 ms) |
| celestial_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (8400 ticks in 20698 ms) |
| celestial_07 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 97964 ms) |
| celestial_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21796 ms) |
| celestial_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 22385 ms) |
| celestial_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 21188 ms) |
| celestial_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20682 ms) |
| carnival_01 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (9600 ticks in 20967 ms) |
| carnival_02 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4200 ticks in 22747 ms) |
| carnival_03 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (7200 ticks in 20867 ms) |
| carnival_05 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (8400 ticks in 21526 ms) |
| carnival_07 | LOST | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 20811 ms) |
| carnival_08 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (600 ticks in 81804 ms) |
| carnival_09 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4800 ticks in 20215 ms) |
| carnival_10 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (4800 ticks in 20511 ms) |
| carnival_bonus | LOST | **SLOW_SIM** wall_budget: sim too slow (6600 ticks in 20126 ms) |
| carnival_h1 | NOT_ASSESSED | **SLOW_SIM** wall_budget: sim too slow (6000 ticks in 21388 ms) |
| carnival_h2 | LOST | **SLOW_SIM** wall_budget: sim too slow (10800 ticks in 21772 ms) |

## Per level

| Level | Goal | Verb | t3 s | Status | Attempts (outcome@s/locks/stars, reason) | Note |
|---|---|---|---|---|---|---|
| meadow_01 (log) | ? | ? | - | LOST | lost@220s/L144/?★ (top_out_or_goal_fail); lost@231s/L151/?★ (top_out_or_goal_fail); lost@233s/L152/?★ (top_out_or_goal_fail) |  |
| meadow_02 (log) | ? | ? | - | LOST | lost@204s/L128/?★ (top_out_or_goal_fail); lost@159s/L103/?★ (top_out_or_goal_fail); lost@182s/L114/?★ (top_out_or_goal_fail) |  |
| meadow_03 (log) | ? | ? | - | LOST | lost@218s/L138/?★ (top_out_or_goal_fail); budget@255s/L157/?★ (wall_budget: sim too slow (15600 ticks in 20581 ms)); budget@157s/L99/?★ (wall_budget: sim too slow (9600 ticks in 20610 ms)) |  |
| meadow_04 (log) | ? | ? | - | LOST | lost@94s/L21/?★ (top_out_or_goal_fail); lost@83s/L23/?★ (top_out_or_goal_fail); lost@120s/L30/?★ (top_out_or_goal_fail) |  |
| meadow_05 (log) | ? | ? | - | NOT_ASSESSED | budget@147s/L93/?★ (wall_budget: sim too slow (9000 ticks in 22660 ms)); budget@157s/L101/?★ (wall_budget: sim too slow (9600 ticks in 20100 ms)); budget@187s/L119/?★ (wall_budget: sim too slow (11400 ticks in 20879 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| meadow_06 (log) | ? | ? | - | WON | won@52s/L34/?★; budget@97s/L61/?★ (wall_budget: sim too slow (6000 ticks in 20525 ms)); budget@117s/L74/?★ (wall_budget: sim too slow (7200 ticks in 21212 ms)) |  |
| meadow_07 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 132065 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 44797 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 48223 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| meadow_08 (log) | ? | ? | - | NOT_ASSESSED | budget@107s/L67/?★ (wall_budget: sim too slow (6600 ticks in 21243 ms)); budget@117s/L74/?★ (wall_budget: sim too slow (7200 ticks in 20574 ms)); budget@87s/L53/?★ (wall_budget: sim too slow (5400 ticks in 20047 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| meadow_09 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L42/?★ (wall_budget: sim too slow (4200 ticks in 22065 ms)); budget@57s/L35/?★ (wall_budget: sim too slow (3600 ticks in 20209 ms)); budget@67s/L41/?★ (wall_budget: sim too slow (4200 ticks in 22615 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| meadow_10 (log) | ? | ? | - | NOT_ASSESSED | budget@77s/L47/?★ (wall_budget: sim too slow (4800 ticks in 21475 ms)); budget@67s/L41/?★ (wall_budget: sim too slow (4200 ticks in 20119 ms)); budget@87s/L53/?★ (wall_budget: sim too slow (5400 ticks in 20686 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| meadow_bonus (log) | ? | ? | - | NOT_ASSESSED | lost@9s/L6/?★ (out_of_pieces); lost@9s/L6/?★ (out_of_pieces); lost@9s/L6/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| meadow_h1 (log) | ? | ? | - | LOST | budget@55s/L34/?★ (wall_budget: sim too slow (3600 ticks in 20401 ms)); budget@55s/L35/?★ (wall_budget: sim too slow (3600 ticks in 20022 ms)); lost@62s/L39/?★ (top_out_or_goal_fail) |  |
| meadow_h2 (log) | ? | ? | - | NOT_ASSESSED | budget@147s/L93/?★ (wall_budget: sim too slow (9000 ticks in 21044 ms)); budget@137s/L87/?★ (wall_budget: sim too slow (8400 ticks in 20113 ms)); budget@127s/L80/?★ (wall_budget: sim too slow (7800 ticks in 20303 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| candy_01 | clear_n | piece | 210 | LOST | lost@222s/L144/0★ (top_out_or_goal_fail); lost@232s/L151/0★ (top_out_or_goal_fail); lost@234s/L152/0★ (top_out_or_goal_fail) |  |
| candy_02 | clear_n | piece | 155 | LOST | lost@187s/L119/0★ (top_out_or_goal_fail); lost@223s/L140/0★ (top_out_or_goal_fail); budget@147s/L93/0★ (wall_budget: sim too slow (9000 ticks in 20012 ms)) |  |
| candy_03 | clear_n | piece | 350 | NOT_ASSESSED | budget@87s/L54/0★ (wall_budget: sim too slow (5400 ticks in 22711 ms)); budget@77s/L47/0★ (wall_budget: sim too slow (4800 ticks in 20316 ms)); budget@97s/L60/0★ (wall_budget: sim too slow (6000 ticks in 22404 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| candy_04 | clear_n | piece | 295 | NOT_ASSESSED | budget@137s/L86/0★ (wall_budget: sim too slow (8400 ticks in 21993 ms)); budget@155s/L101/0★ (wall_budget: sim too slow (9600 ticks in 20564 ms)); budget@107s/L67/0★ (wall_budget: sim too slow (6600 ticks in 20134 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| candy_05 | height | piece | - | NOT_ASSESSED | budget@207s/L56/0★ (wall_budget: sim too slow (12600 ticks in 20374 ms)); budget@187s/L43/0★ (wall_budget: sim too slow (11400 ticks in 20247 ms)); budget@157s/L30/0★ (wall_budget: sim too slow (9600 ticks in 20452 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| candy_06 | shape | piece | 115 | WON | won@24s/L16/3★; won@27s/L18/3★; won@24s/L16/3★ | goal type 'shape' is not targeted by WtBotPlayer |
| candy_07 | clear_n | piece | 350 | WON | won@70s/L11/2★; won@132s/L19/2★; won@83s/L14/2★ |  |
| candy_08 | survive | piece | - | NOT_ASSESSED | budget@17s/L9/0★ (wall_budget: sim too slow (1200 ticks in 20670 ms)); budget@17s/L9/0★ (wall_budget: sim too slow (1200 ticks in 20422 ms)); budget@37s/L20/0★ (wall_budget: sim too slow (2400 ticks in 23076 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| candy_09 | clear_n | piece | 400 | WON | won@26s/L15/3★; won@27s/L16/3★; won@27s/L16/3★ |  |
| candy_10 | bake_oven | piece | 240 | NOT_ASSESSED | lost@277s/L141/0★ (top_out_or_goal_fail); budget@257s/L112/0★ (wall_budget: sim too slow (15600 ticks in 20404 ms)); budget@287s/L88/0★ (wall_budget: sim too slow (17400 ticks in 22918 ms)) | goal type 'bake_oven' is not targeted by WtBotPlayer |
| candy_bonus | shape | piece | 30 | NOT_ASSESSED | lost@8s/L6/0★ (top_out_or_goal_fail); lost@8s/L6/0★ (top_out_or_goal_fail); lost@8s/L6/0★ (top_out_or_goal_fail) | goal type 'shape' is not targeted by WtBotPlayer |
| candy_h1 | clear_n | piece | 350 | WON | budget@77s/L64/0★ (wall_budget: sim too slow (4800 ticks in 21078 ms)); won@75s/L63/3★; won@80s/L68/3★ |  |
| candy_h2 | rescue_all | piece | 245 | NOT_ASSESSED | budget@47s/L29/0★ (wall_budget: sim too slow (3000 ticks in 24480 ms)); budget@57s/L35/0★ (wall_budget: sim too slow (3600 ticks in 21288 ms)); budget@47s/L28/0★ (wall_budget: sim too slow (3000 ticks in 20486 ms)) | goal type 'rescue_all' is not targeted by WtBotPlayer |
| candy_h3 | bonk_boss | piece | 200 | NOT_ASSESSED | budget@147s/L49/0★ (wall_budget: sim too slow (9000 ticks in 21519 ms)); lost@52s/L18/0★ (top_out_or_goal_fail); budget@137s/L34/0★ (wall_budget: sim too slow (8400 ticks in 22103 ms)) | goal type 'bonk_boss' is not targeted by WtBotPlayer |
| ice_01 (log) | ? | ? | - | NOT_ASSESSED | budget@157s/L97/?★ (wall_budget: sim too slow (9600 ticks in 20168 ms)); budget@157s/L97/?★ (wall_budget: sim too slow (9600 ticks in 20382 ms)); budget@127s/L78/?★ (wall_budget: sim too slow (7800 ticks in 20767 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| ice_02 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L42/?★ (wall_budget: sim too slow (4200 ticks in 21815 ms)); budget@47s/L29/?★ (wall_budget: sim too slow (3000 ticks in 21173 ms)); budget@47s/L28/?★ (wall_budget: sim too slow (3000 ticks in 20389 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| ice_03 (log) | ? | ? | - | NOT_ASSESSED | budget@157s/L96/?★ (wall_budget: sim too slow (9600 ticks in 20606 ms)); budget@175s/L112/?★ (wall_budget: sim too slow (10800 ticks in 21279 ms)); lost@245s/L157/?★ (top_out_or_goal_fail) | recovered from killed-run log (no goal/stars detail) |
| ice_04 (log) | ? | ? | - | NOT_ASSESSED | budget@77s/L48/?★ (wall_budget: sim too slow (4800 ticks in 21096 ms)); budget@77s/L48/?★ (wall_budget: sim too slow (4800 ticks in 20269 ms)); budget@77s/L47/?★ (wall_budget: sim too slow (4800 ticks in 23348 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| ice_05 (log) | ? | ? | - | NOT_ASSESSED | budget@117s/L73/?★ (wall_budget: sim too slow (7200 ticks in 21161 ms)); budget@107s/L69/?★ (wall_budget: sim too slow (6600 ticks in 20625 ms)); budget@97s/L61/?★ (wall_budget: sim too slow (6000 ticks in 20597 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| ice_06 (log) | ? | ? | - | NOT_ASSESSED | budget@77s/L48/?★ (wall_budget: sim too slow (4800 ticks in 23138 ms)); budget@57s/L37/?★ (wall_budget: sim too slow (3600 ticks in 21578 ms)); budget@57s/L36/?★ (wall_budget: sim too slow (3600 ticks in 20355 ms)) | recovered from killed-run log (no goal/stars detail) |
| ice_07 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 46636 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 58110 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 104371 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| ice_08 (log) | ? | ? | - | WON | won@140s/L90/?★; budget@107s/L69/?★ (wall_budget: sim too slow (6600 ticks in 21137 ms)); won@140s/L89/?★ |  |
| ice_09 (log) | ? | ? | - | NOT_ASSESSED | budget@145s/L91/?★ (wall_budget: sim too slow (9000 ticks in 20155 ms)); budget@135s/L87/?★ (wall_budget: sim too slow (8400 ticks in 20285 ms)); budget@135s/L86/?★ (wall_budget: sim too slow (8400 ticks in 21121 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| ice_10 (log) | ? | ? | - | LOST | lost@51s/L7/?★ (top_out_or_goal_fail); lost@45s/L6/?★ (top_out_or_goal_fail); lost@20s/L2/?★ (top_out_or_goal_fail) |  |
| ice_bonus (log) | ? | ? | - | NOT_ASSESSED | lost@9s/L6/?★ (out_of_pieces); lost@10s/L6/?★ (out_of_pieces); lost@10s/L6/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| ice_h1 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L43/?★ (wall_budget: sim too slow (4200 ticks in 21106 ms)); budget@105s/L47/?★ (wall_budget: sim too slow (6600 ticks in 20524 ms)); budget@107s/L50/?★ (wall_budget: sim too slow (6600 ticks in 20305 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_01 (log) | ? | ? | - | NOT_ASSESSED | budget@165s/L103/?★ (wall_budget: sim too slow (10200 ticks in 20193 ms)); budget@185s/L115/?★ (wall_budget: sim too slow (11400 ticks in 20847 ms)); budget@127s/L78/?★ (wall_budget: sim too slow (7800 ticks in 21674 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_02 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L42/?★ (wall_budget: sim too slow (4200 ticks in 22073 ms)); budget@37s/L24/?★ (wall_budget: sim too slow (2400 ticks in 22418 ms)); budget@47s/L28/?★ (wall_budget: sim too slow (3000 ticks in 20147 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_03 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L41/?★ (wall_budget: sim too slow (4200 ticks in 21453 ms)); budget@107s/L67/?★ (wall_budget: sim too slow (6600 ticks in 21698 ms)); budget@77s/L47/?★ (wall_budget: sim too slow (4800 ticks in 20710 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_04 (log) | ? | ? | - | NOT_ASSESSED | budget@117s/L73/?★ (wall_budget: sim too slow (7200 ticks in 20243 ms)); budget@137s/L86/?★ (wall_budget: sim too slow (8400 ticks in 21281 ms)); budget@137s/L86/?★ (wall_budget: sim too slow (8400 ticks in 21202 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_05 (log) | ? | ? | - | NOT_ASSESSED | budget@127s/L80/?★ (wall_budget: sim too slow (7800 ticks in 21701 ms)); budget@107s/L69/?★ (wall_budget: sim too slow (6600 ticks in 20345 ms)); budget@97s/L61/?★ (wall_budget: sim too slow (6000 ticks in 20283 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_06 (log) | ? | ? | - | NOT_ASSESSED | lost@13s/L9/?★ (out_of_pieces); lost@14s/L9/?★ (out_of_pieces); lost@14s/L9/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| underwater_07 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L0/?★ (wall_budget: sim too slow (600 ticks in 92820 ms)); budget@7s/L0/?★ (wall_budget: sim too slow (600 ticks in 39764 ms)); budget@7s/L0/?★ (wall_budget: sim too slow (600 ticks in 102870 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_08 (log) | ? | ? | - | LOST | budget@95s/L61/?★ (wall_budget: sim too slow (6000 ticks in 20744 ms)); lost@95s/L61/?★ (top_out_or_goal_fail); lost@93s/L60/?★ (top_out_or_goal_fail) |  |
| underwater_09 (log) | ? | ? | - | NOT_ASSESSED | budget@97s/L61/?★ (wall_budget: sim too slow (6000 ticks in 20916 ms)); budget@147s/L93/?★ (wall_budget: sim too slow (9000 ticks in 21822 ms)); budget@107s/L68/?★ (wall_budget: sim too slow (6600 ticks in 21475 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_10 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L41/?★ (wall_budget: sim too slow (4200 ticks in 21064 ms)); budget@87s/L54/?★ (wall_budget: sim too slow (5400 ticks in 21094 ms)); budget@127s/L78/?★ (wall_budget: sim too slow (7800 ticks in 20472 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_bonus (log) | ? | ? | - | NOT_ASSESSED | lost@10s/L7/?★ (top_out_or_goal_fail); lost@10s/L7/?★ (top_out_or_goal_fail); lost@10s/L7/?★ (top_out_or_goal_fail) | recovered from killed-run log (no goal/stars detail) |
| underwater_h1 (log) | ? | ? | - | NOT_ASSESSED | budget@147s/L91/?★ (wall_budget: sim too slow (9000 ticks in 20661 ms)); budget@185s/L119/?★ (wall_budget: sim too slow (11400 ticks in 21156 ms)); budget@147s/L91/?★ (wall_budget: sim too slow (9000 ticks in 20324 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| underwater_h2 (log) | ? | ? | - | NOT_ASSESSED | budget@87s/L54/?★ (wall_budget: sim too slow (5400 ticks in 20438 ms)); budget@97s/L61/?★ (wall_budget: sim too slow (6000 ticks in 20827 ms)); budget@117s/L72/?★ (wall_budget: sim too slow (7200 ticks in 20514 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_01 | clear_n | piece | 205 | LOST | lost@181s/L119/0★ (top_out_or_goal_fail); lost@186s/L119/0★ (top_out_or_goal_fail); lost@172s/L114/0★ (top_out_or_goal_fail) |  |
| lava_02 | clear_n | piece | 180 | TIMEOUT | timeout@360s/L230/0★; timeout@360s/L224/0★; budget@347s/L225/0★ (wall_budget: sim too slow (21000 ticks in 20521 ms)) | some attempts cut by wall-clock budget |
| lava_03 | clear_n | piece | 205 | NOT_ASSESSED | budget@187s/L119/0★ (wall_budget: sim too slow (11400 ticks in 20258 ms)); budget@117s/L74/0★ (wall_budget: sim too slow (7200 ticks in 21642 ms)); budget@127s/L81/0★ (wall_budget: sim too slow (7800 ticks in 20809 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_04 | clear_n | piece | 410 | NOT_ASSESSED | budget@107s/L68/0★ (wall_budget: sim too slow (6600 ticks in 21225 ms)); budget@175s/L113/0★ (wall_budget: sim too slow (10800 ticks in 21701 ms)); budget@127s/L79/0★ (wall_budget: sim too slow (7800 ticks in 21599 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_05 | height | piece | 170 | NOT_ASSESSED | budget@117s/L74/0★ (wall_budget: sim too slow (7200 ticks in 21008 ms)); budget@137s/L88/0★ (wall_budget: sim too slow (8400 ticks in 20112 ms)); budget@147s/L95/0★ (wall_budget: sim too slow (9000 ticks in 20945 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_06 | shape | piece | 115 | NOT_ASSESSED | budget@167s/L109/0★ (wall_budget: sim too slow (10200 ticks in 20919 ms)); budget@117s/L74/0★ (wall_budget: sim too slow (7200 ticks in 21030 ms)); budget@147s/L92/0★ (wall_budget: sim too slow (9000 ticks in 20016 ms)) | goal type 'shape' is not targeted by WtBotPlayer |
| lava_07 | clear_n | piece | 310 | NOT_ASSESSED | budget@7s/L4/0★ (wall_budget: sim too slow (600 ticks in 91397 ms)); budget@7s/L4/0★ (wall_budget: sim too slow (600 ticks in 38858 ms)); budget@7s/L4/0★ (wall_budget: sim too slow (600 ticks in 88749 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_08 | survive | piece | - | NOT_ASSESSED | budget@107s/L68/0★ (wall_budget: sim too slow (6600 ticks in 21280 ms)); budget@107s/L67/0★ (wall_budget: sim too slow (6600 ticks in 21350 ms)); budget@137s/L86/0★ (wall_budget: sim too slow (8400 ticks in 20038 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_09 | clear_n | piece | 305 | NOT_ASSESSED | budget@97s/L58/0★ (wall_budget: sim too slow (6000 ticks in 21861 ms)); budget@87s/L52/0★ (wall_budget: sim too slow (5400 ticks in 21246 ms)); budget@97s/L59/0★ (wall_budget: sim too slow (6000 ticks in 21028 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_10 | clear_n | piece | 305 | NOT_ASSESSED | budget@87s/L53/0★ (wall_budget: sim too slow (5400 ticks in 23236 ms)); budget@77s/L47/0★ (wall_budget: sim too slow (4800 ticks in 21766 ms)); budget@97s/L60/0★ (wall_budget: sim too slow (6000 ticks in 20508 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_bonus | shape | piece | 60 | NOT_ASSESSED | lost@10s/L7/0★ (top_out_or_goal_fail); lost@10s/L7/0★ (top_out_or_goal_fail); lost@10s/L7/0★ (top_out_or_goal_fail) | goal type 'shape' is not targeted by WtBotPlayer |
| lava_h1 | clear_n | piece | 305 | NOT_ASSESSED | budget@117s/L73/0★ (wall_budget: sim too slow (7200 ticks in 20177 ms)); budget@117s/L74/0★ (wall_budget: sim too slow (7200 ticks in 20178 ms)); budget@157s/L100/0★ (wall_budget: sim too slow (9600 ticks in 21208 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_h2 | clear_n | piece | 365 | NOT_ASSESSED | budget@155s/L101/0★ (wall_budget: sim too slow (9600 ticks in 20150 ms)); budget@97s/L61/0★ (wall_budget: sim too slow (6000 ticks in 21032 ms)); budget@165s/L104/0★ (wall_budget: sim too slow (10200 ticks in 20879 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| lava_h3 | clear_n | piece | 170 | LOST | lost@9s/L7/0★ (top_out_or_goal_fail); lost@9s/L7/0★ (top_out_or_goal_fail); lost@9s/L7/0★ (top_out_or_goal_fail) |  |
| forest_01 | clear_n | piece | 170 | LOST | lost@149s/L29/0★ (top_out_or_goal_fail); lost@142s/L30/0★ (top_out_or_goal_fail); lost@131s/L26/0★ (top_out_or_goal_fail) |  |
| forest_02 | clear_n | piece | 205 | LOST | lost@98s/L65/0★ (top_out_or_goal_fail); lost@115s/L75/0★ (top_out_or_goal_fail); lost@94s/L61/0★ (top_out_or_goal_fail) |  |
| forest_03 | clear_n | piece | 305 | LOST | lost@199s/L127/0★ (top_out_or_goal_fail); lost@197s/L125/0★ (top_out_or_goal_fail); lost@276s/L177/0★ (top_out_or_goal_fail) |  |
| forest_04 | clear_n | piece | 210 | LOST | lost@61s/L13/0★ (top_out_or_goal_fail); lost@58s/L13/0★ (top_out_or_goal_fail); lost@53s/L12/0★ (top_out_or_goal_fail) |  |
| forest_05 | height | piece | 115 | TIMEOUT | timeout@230s/L157/0★; budget@177s/L113/0★ (wall_budget: sim too slow (10800 ticks in 21412 ms)); budget@137s/L86/0★ (wall_budget: sim too slow (8400 ticks in 20996 ms)) | some attempts cut by wall-clock budget |
| forest_06 | shape | piece | 50 | NOT_ASSESSED | lost@9s/L6/0★ (out_of_pieces); lost@9s/L6/0★ (out_of_pieces); lost@9s/L6/0★ (out_of_pieces) | goal type 'shape' is not targeted by WtBotPlayer |
| forest_07 | clear_n | piece | 410 | NOT_ASSESSED | budget@67s/L41/0★ (wall_budget: sim too slow (4200 ticks in 20331 ms)); budget@67s/L41/0★ (wall_budget: sim too slow (4200 ticks in 20862 ms)); budget@97s/L60/0★ (wall_budget: sim too slow (6000 ticks in 21570 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| forest_08 | clear_n | piece | 210 | NOT_ASSESSED | budget@127s/L79/0★ (wall_budget: sim too slow (7800 ticks in 20383 ms)); budget@137s/L87/0★ (wall_budget: sim too slow (8400 ticks in 20183 ms)); budget@117s/L73/0★ (wall_budget: sim too slow (7200 ticks in 20344 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| forest_09 | clear_n | piece | 410 | NOT_ASSESSED | budget@87s/L54/0★ (wall_budget: sim too slow (5400 ticks in 20676 ms)); budget@57s/L34/0★ (wall_budget: sim too slow (3600 ticks in 20949 ms)); budget@67s/L41/0★ (wall_budget: sim too slow (4200 ticks in 21717 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| forest_10 | clear_n | piece | 305 | NOT_ASSESSED | budget@67s/L41/0★ (wall_budget: sim too slow (4200 ticks in 20459 ms)); budget@67s/L41/0★ (wall_budget: sim too slow (4200 ticks in 20795 ms)); budget@57s/L34/0★ (wall_budget: sim too slow (3600 ticks in 21866 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| forest_bonus | shape | piece | 90 | NOT_ASSESSED | lost@14s/L9/0★ (out_of_pieces); lost@13s/L9/0★ (out_of_pieces); lost@13s/L9/0★ (out_of_pieces) | goal type 'shape' is not targeted by WtBotPlayer |
| forest_h1 | clear_n | piece | 375 | NOT_ASSESSED | budget@7s/L4/0★ (wall_budget: sim too slow (600 ticks in 46517 ms)); budget@7s/L4/0★ (wall_budget: sim too slow (600 ticks in 59356 ms)); budget@7s/L4/0★ (wall_budget: sim too slow (600 ticks in 106019 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| forest_h2 | clear_n | piece | 285 | NOT_ASSESSED | budget@137s/L89/0★ (wall_budget: sim too slow (8400 ticks in 22075 ms)); budget@107s/L71/0★ (wall_budget: sim too slow (6600 ticks in 22675 ms)); budget@157s/L102/0★ (wall_budget: sim too slow (9600 ticks in 22451 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| forest_h3 | clear_n | piece | 375 | NOT_ASSESSED | budget@87s/L55/0★ (wall_budget: sim too slow (5400 ticks in 20180 ms)); budget@67s/L42/0★ (wall_budget: sim too slow (4200 ticks in 20563 ms)); budget@77s/L48/0★ (wall_budget: sim too slow (4800 ticks in 21236 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| cave_01 (log) | ? | ? | - | LOST | lost@271s/L171/?★ (top_out_or_goal_fail); lost@282s/L178/?★ (top_out_or_goal_fail); lost@294s/L186/?★ (top_out_or_goal_fail) |  |
| cave_02 (log) | ? | ? | - | LOST | lost@252s/L157/?★ (top_out_or_goal_fail); lost@234s/L148/?★ (top_out_or_goal_fail); lost@242s/L155/?★ (top_out_or_goal_fail) |  |
| cave_03 (log) | ? | ? | - | NOT_ASSESSED | budget@215s/L127/?★ (wall_budget: sim too slow (13200 ticks in 20149 ms)); budget@147s/L91/?★ (wall_budget: sim too slow (9000 ticks in 20478 ms)); budget@97s/L60/?★ (wall_budget: sim too slow (6000 ticks in 20159 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| cave_04 (log) | ? | ? | - | NOT_ASSESSED | budget@107s/L67/?★ (wall_budget: sim too slow (6600 ticks in 21237 ms)); budget@127s/L79/?★ (wall_budget: sim too slow (7800 ticks in 20882 ms)); budget@167s/L103/?★ (wall_budget: sim too slow (10200 ticks in 20358 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| cave_05 (log) | ? | ? | - | NOT_ASSESSED | budget@147s/L91/?★ (wall_budget: sim too slow (9000 ticks in 20458 ms)); budget@137s/L85/?★ (wall_budget: sim too slow (8400 ticks in 20305 ms)); budget@157s/L96/?★ (wall_budget: sim too slow (9600 ticks in 20723 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| cave_06 (log) | ? | ? | - | NOT_ASSESSED | budget@155s/L100/?★ (wall_budget: sim too slow (9600 ticks in 21096 ms)); budget@135s/L89/?★ (wall_budget: sim too slow (8400 ticks in 20626 ms)); budget@107s/L68/?★ (wall_budget: sim too slow (6600 ticks in 20450 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| cave_07 (log) | ? | ? | - | NOT_ASSESSED | lost@4s/L3/?★ (out_of_pieces); lost@4s/L3/?★ (out_of_pieces); lost@4s/L3/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| cave_08 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 105566 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 38769 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 73906 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| cave_09 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 100111 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 102879 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 74502 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| clockwork_01 | clear_n | piece | 170 | LOST | lost@57s/L15/0★ (top_out_or_goal_fail); lost@51s/L16/0★ (top_out_or_goal_fail); lost@56s/L16/0★ (top_out_or_goal_fail) |  |
| clockwork_02 | clear_n | piece | 130 | WON | timeout@260s/L156/0★; timeout@260s/L159/0★; won@44s/L27/3★ |  |
| clockwork_03 | clear_n | piece | 310 | LOST | lost@253s/L147/0★ (top_out_or_goal_fail); lost@201s/L128/0★ (top_out_or_goal_fail); budget@137s/L85/0★ (wall_budget: sim too slow (8400 ticks in 20250 ms)) |  |
| clockwork_04 | clear_n | piece | 310 | NOT_ASSESSED | budget@137s/L87/0★ (wall_budget: sim too slow (8400 ticks in 20504 ms)); budget@137s/L87/0★ (wall_budget: sim too slow (8400 ticks in 20910 ms)); budget@137s/L86/0★ (wall_budget: sim too slow (8400 ticks in 20885 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| clockwork_05 | height | piece | 115 | WON | won@193s/L123/1★; budget@147s/L94/0★ (wall_budget: sim too slow (9000 ticks in 20004 ms)); budget@167s/L106/0★ (wall_budget: sim too slow (10200 ticks in 21202 ms)) |  |
| clockwork_06 | shape | piece | 55 | NOT_ASSESSED | lost@10s/L7/0★ (out_of_pieces); lost@10s/L7/0★ (out_of_pieces); lost@10s/L7/0★ (out_of_pieces) | goal type 'shape' is not targeted by WtBotPlayer |
| clockwork_07 | clear_n | piece | 410 | NOT_ASSESSED | budget@127s/L77/0★ (wall_budget: sim too slow (7800 ticks in 21487 ms)); budget@137s/L82/0★ (wall_budget: sim too slow (8400 ticks in 21511 ms)); budget@87s/L52/0★ (wall_budget: sim too slow (5400 ticks in 21857 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| clockwork_08 | wind_keys | piece | 140 | NOT_ASSESSED | budget@127s/L80/0★ (wall_budget: sim too slow (7800 ticks in 21441 ms)); budget@137s/L88/0★ (wall_budget: sim too slow (8400 ticks in 20906 ms)); budget@117s/L73/0★ (wall_budget: sim too slow (7200 ticks in 21940 ms)) | goal type 'wind_keys' is not targeted by WtBotPlayer |
| clockwork_09 | clear_n | piece | 410 | LOST | budget@57s/L35/0★ (wall_budget: sim too slow (3600 ticks in 20455 ms)); budget@107s/L68/0★ (wall_budget: sim too slow (6600 ticks in 20990 ms)); lost@205s/L130/0★ (top_out_or_goal_fail) |  |
| clockwork_10 | clear_n | piece | 305 | LOST | lost@223s/L137/0★ (top_out_or_goal_fail); budget@215s/L131/0★ (wall_budget: sim too slow (13200 ticks in 20304 ms)); budget@185s/L114/0★ (wall_budget: sim too slow (11400 ticks in 23597 ms)) |  |
| clockwork_bonus | shape | piece | 75 | NOT_ASSESSED | lost@10s/L7/0★ (out_of_pieces); lost@11s/L7/0★ (out_of_pieces); lost@10s/L7/0★ (out_of_pieces) | goal type 'shape' is not targeted by WtBotPlayer |
| clockwork_h1 | clear_n | piece | 375 | NOT_ASSESSED | budget@97s/L58/0★ (wall_budget: sim too slow (6000 ticks in 20240 ms)); budget@97s/L57/0★ (wall_budget: sim too slow (6000 ticks in 21517 ms)); budget@97s/L60/0★ (wall_budget: sim too slow (6000 ticks in 20410 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| clockwork_h2 | clear_n | piece | 375 | NOT_ASSESSED | budget@97s/L60/0★ (wall_budget: sim too slow (6000 ticks in 20084 ms)); budget@97s/L61/0★ (wall_budget: sim too slow (6000 ticks in 21394 ms)); budget@127s/L80/0★ (wall_budget: sim too slow (7800 ticks in 20045 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| clockwork_h3 | wind_keys | piece | 170 | NOT_ASSESSED | budget@147s/L92/0★ (wall_budget: sim too slow (9000 ticks in 20036 ms)); budget@117s/L73/0★ (wall_budget: sim too slow (7200 ticks in 20596 ms)); budget@167s/L105/0★ (wall_budget: sim too slow (10200 ticks in 20890 ms)) | goal type 'wind_keys' is not targeted by WtBotPlayer |
| neon_01 | clear_n | piece | 140 | WON | lost@195s/L123/0★ (top_out_or_goal_fail); lost@212s/L136/0★ (top_out_or_goal_fail); won@37s/L23/3★ |  |
| neon_02 | clear_n | piece | 235 | LOST | lost@206s/L128/0★ (top_out_or_goal_fail); lost@248s/L149/0★ (top_out_or_goal_fail); lost@238s/L148/0★ (top_out_or_goal_fail) |  |
| neon_03 | clear_n | piece | 330 | LOST | lost@207s/L131/0★ (top_out_or_goal_fail); budget@127s/L79/0★ (wall_budget: sim too slow (7800 ticks in 21083 ms)); budget@87s/L54/0★ (wall_budget: sim too slow (5400 ticks in 22270 ms)) |  |
| neon_04 | clear_n | piece | 425 | LOST | budget@145s/L95/0★ (wall_budget: sim too slow (9000 ticks in 20382 ms)); budget@155s/L102/0★ (wall_budget: sim too slow (9600 ticks in 21513 ms)); lost@146s/L96/0★ (top_out_or_goal_fail) |  |
| neon_05 | height | piece | 185 | WON | won@198s/L126/2★; budget@157s/L100/0★ (wall_budget: sim too slow (9600 ticks in 20366 ms)); budget@137s/L86/0★ (wall_budget: sim too slow (8400 ticks in 20948 ms)) |  |
| neon_06 | shape | piece | 55 | NOT_ASSESSED | lost@11s/L8/0★ (out_of_pieces); lost@11s/L8/0★ (out_of_pieces); lost@11s/L8/0★ (out_of_pieces) | goal type 'shape' is not targeted by WtBotPlayer |
| neon_07 | clear_n | piece | 365 | NOT_ASSESSED | budget@176s/L113/0★ (wall_budget: sim too slow (10800 ticks in 20045 ms)); budget@157s/L100/0★ (wall_budget: sim too slow (9600 ticks in 20310 ms)); budget@127s/L79/0★ (wall_budget: sim too slow (7800 ticks in 20217 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_08 | survive | piece | - | NOT_ASSESSED | budget@67s/L40/0★ (wall_budget: sim too slow (4200 ticks in 20515 ms)); budget@87s/L53/0★ (wall_budget: sim too slow (5400 ticks in 21414 ms)); budget@57s/L34/0★ (wall_budget: sim too slow (3600 ticks in 20821 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_09 | clear_n | piece | 410 | NOT_ASSESSED | budget@47s/L29/0★ (wall_budget: sim too slow (3000 ticks in 20921 ms)); budget@67s/L42/0★ (wall_budget: sim too slow (4200 ticks in 20760 ms)); budget@147s/L92/0★ (wall_budget: sim too slow (9000 ticks in 20260 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_10 | clear_n | piece | 455 | NOT_ASSESSED | budget@187s/L111/0★ (wall_budget: sim too slow (11400 ticks in 21917 ms)); budget@137s/L83/0★ (wall_budget: sim too slow (8400 ticks in 21430 ms)); budget@97s/L57/0★ (wall_budget: sim too slow (6000 ticks in 22452 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_bonus | clear_n | piece | 240 | NOT_ASSESSED | budget@107s/L65/0★ (wall_budget: sim too slow (6600 ticks in 20303 ms)); budget@127s/L75/0★ (wall_budget: sim too slow (7800 ticks in 21548 ms)); budget@127s/L78/0★ (wall_budget: sim too slow (7800 ticks in 21156 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_h1 | clear_n | piece | 375 | NOT_ASSESSED | budget@107s/L64/0★ (wall_budget: sim too slow (6600 ticks in 21474 ms)); budget@127s/L77/0★ (wall_budget: sim too slow (7800 ticks in 21236 ms)); budget@147s/L89/0★ (wall_budget: sim too slow (9000 ticks in 22338 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_h2 | clear_n | piece | 375 | NOT_ASSESSED | budget@87s/L55/0★ (wall_budget: sim too slow (5400 ticks in 21916 ms)); budget@87s/L55/0★ (wall_budget: sim too slow (5400 ticks in 21273 ms)); budget@117s/L74/0★ (wall_budget: sim too slow (7200 ticks in 20790 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| neon_h3 | clear_n | piece | 375 | WON | won@50s/L33/3★; budget@155s/L102/0★ (wall_budget: sim too slow (9600 ticks in 20646 ms)); budget@126s/L83/0★ (wall_budget: sim too slow (7800 ticks in 20251 ms)) |  |
| celestial_01 (log) | ? | ? | - | WON | won@69s/L44/?★; budget@185s/L117/?★ (wall_budget: sim too slow (11400 ticks in 20305 ms)); budget@175s/L112/?★ (wall_budget: sim too slow (10800 ticks in 21650 ms)) |  |
| celestial_02 (log) | ? | ? | - | NOT_ASSESSED | budget@87s/L55/?★ (wall_budget: sim too slow (5400 ticks in 20683 ms)); budget@57s/L37/?★ (wall_budget: sim too slow (3600 ticks in 22617 ms)); budget@47s/L28/?★ (wall_budget: sim too slow (3000 ticks in 23186 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_03 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L41/?★ (wall_budget: sim too slow (4200 ticks in 22074 ms)); budget@87s/L55/?★ (wall_budget: sim too slow (5400 ticks in 21658 ms)); budget@117s/L72/?★ (wall_budget: sim too slow (7200 ticks in 21481 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_04 (log) | ? | ? | - | NOT_ASSESSED | budget@117s/L73/?★ (wall_budget: sim too slow (7200 ticks in 21195 ms)); budget@137s/L87/?★ (wall_budget: sim too slow (8400 ticks in 20250 ms)); budget@117s/L72/?★ (wall_budget: sim too slow (7200 ticks in 20403 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_05 (log) | ? | ? | - | NOT_ASSESSED | budget@137s/L87/?★ (wall_budget: sim too slow (8400 ticks in 20698 ms)); budget@87s/L56/?★ (wall_budget: sim too slow (5400 ticks in 21485 ms)); budget@77s/L49/?★ (wall_budget: sim too slow (4800 ticks in 20168 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_06 (log) | ? | ? | - | NOT_ASSESSED | lost@8s/L6/?★ (out_of_pieces); lost@8s/L6/?★ (out_of_pieces); lost@8s/L6/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| celestial_07 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 97964 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 37505 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 94111 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_08 (log) | ? | ? | - | NOT_ASSESSED | budget@105s/L67/?★ (wall_budget: sim too slow (6600 ticks in 21796 ms)); budget@87s/L55/?★ (wall_budget: sim too slow (5400 ticks in 20129 ms)); budget@107s/L67/?★ (wall_budget: sim too slow (6600 ticks in 20723 ms)) | recovered from killed-run log (no goal/stars detail) |
| celestial_09 (log) | ? | ? | - | NOT_ASSESSED | budget@117s/L73/?★ (wall_budget: sim too slow (7200 ticks in 22385 ms)); budget@167s/L106/?★ (wall_budget: sim too slow (10200 ticks in 20331 ms)); budget@127s/L81/?★ (wall_budget: sim too slow (7800 ticks in 23151 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_10 (log) | ? | ? | - | NOT_ASSESSED | budget@107s/L65/?★ (wall_budget: sim too slow (6600 ticks in 21188 ms)); budget@97s/L60/?★ (wall_budget: sim too slow (6000 ticks in 20955 ms)); budget@127s/L79/?★ (wall_budget: sim too slow (7800 ticks in 20596 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| celestial_bonus (log) | ? | ? | - | NOT_ASSESSED | lost@7s/L5/?★ (out_of_pieces); lost@7s/L5/?★ (out_of_pieces); lost@8s/L5/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| celestial_h1 (log) | ? | ? | - | NOT_ASSESSED | budget@97s/L60/?★ (wall_budget: sim too slow (6000 ticks in 20682 ms)); budget@117s/L74/?★ (wall_budget: sim too slow (7200 ticks in 20299 ms)); budget@127s/L82/?★ (wall_budget: sim too slow (7800 ticks in 21756 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_01 (log) | ? | ? | - | NOT_ASSESSED | budget@157s/L97/?★ (wall_budget: sim too slow (9600 ticks in 20967 ms)); budget@157s/L97/?★ (wall_budget: sim too slow (9600 ticks in 21502 ms)); budget@117s/L72/?★ (wall_budget: sim too slow (7200 ticks in 21232 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_02 (log) | ? | ? | - | NOT_ASSESSED | budget@67s/L42/?★ (wall_budget: sim too slow (4200 ticks in 22747 ms)); budget@37s/L23/?★ (wall_budget: sim too slow (2400 ticks in 21250 ms)); budget@47s/L29/?★ (wall_budget: sim too slow (3000 ticks in 25781 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_03 (log) | ? | ? | - | NOT_ASSESSED | budget@117s/L73/?★ (wall_budget: sim too slow (7200 ticks in 20867 ms)); budget@177s/L110/?★ (wall_budget: sim too slow (10800 ticks in 20217 ms)); budget@167s/L105/?★ (wall_budget: sim too slow (10200 ticks in 21548 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_04 (log) | ? | ? | - | WON | won@14s/L8/?★; won@13s/L8/?★; won@15s/L9/?★ |  |
| carnival_05 (log) | ? | ? | - | NOT_ASSESSED | budget@137s/L86/?★ (wall_budget: sim too slow (8400 ticks in 21526 ms)); budget@117s/L75/?★ (wall_budget: sim too slow (7200 ticks in 20403 ms)); budget@127s/L80/?★ (wall_budget: sim too slow (7800 ticks in 21454 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_06 (log) | ? | ? | - | NOT_ASSESSED | lost@11s/L8/?★ (out_of_pieces); lost@11s/L8/?★ (out_of_pieces); lost@12s/L8/?★ (out_of_pieces) | recovered from killed-run log (no goal/stars detail) |
| carnival_07 (log) | ? | ? | - | LOST | budget@95s/L65/?★ (wall_budget: sim too slow (6000 ticks in 20811 ms)); lost@88s/L62/?★ (top_out_or_goal_fail); budget@107s/L74/?★ (wall_budget: sim too slow (6600 ticks in 20009 ms)) |  |
| carnival_08 (log) | ? | ? | - | NOT_ASSESSED | budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 81804 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 40676 ms)); budget@7s/L4/?★ (wall_budget: sim too slow (600 ticks in 103582 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_09 (log) | ? | ? | - | NOT_ASSESSED | budget@77s/L48/?★ (wall_budget: sim too slow (4800 ticks in 20215 ms)); budget@77s/L49/?★ (wall_budget: sim too slow (4800 ticks in 20203 ms)); budget@107s/L67/?★ (wall_budget: sim too slow (6600 ticks in 22019 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_10 (log) | ? | ? | - | NOT_ASSESSED | budget@77s/L44/?★ (wall_budget: sim too slow (4800 ticks in 20511 ms)); budget@117s/L44/?★ (wall_budget: sim too slow (7200 ticks in 20617 ms)); budget@87s/L55/?★ (wall_budget: sim too slow (5400 ticks in 21435 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_bonus (log) | ? | ? | - | LOST | lost@99s/L41/?★ (top_out_or_goal_fail); budget@105s/L46/?★ (wall_budget: sim too slow (6600 ticks in 20126 ms)); lost@92s/L40/?★ (top_out_or_goal_fail) |  |
| carnival_h1 (log) | ? | ? | - | NOT_ASSESSED | budget@97s/L58/?★ (wall_budget: sim too slow (6000 ticks in 21388 ms)); budget@127s/L80/?★ (wall_budget: sim too slow (7800 ticks in 21139 ms)); budget@117s/L74/?★ (wall_budget: sim too slow (7200 ticks in 21094 ms)) | every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal |
| carnival_h2 (log) | ? | ? | - | LOST | budget@175s/L121/?★ (wall_budget: sim too slow (10800 ticks in 21772 ms)); budget@165s/L113/?★ (wall_budget: sim too slow (10200 ticks in 20064 ms)); lost@168s/L113/?★ (top_out_or_goal_fail) |  |
