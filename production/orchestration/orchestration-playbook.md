# Orchestration Playbook (producer, 2026-10-10)

Sources: core-loop-orchestration-plan.md (CH-037..073, AF-0..7), chunks/README.md, qa-plan-core-loop §0-2, active.md. Defaults, tunable.

## 1. The loop per wave

1. **Plan (Opus lead, once per wave, <=10 min):** read README status rows only. Pick every chunk whose deps are `done`, no two touching the same file. Write the wave list into active.md (IDs + model + reviewer). Nothing else.
2. **Size:** 4-6 writers per wave, never more than 8. One chunk = one file + its test, <=150 lines of code. Same-file sequential chunks (board_sim 035>064>066>068, board_state 030>031>050>054, movement 051>053) are merged into ONE agent per pair when both tickets are written; they cannot parallelise anyway and each extra agent pays a full re-read.
3. **Models:** Haiku = JSON/data, constants, containers, mechanical extraction. Sonnet = any logic, scenes, input, MCP scene building, integrators. Opus = wave planning, contracts, one review per wave, cross-system decisions. Opus never writes chunk code.
4. **Direct chunk vs staging+integrator:** direct (write to `src/`, own test) when the chunk is pure `core/`/`data/` logic with its own test and touches no scene. Staging (`_staging/` with `.gdignore`, contract file first, writers in parallel, 1 integrator) only when >=3 parts must agree on node names/signals/scene paths: view, HUD, input, level scenes, every GP-n ticket. Staging is never used for logic chunks.
5. **Gate order (cheap first, stop at first fail):**
   a. writer self-gate: its own test red then green, `script_check`/parse on its files;
   b. ONE `--import` after the whole wave finishes writing (never during; kills stale class cache and half-written-file parse errors);
   c. full headless suite, once, by QA, nobody editing (exit 0, count = baseline + new, no `No test cases found`);
   d. Opus single review of the wave diff list (not per chunk) against ticket "Done when";
   e. scene/visual chunks only: godot-ai `editor_state`, `logs_read`, play, screenshot to `production/qa/evidence/`.
   Failure routing: a red outside a writer's files is `blocked`, goes to a single fixer agent, never to the writer.
6. **Lead refresh:** replace the Opus lead with a fresh agent + checkpoint when (a) it has run 2 waves, (b) context > ~60%, or (c) it starts re-reading files it already summarised. Checkpoint = active.md (done list, in flight, open decisions, next wave list) + README table. The file is the memory.
7. **Reader turn budget (20-turn limit):** every spawn prompt contains: "Read at most the ticket + the named files (<=5 reads). Turn 6 at the latest: write the test file. No GDD browsing; if a fact is missing, write `blocked (needs X)`." Give design facts inline in the ticket, not by pointer to a GDD. Pure-read agents (audits, research) get a hard "write findings by turn 12".
8. **Report size:** <=5 lines, fixed template (QA plan §1.1): `CH-NNN | tests n/n | sys exit | full exit | new-red | files`. No code, no prose, no diffs. Detail goes in a file the lead opens only on a fail.
9. **Hygiene:** per-agent `-rd reports/<CH>`; `--import` under `.godot/qa.lock`; the lead, not writers, edits README rows (removes row-edit races); no commits mid-wave.

## 2. Schedule to first playable of the real game

The plan's FP-1..11 groups are re-cut by dependency into 8 waves. Critical path (sequential, single-file): CH-029>030>031>051>053>066>068>071>073, parallel to board_sim 035>064>066>068. Everything else must be finished off this path, not in front of it.

| Wave | Content (all parallel inside) | Gate/integration |
|---|---|---|
| W0 (now) | Finish in-flight: 008, 014, 018, 021, 025, 028, GP-0, first-playable prototype integrator G; QA suite fix; delete stray control.tscn; fix `PackedVector3iArray` in 027 ticket; user decisions G1-G5 | baseline file, known-red list |
| W1 | 022, 027, 030(+031 merged), 037, 038, 039, 040, 041, 042 (off-path items ride along) | import, full suite |
| W2 | 034, 043, 044, 045, 046, 047, 048 | import, suite, Opus review |
| W3 | 035(+skeleton only), 049, 050(+054 merged), 051(+053 merged), 052, 055 | import, suite |
| W4 | 056, 057, 058, 059, 060+061, 062; stage view/HUD pieces | GP-1 Board part (integrator) |
| W5 | 064, 065, 069 | GP-2 Piece part |
| W6 | 066, 068, 070 (board_sim chain tail: single agent each, strictly ordered) | suite |
| W7 | GP-3 drop/lock/clear + headless win test (071), GP-4 camera+input (072) in parallel | scene checks |
| W8 | GP-5 (073): QA plays meadow_01 to win and loss with `input_simulate`, evidence + playtest doc | **FIRST PLAYABLE** |

Estimate: 50 chunks / ~5 per wave = 9-10 waves at 15-25 min each (writers 3-10 min + gates) = roughly one working day of wall clock if gates stay cheap. Pull-forward trick: start chunk N+1 of the board_sim chain the moment N is `done`, do not wait for the wave gate; only the full-suite gate waits.

After first playable (real game): AF-0 meadow_02 data+scene (3-axis rotation playtest, biggest design risk, do immediately) > AF-1 hardening (fuzz, replay, validator, buffer, hold-repeat) > AF-2 mechanics database (074-077, then Haiku data chunks per Meadow mechanic, rule runtime) > AF-3/4 Meadow 02-10 one level per wave of 2-3 levels (data-only for most) > AF-5 UI/menus > AF-6 presentation (shaders, VFX) > AF-7 Android export. Run AF-5 and AF-6 in parallel once AF-3 is stable. Re-plan at each AF boundary.

## 3. Top 5 risks

| # | Risk | Mitigation |
|---|---|---|
| 1 | Sequential board_sim/board_state chain is the critical path; one slow or red chunk stalls everything | Merge same-file pairs into one agent; start on `done`, not wave end; fixer agent on standby; Opus reviews tickets of this chain before launch so no rework |
| 2 | Parse errors / stale class cache / half-written files invalidate gates | Single import per wave under lock, staging with `.gdignore`, suite run only when no writers active, gate of record = headless, MCP is pre-check only |
| 3 | Plan drift (README stale, `PackedVector3iArray`, JsonNum copies, project.godot autoloads GUIDE/PhantomCamera) corrupts tickets | Lead reconciles README against disk at every wave start; patch tickets before spawn; user decides G1 (remove autoloads) now |
| 4 | Agent turn exhaustion and context bloat (readers, bloated reports, lead drift) | Read caps and "write by turn 6" in every prompt, design facts inlined into tickets, 5-line template, lead refresh every 2 waves |
| 5 | Integration surprises at GP tickets (node names, signals, scene paths) and first-playable proves only spin-only meadow_01 | Contract file before staging writers; integrator owns all fixes; screenshot evidence mandatory; AF-0 meadow_02 3-axis playtest immediately after W8 |
