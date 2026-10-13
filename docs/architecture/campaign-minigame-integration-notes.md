# Campaign Minigame Integration: Technical Notes

Status: investigation notes (no code changed). Engine: Godot 4.7.2, GDScript. Date: 2026-10-13.
Line references are to the working tree at the time of writing.

## 1. Templates: where they live, schema, setup

**Storage.** All 40 round templates (4 versus modes + `mg01`..`mg36`) live in one file,
`assets/data/tournament/templates.json` (`{"schema":1,"source":[...],"templates":[...]}`).
The only reader is `WtModes._init` (`src/game/modes/wt_modes.gd:20`). Ids are lower-case
(`mg22`); `minigame_id` carries the display form (`MG22`).

**Template keys** (union over all rows): `id, minigame_id, mode, category ("minigame"|"versus"),
tags, name, card_name, name_key, rule, rule_key, icon, duration_ms, weight, standing_metric
(score|race_progress|height|alive_time), standing_tiebreak, interaction_hook, slots{board_kind,
spawn_entry, clear_detector, collapse, top_out_check, goal_evaluator}, board{width,depth,h_play},
piece_pool, items_enabled, item_whitelist, item_trigger, twist_limit, skill_support, perk_support,
controls[], params{...}, rules_script, always_available, level{...}` (versus only), `source`.
Example `mg22` params: `roll_step_ms, curve_row, balls_per_frame, strike_points, spare_points, ...`.

**Rules script selection** (`src/game/minigames/minigame_session.gd:63`): explicit
`rules_script` wins (8 rows -> `rules_c.gd`, 7 rows -> `rules_d.gd`); otherwise a hardcoded id list
-> `rules_b.gd`, everything else -> `rules_a.gd`. `mg05` (Crane Tower, native Jolt scene) is refused
by both `WtMinigameRound.UNSUPPORTED` (`minigame_round.gd:7`) and `session.setup` (`minigame_session.gd:43`).

**Setup chain.**
- `WtMinigameRound.setup(row, seed, catalog, players)` (`minigame_round.gd:28-48`): one
  `WtMinigameSession` per player, *all with the same seed*; bot RNG is
  `Seeds.make_rng(seed, ["minigame_round_bots", id])` (`:37`). Returns false if unsupported.
- `players` rows: `{"name": String, "is_bot": bool}`; **index 0 is the local human**; any index > 0
  is forced to a bot (`:47`). Built in `main.gd:421`.
- `WtMinigameSession.setup` (`minigame_session.gd:37-67`): copies `params`, duration from
  `duration_ms`, derives `rng` (`["minigame", id, "challenges"]`) and per-owner `attack_rng`
  (`:60-61`), builds a `Spawner` from the seed, loads the rules script and calls `start`.
- Per tick: `step()` (`minigame_round.gd:61`) runs bots every `BOT_EVERY=18` ticks with
  staggered phase, steps sessions, routes `mg_send_request` / `mg_shared_request`.
- **Result row** (`minigame_round.gd:86-97`): `{id:"0", player, index, won, ms, standing_value,
  progress, score, height, layers:0, alive, alive_time, active:true}`. Session-level result
  (`minigame_session.gd:186-190`): `{status: won|lost|time_cap|invalid, score, progress_milli,
  standing, elapsed_ms, player_id, ghost}`.
- **Standings**: `_ranked()` sorts by `standing()` (driven by `standing_metric`,
  `minigame_session.gd:200-205`), then score, then player id (`minigame_round.gd:121-127`).
  The *tournament* winner decision is in `WtModes.record_round` (`wt_modes.gd:195-235`): timed
  goal evaluators (`score_timer|height_timer|last_standing`) rank by metric; others by earliest win.

## 2. Minimal campaign integration

### Why it does not work today
- `LevelValidator` whitelists goal types (`src/data/level_validator.gd:36-38`) -> `"minigame"` is
  rejected as `unknown_goal`. It also requires a non-empty weighted bag (`:28-34`).
- `LevelLoader.parse_level` requires `id, board, goal` (`src/data/level_loader.gd:8`) and rejects
  unknown top-level keys (`:29-31`), so no new top-level key without editing `KEYS_TOP` (`:7`).
- `verify_campaign_biomes.gd:41` fails any level whose `goal.type` has no `GoalEvaluator` plugin,
  then builds a `BoardSim` and instantiates `entry.scene` (`:42-52`).
- `main._start_level` (`main.gd:371-381`) always goes `LevelLoader -> _begin_session -> BoardSim`.
- `_start_minigame_round` / `_minigame_tick` (`main.gd:418-454`) are tournament-bound: players come
  from `_modes.tournament_snapshot()`, results go to `_modes.record_round()` (which returns
  `round_not_playing` unless a tournament round is locked, `wt_modes.gd:196`), `stars` is
  hardcoded 0 (`:451`), and lifecycle mode is `"tournament"`.
- No public "template by id" lookup: `WtModes.round_cards()` (`wt_modes.gd:26`) returns the whole
  library; `WtTournamentRandomizer.template(id)` exists (used at `wt_modes.gd:118`).

### Proposed level JSON (in `src/levels/<biome>/<id>/<id>.json`)
Keep `board`/`pieces` (loader requires them; copy from the template's `board`/`piece_pool`) and put
everything minigame-specific under `goal`, which the loader already passes through verbatim
(`level_loader.gd:58`):

```json
"goal": {
  "type": "minigame",
  "minigame_id": "mg22",
  "opponents": {"count": 2, "skill": "practice"},
  "params": {"balls_per_frame": 3, "strike_points": 25},
  "duration_ms": 75000,
  "theme": "candy"
},
"stars": {"metric": "score", "s2": 120, "s3": 200}
```
- `opponents.count` 0..3 (0 = score-target stage). `params` is shallow-merged over template params;
  `duration_ms` overrides the template.
- `stars.metric` is already accepted as a string by the loader (`level_loader.gd:238-240`); other
  star keys must be whole ints. Metrics: `score` | `standing` | `rank` (`s2`/`s3` = max rank, e.g.
  `{"metric":"rank","s2":2,"s3":1}`). 1 star = finished/won; 0 stars = not cleared.
- Win condition for 1 star: with bots, rank <= `goal.win_rank` (default 1); without bots,
  `metric >= stars.s1` (add optional `s1`).
- Catalog entry (`assets/data/campaign/catalog.json`) needs no new field; optionally
  `"kind": "minigame"` for map icons. `scene` can point to a tiny descriptor scene or be omitted
  once the verifier branches.

### Touchpoints (smallest change set)
1. `level_validator.gd:37`: accept `"minigame"`; for it, skip bag/board-shape checks and instead
   validate `minigame_id` exists, is supported, and star keys match `metric`.
   Validator has no template access today -> inject a template lookup (e.g. new
   `WtContent.minigame_template(id)` that reads `templates.json` once; avoid going through `WtModes`).
2. `WtContent` (`src/data/wt_content.gd:62-78`): unchanged load path; add the template lookup above.
3. `verify_campaign_biomes.gd:41`: branch for `goal.type == "minigame"`: run `WtMinigameRound`
   headless for N ticks with seed 1729 and the requested bot count, assert `finished()` and a
   result row; skip BoardSim/scene checks.
4. `main.gd`:
   - Intro (`main.gd:356-369`): `_goal_text` and `star_targets` assume `t3/t2` ms; add a
     minigame branch (template `rule` text, star metric labels).
   - `_start_level` (`:371`): if `raw.goal.type == "minigame"` call a new
     `_start_campaign_minigame(level)` instead of `_begin_session`.
   - Factor `_start_minigame_round` into `_run_minigame(template, seed, players, mode)` so both
     tournament and campaign share setup; campaign builds `players` locally
     (`[{name: profile}, {name: "Bot 1", is_bot: true}, ...]`).
   - `_minigame_tick` (`:438`): branch on `_mode`. Campaign path must NOT call
     `_modes.record_round`; compute rank from `results()` (sort like `_ranked`), stars from
     `_level.stars`, then `_store.record_result(_level_id, stars, ms, score, _level.level_hash)`
     (`wt_profile_store.gd:194`; returns no award for 0 stars) and reuse the `_finish_level`
     results/story flow (`main.gd:630-655`). `_star_pace` (`:731`) needs a minigame branch for HUD.
   - Pause/quit (`:572-574`), `_back`, and `has_session` (`:1135`) already treat `_minigame` generically.
5. Template merge: deep-copy template, overlay `goal.params`/`duration_ms`, set `template.theme`
   for `WtMinigameArt` / UI.

Solo edge case: with 0 bots, `_target()` returns -1 (`minigame_session.gd:242-254`) so send effects
are dropped; templates whose design depends on incoming attacks (send/attack hooks) will feel
different solo. Prefer bot counts >= 1 for `interaction_hook: ["send"]` templates. Unverified:
whether every rules script tolerates `_players == 1` without edge cases; test per template.

## 3. Adding a new minigame: the contract

1. **Template row** in `templates.json`: `id` (`mg37`), `category:"minigame"`, `duration_ms`,
   `standing_metric`, `slots.goal_evaluator` (`score_timer` etc., used by `record_round`), `board`,
   `piece_pool`, `controls[]` (also the bot action vocabulary, `minigame_round.gd:195-223`),
   `params`, and `rules_script` (always set it explicitly for new rounds).
2. **Rules script** (stateless dispatcher, e.g. new `rules_e.gd`, pattern `rules_c.gd:1-90`):
   `start(s)`, `tick(s, events)`, `command(s, cmd) -> bool` (true = consumed), `attack(s, effect,
   data)`; all mutable data in `s.state`, presentation data in `s.view`; use `s.add_score`,
   `s.progress`, `s.finish(status)`, `s.charge_send`, `s.rng` (never global RNG). Optional `s.sim`
   (BoardSim) gets default grid handling for `mg_move/mg_rotate/...` (`minigame_session.gd:132+`).
   Unknown ids must `s.finish(&"invalid")`.
3. **Bot**: if controls are new intent names, add a case in `_bot_act` (`minigame_round.gd:207-223`),
   otherwise the default branch queues the bare intent.
4. **UI**: `src/ui/minigame_ui.gd` builds controls per id (`_build_actions`, `:191-233`) and draws
   per id (`:345-401`). Preferred: new `src/ui/minigame_ext_e.gd` with `static handles(id)` plus
   control rows, appended to `EXTENSIONS` (`minigame_ui.gd:12`, lookup `:184-189`), as wave 2 did.
5. **Art**: add an entry to `WtMinigameArt.THEMES` (`src/view/wt_minigame_art.gd:4-42`) and a
   branch in `create()` (`:57+`); `normalize()` falls back to `mg01` for unknown ids (`:43-52`).
6. Audio (`src/view/fx/wt_minigame_audio.gd`), localisation keys, `src/ui/tests/minigame_ui_smoke.gd`,
   and a unit test under `tests/unit/minigames/`.

**"Wobble Builders" estimate.** Two routes:
- **A. Integer session (recommended):** BoardSim stacking (reuse `rules_a` grid path) plus a
  fixed-point spring/stability model in `state` (mass offset from centre -> lean, damped spring
  per tick, meter 0..1000, topple when exceeded). Deterministic, bots, sends and campaign/
  tournament all work for free. Effort: rules ~1.5 d, UI ext + meter ~1 d, art primitive ~0.5 d,
  tests/tuning ~1 d = **~4 dev-days**.
- **B. Real physics** via `WtPhysicsChallenge` (`src/physics/wt_physics_challenge.gd`, new entry
  in `VARIANTS` `:7-10`, config `setup` `:61-70`, Jolt + LimboAI `WtPhysicsAction`): looks best,
  but Jolt is not deterministic across machines, it cannot run inside `WtMinigameRound` (same reason
  as `mg05`), no bots/LAN; campaign only as a score-target stage. Note 4.7 Jolt changes
  (`WorldBoundaryShape3D.plane.d` sign flip; SoftBody3D/Area3D) before using a spring/soft body.
  Effort **~5-7 dev-days** plus a separate campaign path through `_start_physics` (`main.gd:1148`).

## 4. Randomness

- Tournament seed: `_modes.start_tournament(..., _fresh_seed(), ...)` (`main.gd:308`; LAN `:909`).
  `round_seed = Seeds.derive(seed, ["round", round_index])` (`wt_tournament_randomizer.gd:149-150`),
  attached to every draw (`:147`, sudden death `wt_modes.gd:123`).
- **Confirmed:** `_start_minigame_round` passes `int(draw.get("round_seed", 20261010))`
  (`main.gd:423`) and every session in the round shares it (`minigame_round.gd:42`), so all players
  face the same challenge sequence; incoming attacks differ per owner by design (`minigame_session.gd:61`).
- Caveat: the `20261010` fallback means a malformed draw replays one fixed round; prefer failing
  loudly or using `_fresh_seed()`.
- Campaign BoardSim levels: `_begin_session` uses `_fresh_seed()` unless tournament/lan with a fixed
  seed (`main.gd:465-467`). The campaign minigame path should do the same: `_fresh_seed()` per
  attempt, or `level.seed` when the JSON pins one (puzzle-like stages). `_attempt_rng` is fixed at
  1729 in smoke runs (`main.gd:74`).

## 5. Blender 5.2 pipeline and 3D-looking UI

**Current state.**
- Installed binary reports `Blender 5.2.2 LTS` (matches pin in `.claude/docs/technical-preferences.md:18`).
- `assets/source/blender/scripts/export_glb.py:8` hardcodes a Windows `GAME_MODELS_DIR`; on Linux/CI
  it silently skips the copy (`:26`). Make it an env var / CLI arg. Export uses
  `export_apply=True, export_yup=True` (`:24-25`).
- `SPEC.md` names a different repo path (`C:/Users/tessi/...`) than the pin file (`D:/TESSA/...`).
- `render_lineup.py:32-34` renders a 1600x1100 probe PNG; the rendering path already exists.
- `project.godot:39-46` sets `[importer_defaults] scene` -> `block_post_import.gd` for **every**
  scene import. The script only acts under `res://assets/models/blocks/` (`block_post_import.gd:12-16`),
  so UI GLBs elsewhere pass through, but keep UI models out of `blocks/`.
- `minigame_ui.gd:122-131` already uses `SubViewport` with `UPDATE_ONCE` for art previews.

**Recommendation: rendered PNG nine-patch for frames/buttons/plaques; GLB-in-SubViewport only for
hero ornaments.**
- Frames, buttons and plaques are numerous, resize with text/locale, and need hover/pressed/disabled
  states. A Blender render (orthographic camera, transparent film, baked light matching the art
  bible) of a bevelled panel, sliced into `StyleBoxTexture` (`texture_margin_*`, `axis_stretch` tile
  or stretch) is cheap on the Mobile renderer (`project.godot:127`), crisp with `canvas_items` stretch
  (`:32-33`), and themeable. Render at 2x, keep corners outside the margins, export state variants
  (normal/hover/pressed/disabled) from one script.
- Add `tools/asset-pipeline/render_ui_kit.py` (headless `blender -b ui_kit.blend -P ...`) writing to
  `assets/ui/kit/` with a manifest of margins, so `.tres` StyleBoxes can be generated/checked.
- SubViewport GLBs cost a viewport render pass each, do not nine-slice, need manual DPI handling and
  break theme inheritance. Use for 1-3 animated hero pieces (results trophy, star plaque) with
  `UPDATE_ONCE`/`UPDATE_WHEN_VISIBLE` and transparent background.
- 4.7 caveats (from `docs/engine-reference/godot/breaking-changes.md:11-31`): `CanvasItem` lines lose
  antialiasing feather (thin drawn outlines around frames look thinner; bake outlines into PNG);
  `LinearToSRGB` visual shader no longer clamps on Mobile (check any UI shader glow); new
  `Control` offset transforms survive container sorting (useful for button press juice,
  `current-best-practices.md:175`); custom import plugins see `IMPORT_*` -> `ImportFlags`
  (`EditorScenePostImport` used here is unaffected). HDR output is iOS-only in 4.7; UI PNGs should
  stay sRGB. Unverified: whether StyleBoxTexture behaviour changed in 4.7 (not in the reference files).
