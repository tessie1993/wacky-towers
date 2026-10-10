# Plan: play the first level (meadow_01)

Two tracks. Track A gets you playing soonest; Track B is the real game that replaces it.
Every integrator uses **godot-ai** as its eyes: `logs_read` after each import, `project_run` + `input_simulate` to play, `editor_screenshot source=game` to check, and it fixes before reporting. QA runs a godot-ai sweep (logs_read + full gdUnit suite) after every wave and feeds errors back to the owning agent.

## Track A — prototype, F5-playable (in progress)
| # | Step | Who | Status |
|---|------|-----|--------|
| A1 | 6 parts written in staging (board, pieces/bag, game, view, input/touch, HUD) | 6 Sonnet/Haiku | done |
| A2 | Move in, import, fix parse errors, `fp_main.tscn`, stand-in platform `fp_platform.tscn` | Opus integrator + godot-ai | in progress (scene open, has run) |
| A3 | InputMap, main scene = fp_main, 3-axis rotation (yaw Q/E, pitch R/F, roll T/G), camera-relative | same integrator | queued |
| A4 | godot-ai playtest to a layer clear + win, screenshots → production/qa/evidence/first-playable/ | same integrator | queued |
**You play:** press F5 in Godot once A4 reports "plays: yes".

## Track B — real modular game, meadow_01 inside the framework
| Wave | Parts | Plugin | Agents |
|------|-------|--------|--------|
| B0 | CH-034 LevelData/GameCatalog (running), CH-035 BoardSim skeleton, CH-036 Replay | — | Sonnet ×1 each |
| B1 | Spawner + bag, ActivePiece, 3-axis rotation + kicks, fall/soft/hard drop, lock delay, layer clear + collapse, goal clear_n + top-out | — | Sonnet per chunk; same-file chunks merged |
| B2 | LevelLoader (JSON → LevelData), meadow_01 JSON → `src/levels/meadow/meadow_01/` | — | Sonnet + Haiku |
| B3 | Controls: `GameInput` signals (move, rotate_piece yaw/pitch/roll, drops, view, pause, restart) + touch buttons | **GUIDE** | Opus implementer (GUIDE resources via godot-ai) |
| B3 | Camera: CameraRig on PhantomCamera3D + PhantomCameraHost, 12 snaps | **phantom_camera** | Sonnet implementer |
| B3 | Board/piece/ghost view with candy_toy cube MultiMesh (RND-01..08 greybox) | — | Sonnet per chunk |
| B3 | Stand-in landing platform kit `src/levels/_kit/platform/` | **TileMapLayer3D** | Sonnet implementer |
| B4 | HUD (layers x/n, timer, next, result panel w/ stars) | — | Haiku + Sonnet |
| B5 | GP-5: `PlaySession` + `LevelStage` + `meadow_01.tscn` + Main, wired via godot-ai; QA plays to win and loss with `input_simulate` | all | Opus integrator, QA |
| later | Pip helper behaviour (cheer on clear), Miller boss in meadow_10 | **beehave** | Sonnet |
Tests: gdUnit4 per chunk (tests first) + one full-suite gate per wave.

## What I need from you
1. Nothing to start: Track A is running. When it says "plays", press F5 and tell me how it feels.
2. Keep the Godot editor open (godot-ai needs it).
3. Decisions with defaults (say if you disagree): meadow_01 stays spin-only in the real game (all axes in the prototype); GUIDE/PhantomCamera autoloads stay registered (breaks the plan's "no gameplay autoloads" rule — accepted).
