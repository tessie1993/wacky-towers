# QA Monitoring Plan: Core Loop (chunk fleet, CH-006 … CH-036 → APP-001 meadow_01)

**Date**: 2026-10-10 · **Owner**: qa-lead · **Branch**: `feat/core-board-grid`
**Engine**: Godot 4.7.2, GDScript, gdUnit4 6.2.1 · **Rigor**: standard · **qa.level / testing.strict**: unset → default gates (Logic/Integration/Visual/UI BLOCKING, Config ADVISORY; `/smoke-check` config BLOCKING)
**Inputs**: `tests/README.md`, `.claude/docs/coding-standards.md` (Testing), `.claude/rules/test-standards.md`, `.claude/docs/run-and-observe.md`, `production/chunks/README.md`, CH-025 / CH-029 / CH-035, `production/qa/editor-check.md`, `tests/unit/**`, `project.yaml` `commands.*`.

This is a plan. Nothing here has been run yet.

---

## 0. Before the first chunk: baseline

The fleet's "suite still green" check is only meaningful against a known baseline. Run once, before group B / E / I agents start:

1. Import + full suite (commands in §1.2). Record the exit code, the test count and every failing test in `production/qa/baseline-2026-10-10.md`.
2. Open items from `editor-check.md` (04:13):
   - `shape_def.gd` `PackedVector3iArray` parse error: the type no longer appears in either file, so it looks fixed. The baseline run confirms it, or not.
   - `block_set_import_test.gd:58` `neon_voxel: no blk_neon_voxel_cube*.glb`: an asset test, not a chunk test. If it is still red, file it as a BUG (owner technical-artist) and list it in the baseline as a **known red**. Chunk agents treat a known red as "not yours": the rule is *no new red*, not *all green*.
3. If the baseline has anything red that is not on the known-red list, the fleet does not start.

---

## 1. Per-chunk gate (the chunk agent shows this before flipping its row to `done`)

### 1.1 Evidence the agent pastes into its hand-off (5 lines, no prose)

```
Ticket: CH-NNN  Story: XXX-NNN  Type: Logic|Integration|Visual|UI|Config
Tests: tests/unit/<system>/<file>_test.gd  (N listed in ticket / N present)
System run: -a res://tests/unit/<system>  exit=<code>  "<Overall Summary line>"
Full run:   -a res://tests                exit=<code>  "<Overall Summary line>"  new-red: none
Parse: no "Parse Error"/"SCRIPT ERROR"/"Failed to load" lines for my files   Evidence: <png paths or n/a>
```

### 1.2 Commands (Git Bash; run from the repo root)

```bash
cd "/c/Users/tessi/Claude/repos/wacky towers"
G="/d/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe"
RUN() { "$G" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
        res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -rd "$RD" "$@"; }
RD="reports/CH-NNN"                      # per-agent report dir: parallel agents must not share one

# a) refresh the class cache (only if the ticket adds a class_name; see §1.4 lock)
"$G" --headless --path . --import > "$RD.import.log" 2>&1; echo "import exit=$?"

# b) parse check of the new files: any hit = not done
grep -nE "Parse Error|SCRIPT ERROR|Failed to load script|Could not find type|Identifier .* not declared" "$RD.import.log" \
  | grep -E "<your files, e.g. board_state|board_fixtures>"

# c) red first (tests written, no code yet): expect exit 100 or 105, and record it
RUN -a res://tests/unit/<system> 2>&1 | tee "$RD.red.log"; echo "red exit=${PIPESTATUS[0]}"

# d) green: the system folder
RUN -a res://tests/unit/<system> 2>&1 | tee "$RD.sys.log"; echo "sys exit=${PIPESTATUS[0]}"

# e) the whole suite (replaces the README's "also run rng once")
RUN -a res://tests 2>&1 | tee "$RD.all.log"; echo "all exit=${PIPESTATUS[0]}"
grep -E "Overall Summary|FAILED|Parse Error|SCRIPT ERROR" "$RD.all.log"
```

`--remote-debug tcp://127.0.0.1:0` is required: gdUnit4 hangs without it. **`production/chunks/README.md` "Run" omits it**: agents copy the line above, not the README one (see CONCERNS). The two `ERROR:` lines about port `127.0.0.1:0` are expected noise.

### 1.3 Exit codes (from `GdUnitTestSessionRunner.gd`)

| Exit | Meaning | Chunk may flip to `done`? |
|---|---|---|
| 0 | all passed | yes, **if** the summary's test count includes the ticket's N new tests |
| 0 + `No test cases found` | nothing ran | **no**: wrong path or the suite did not load |
| 100 | at least one failure/error | no (expected at step c only) |
| 101 | passed, orphan nodes leaked | no for a new leak in the agent's files; see §2.3 |
| 103 | headless not supported (missing `--ignoreHeadlessMode`) | no; fix the command |
| 104 | Godot version not supported by gdUnit4 | no; stop, escalate to QA |
| 105 | a test script does not parse | no; the file never ran, so its tests are absent from the count |

Also check the **count**: a suite that fails to load is silently left out of the total (this is how `shape_def_test` disappeared from the 04:13 run). Summary count must equal baseline count + the ticket's new tests.

### 1.4 Parallel-run hygiene

- `--import` writes the shared `.godot/` cache. Two agents importing at once can corrupt `global_script_class_cache.cfg`. One import at a time: `mkdir .godot/qa.lock` before importing, `rmdir` after; if `mkdir` fails, wait and retry.
- `-rd reports/CH-NNN` keeps report folders apart. `reports/` should be gitignored (check before the first commit).
- An agent must not "fix" another ticket's red test. A red outside its own files → row to `blocked (red: <test>)` and stop.

### 1.5 Godot-AI equivalent (when the editor is open and the MCP is connected)

| Step | godot-ai | godot-mcp-toolkit |
|---|---|---|
| parse check | `script_manage` (open/validate the file) then `logs_read`: no parse error for the file | `script_check` on each new `.gd`: zero errors |
| system tests | `test_run` with path `res://tests/unit/<system>` | n/a (use headless) |
| full suite | `test_run` with path `res://tests` | n/a |
| editor errors | `editor_state` + `logs_read`: no new errors since the last check | `editor_get_console` |

The editor sees a new `class_name` only after a filesystem rescan. If `test_run` reports an unknown class right after an agent wrote it, rescan (or run the headless `--import`) before calling it red. The headless run is the **gate of record**; the MCP run is a fast pre-check.

### 1.6 Per-type gate on top of the above

| Ticket type | Extra evidence | Examples |
|---|---|---|
| Logic (all of `src/core/**`, `src/data/**`) | none beyond §1.2; plus the ticket's grep bans (e.g. CH-035: no `Node`, `Time`, `OS`, `await`) | CH-006…036 except CH-025 |
| Visual/UI (`src/view/**`, `.tscn`, HUD, input layouts) | retained screenshots per §4, Read and compared to the ticket | CH-025 (3 shots) |
| Integration | `tests/integration/<system>/` test or a playtest doc | APP-001, MDW-* smoke |

Doc-comment check (README Done-when 3), cheap grep the reviewer also runs:
`grep -nB1 -E "^(static )?func [a-z]" <file> | grep -vE "##|^--$|func _"` → every public `func` preceded by a `##` line.

---

## 2. Per-group gate (after every agent in a parallel group has flipped `done`)

Groups: batch 1 B → C → D; batch 2 F → G → H; batch 3 I → J → K → L. Groups from different batches may run alongside each other, so the group gate always runs the **whole** suite.

### 2.1 Run (QA, once per group, nobody else editing)

```bash
"$G" --headless --path . --import > reports/group-X.import.log 2>&1; echo "import exit=$?"
grep -nE "Parse Error|SCRIPT ERROR|Failed to load|Could not find type" reports/group-X.import.log
RD=reports/group-X; RUN -a res://tests 2>&1 | tee reports/group-X.all.log; echo "exit=${PIPESTATUS[0]}"
"$G" --headless --path . --quit-after 5 2>&1 | grep -E "ERROR|SCRIPT ERROR"   # commands.smoke: boots without errors
```

Then the live checks in §3 (`editor_state`, `logs_read`, `script_check` on every file the group touched).

### 2.2 Pass rule

- Import: no parse/load errors anywhere under `src/` or `tests/` (addon noise such as `addons/guide/editor/class_scanner.gd:18 signal already connected` is ignored; keep that list in the baseline file).
- Suite: exit 0, or 101 handled per §2.3; count = previous group count + this group's new tests; no new red vs the baseline known-red list.
- Ticket rows in `production/chunks/README.md` all `done`, none silently `in-progress`.
- Files touched only within each ticket's Files list (`git status --porcelain` vs the tickets). An unlisted file edit = review FAIL for that chunk.
- Reviewer verdicts (§5) PASS for every chunk in the group.

Result recorded as one line appended to `production/qa/group-log.md` (one file for the whole fleet): `group X | date | exit | count | new red | verdict`.

### 2.3 Exit 101 (orphan/leak warning)

1. Read the `-Orphan nodes report-` block; it names the test.
2. Test in a core (`RefCounted`) ticket → almost always a test that built a `Node` without `auto_free()`. Fix in the test.
3. Test in a view/app ticket → either a missing `auto_free`/`queue_free` in the test, or the code leaves children (a Tween or `CSGBox3D` never freed). Owner decides which.
4. 101 is **not** accepted as green for new code. The group stays open until 0. A leak that predates the group goes on the known list with a BUG.

### 2.4 Who fixes a red group

| Red cause | Fixer |
|---|---|
| A chunk's own test or file | the same ticket type re-spawned (fresh Sonnet coder) with the failing output and the ticket; row → `in-progress (fix)` |
| Two chunks that each pass alone, fail together (integration) | the later ticket in dependency order; if it is a contract mismatch between tickets, lead-programmer / godot-specialist decides which side is wrong |
| Shared file conflict (two tickets edited one file) | orchestrator: the group plan was wrong; revert to the earlier ticket's version, re-run the later ticket |
| Test itself is wrong (expected value disagrees with ADR/GDD) | not the coder: file a BUG, route to the ticket author / designer to settle the number, then fix |
| Asset/import red | technical-artist |

The next group does not start until this group is green, except groups with no dependency on the red ticket (check the Depends column).

---

## 3. Live Godot monitoring

Cadence: a **light pass** after each chunk lands (≤ 2 min), a **full pass** at each group gate.

| When | Tool call | Must show | Headless fallback |
|---|---|---|---|
| Every chunk | godot-ai `editor_state` | editor connected, no play session stuck running, project not mid-import | n/a |
| Every chunk | godot-ai `logs_read` (since last check) | no new `Parse Error` / `SCRIPT ERROR` / `Failed to load` naming `src/` or `tests/` | `--import` log grep (§1.2 b) |
| Every chunk | toolkit `script_check` on each new/edited `.gd` | 0 errors, 0 warnings for the agent's files (README Done-when 2) | same grep |
| Every chunk | godot-ai `test_run` path `res://tests/unit/<system>` | same pass count as the agent reported | §1.2 d |
| Group gate | godot-ai `test_run` path `res://tests` | count and failures match the headless run; a difference means stale editor cache, not a pass | §2.1 |
| Group gate | toolkit `editor_get_console` | no errors from addon autoloads (`_mcp_game_helper`, `MCPRuntimeServer`) or project load | `commands.smoke` (`--quit-after 5`) output |
| Scene tickets (CH-025, VEW-*, INP-001, APP-001) | godot-ai `scene_get_hierarchy` on the ticket's `.tscn` | node names/types exactly as the ticket (CH-025: root `CameraRig` → child `Camera3D` named `Camera`, orthographic, current) | `grep -E "^\[node" <file>.tscn` |
| Scene tickets | godot-ai `project_run` (scene) then `logs_read`, or toolkit `game_start` then `debugger_get_log` | runs ≥ 60 frames with no runtime errors; then `game_stop` | `"$G" --path . --windowed --resolution 1280x720 --quit-after 120 <scene> 2>&1 \| grep ERROR` (windowed: needs a display) |
| Runtime state | toolkit `runtime_get_script_vars` on the node | e.g. CameraRig `_k` / `get_yaw_index` after a `rotate_view`; later BoardSim tick/phase | a gdUnit scene test asserting the same |

Rule: an MCP tool result that disagrees with the headless run is investigated, never averaged. The headless gdUnit exit code is the gate of record for tests; the windowed screenshot is the gate of record for looks.

---

## 4. Player-visible chunks: screenshot evidence

### 4.1 Naming

- **Ticket names a path → use it exactly** (CH-025: `production/qa/evidence/VEW-004-yaw-k0.png`, `-k3.png`, `-k4.png`; APP-001: `production/qa/evidence/meadow_01_*.png`).
- **Ticket names none** → `run-and-observe.md` form: `production/qa/evidence/<STORY-ID>/<NN>-<what-it-shows>.png` (e.g. `VEW-001/01-board-4x4-empty.png`).
- One evidence note per story beside the shots: `production/qa/evidence/<STORY-ID>.md` listing each PNG, the scene, the resolution, the build (commit hash) and one line of what it shows / whether it meets the AC.

### 4.2 Capture

- Preferred: godot-ai `project_run` the scene, then `editor_screenshot source=game` (or toolkit `runtime_screenshot`), saved to the path above. The 04:13 check could not save a screenshot ("tool has no save path"): if the MCP still returns the image only, use the fallback.
- Fallback (zero scaffold, run-and-observe):
  `"$G" --path . --windowed --resolution 1280x720 --write-movie production/qa/evidence/tmp/k0.png --quit-after 60 res://src/dev/camera_rig_preview.tscn`
  then keep the last frame (`k000000059.png`), rename to the ticket path, delete the rest of `tmp/`. Never `--headless`.
- States a scene launch cannot reach (k=3, k=4): drive with `input_simulate` (action `wt_rotate_view_*` once INP-001 exists) or a preview-scene export var for the start yaw (in the ticket's own dev scene only).
- Then **Read the PNG** and compare to the ticket. A shot nobody looked at is not evidence.

### 4.3 What each shot must show

| Shot | Must show |
|---|---|
| `VEW-004-yaw-k0/k3/k4.png` | whole 6×14×6 box inside the frame with visible margin on all sides; red marker box at the +x end, moving to the expected side between k0, k3 and k4; orthographic (parallel edges, no perspective taper); lit (DirectionalLight visible shading) |
| VEW-001 board view | 4×4 board at H8 for meadow_01, active cells visible, empty cells not drawn as blocks, starter cubes in the content-type hue |
| INP-001 controls | both portrait and landscape layouts; no control overlapping the board area; only the axes the level enables (meadow_01: spin only) |
| HUD | goal text "Clear 4" progress, next-piece list, clock; no clipped text at 1280×720 |
| `meadow_01_*.png` (APP-001) | `01-boot` level loaded; `02-piece-falling`; `03-piece-locked`; `04-layer-cleared` (count 1/4); `05-win` result panel. Each with no error overlay |

### 4.4 Meadow 01 playtest smoke (first playable, APP-001)

meadow_01 per `design/levels/meadow.md`: 4×4, H8, drizzle, spin only, goal Clear 4, first 2 pieces from {O, I}.
Preconditions: `run/main_scene` = `main.tscn` boots straight into meadow_01; INP-001 `InputMap` actions exist in `project.godot` (`wt_move_*`, `wt_spin_*`, `wt_soft_drop`, `wt_hard_drop`, `wt_rotate_view_*`). Neither exists yet, so this smoke cannot run before APP-001.

Script (toolkit `game_start`, then `input_simulate` with action events; godot-ai `game_manage`/input equivalents):

| # | Input (action, press+release) | Check (`runtime_screenshot` + `runtime_get_script_vars` on BoardSim / LevelScene) |
|---|---|---|
| 1 | none, wait 2 s | countdown ends, phase leaves COUNTDOWN, a piece spawns; shot `meadow_01_01-boot.png` |
| 2 | `wt_move_*` left ×1, right ×2 | piece x changes by −1 then +2; never leaves the 4×4 footprint at the wall |
| 3 | `wt_spin_*` ×4 | piece returns to its start orientation after 4 spins; tilt/roll actions do nothing (spin only) |
| 4 | `wt_rotate_view_*` ×1, then `wt_move_*` right | view tweens 30°; "right" maps to the new screen-right world direction at once |
| 5 | `wt_hard_drop` | piece locks; tick advances; shot `meadow_01_03-piece-locked.png` |
| 6 | repeat moves + hard drops to complete a layer (drive a known seed so the bag is deterministic) | layer clears, goal 1/4; shot `meadow_01_04-layer-cleared.png` |
| 7 | continue to 4 clears, or stack to top-out | win panel (`05-win`) or lose panel; retry restarts the same seed |
| 8 | `game_stop`; `debugger_get_log` | no `SCRIPT ERROR`, no orphan warnings |

Pass = all 8 rows observed, 5 shots retained, log clean. Add rows 1, 5, 6 and 7 to `tests/smoke/critical-paths.md` "Core Mechanic" when APP-001 lands. The touch-first input on a phone is a separate manual playtest (APP-001 AC: Android APK), not covered by `input_simulate`.

Headless fallback: `tests/integration/level_flow/level_scene_boot_test.gd` (APP-001) and the scripted-log `meadow_XX_smoke_test.gd` (Wave 8) prove it runs; they do not replace the shots.

---

## 5. Reviewer-agent prompt template

Spawn one per chunk after the coder hands off. Haiku for Logic tickets with ≤ 6 tests; Sonnet for scene/view tickets, CH-009 (fuzz), CH-035/036 (sim/replay) or any re-review after a FAIL. Read-only: the reviewer never edits files.

```text
You are a read-only test reviewer for Wacky Towers (Godot 4.7.2, GDScript, gdUnit4 6.2.1).
Repo: C:\Users\tessi\Claude\repos\wacky towers. Do not edit, create or run anything except the
commands below. Do not fix problems; report them.

Ticket: production/chunks/{CH-NNN-slug}.md
Coder hand-off:
{paste the 5-line evidence block from §1.1}

Read: the ticket; production/chunks/README.md "Conventions" and "Done when"; every file in the
ticket's Files list; tests/unit/rng/seeds_test.gd (style reference).

Check, in order. Each check is PASS or FAIL with one line of reason citing file:line.
1. FILES      `git status --porcelain` shows only files from the ticket's Files list (plus .uid).
2. TESTS-LISTED  every test the ticket's "Tests to write first" names exists, with the ticket's
              expected values (compare numbers literally, e.g. CH-035 ms_at 29 -> 483).
3. RESULT     the hand-off's exit code is 0 and its count includes these tests; re-run only
              the system folder:
              "/d/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -rd reports/review-{CH-NNN} -a res://tests/unit/{system}
              Must exit 0 (101 = FAIL: leak; 105 = FAIL: parse). "No test cases found" = FAIL.
4. API        public signatures match the ticket's API block exactly (names, types, returns);
              no extra public methods; static typing on every var/param/return.
5. DOCS       `##` doc comment on the class and every public method.
6. BANS       no global randi/randf/randomize/hash( in src; core files (src/core/**) have no
              Node, signal, await, Time, OS, Engine singletons; plus any ban the ticket lists.
7. MAGIC      no bare numeric literals in src except 0/1/-1; named consts carry a source comment.
8. SMELLS (tests):
   a. nondeterminism: randi/randf/Time/OS.get_ticks/await on timers/order of Dictionary keys
      assumed; any Seeds use must pass a fixed seed.
   b. magic numbers: expected values with no ticket/ADR source and not a boundary test.
   c. empty or weak asserts: a test with no assert_*; assert_that(x).is_not_null() as the only
      check; asserting a value against itself; a loop whose case list can be empty.
   d. tautology: expected value computed with the same code under test.
   e. isolation: shared mutable state between tests, file I/O in unit tests, Nodes without
      auto_free(), dependence on test order.
   f. naming: file <system>_<feature>_test.gd, function test_<scenario>_<expected>.
9. ACCEPTANCE the ticket's "Done when" line, item by item (e.g. CH-025: 3 PNGs exist at the
              named paths; Read each and say whether the whole box with margin is visible).

Return exactly:
VERDICT: PASS | FAIL
1 FILES: PASS|FAIL - <reason>
2 TESTS-LISTED: ...
... (one line per check, 1-9; 8 may carry a/b/c/d/e/f sub-lines only when FAIL)
BLOCKING: <the FAIL lines that stop "done", or "none">
FAIL if any of 1-7, 8a, 8c, 8d, 8e or 9 fails. 8b and 8f alone -> PASS with a note.
```

On FAIL the orchestrator sets the row to `in-progress (fix)` and re-spawns a coder with the reviewer's BLOCKING lines. Two FAILs on one ticket → QA looks at it directly; the ticket may be wrong.

---

## 6. Bug filing

- Path: `production/qa/bugs/BUG-NNNN.md` (directory does not exist yet; created with the first bug). ID = highest existing + 1, four digits, `BUG-0001` first. No slug in the filename.
- Format: the `/bug-report` template, unchanged (Summary with Severity S1–S4 and Priority P1–P4; Classification; Environment with **commit hash**; Reproduction Steps; Technical Context; Evidence; Related Issues; Notes). Extra fields for this fleet, under **Related Issues**: `Ticket: CH-NNN`, `Story: XXX-NNN`, `Group: X`, `Failing test: res://tests/...::test_name`, `Exit code: N`.
- Evidence: the failing gdUnit lines pasted (not a summary) and, for visual bugs, a PNG under `production/qa/evidence/bugs/BUG-NNNN-<what>.png`.
- Severity for this phase: S1 = suite cannot run (exit 103/104/105, import broken) or the game cannot boot; S2 = a ticket's acceptance test red or a determinism break (same seed, different result); S3 = leak (101), missing doc comments, test smell; S4 = cosmetic in a dev preview scene.
- When **not** to file: a chunk agent's own red during its red→green loop. File only what is red at a hand-off, a group gate or the live monitor.
- Every fix carries a regression test that was watched failing first (`test-standards.md`). Close only via `/bug-report verify` then `/bug-report close`.
- Run `/bug-triage` at each group gate if any bug is open.
