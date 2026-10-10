# Mechanics runtime

Rules in this directory are pure, statically typed `RefCounted` plugins. They do not instantiate nodes, read wall-clock time, or use the global random generator. `BoardSim` advances them on fixed ticks and supplies the only write facade, `RuleApi`. The plugin registry discovers each declared `PLUGIN_ID`; the corresponding rule JSON selects the behaviour and supplies its parameters.

## Slot plugins

| Slot | IDs | Behaviour |
|---|---|---|
| Arrival | `top`, `side_travel` | Centre the bounding box on the authored anchor, with its lowest cube at the current axis's danger line. Occupied spawn cells stay blocked. |
| Clear detector | `layer`, `none` | Full planes, or no clears for build/target levels. |
| Clear detector | `colour_connect` | Face-connected same-colour groups; minimum cubes and contributing piece IDs are both required. |
| Clear detector | `mono_layer` | Normal planes plus extra occupied planes above a full single-colour plane. |
| Collapse | `slice` | Remove detected planes and shift the planes above them. |
| Collapse | `cascade` | Drop unsupported individual cubes along current gravity. |
| Collapse | `gummy_cascade`, `gummy` | Drop each connected same-colour blob rigidly, retaining its overhangs. Both IDs select the same semantics. |
| Goal | `clear_n`, `height`, `shape`, `survive`, `endless` | Count clears; reach exact-layer coverage; cover target cells; reach playing time; or continue until failure/exit. |
| Goal | `colour_target` | The same flavour-aware target evaluator as `shape`. |
| Top-out | `rescue`, `trim`, `lose` | Spend a warning and wipe lower planes; remove only overflow cubes; or lose immediately. |

`shape` accepts `+`/`#` targets and Candy's `P`/`V`/`M` flavour targets (colour IDs 1/2/3). A wrong flavour remains a smudge. A cube with `status.rainbow = true` matches any flavour. `win_correct` permits a specified number of correct cells; omitting it requires all targets. Empty targets never produce an automatic win.

## Behaviour plugins

| IDs | Runtime effect |
|---|---|
| `build_race`, `fill_shape` | Select no-clear and trim slots at level start. |
| `mascot_catch` | Veto a covered-hole lock before board writes, then return the same piece to spawn. Clearing/goal-winning placements are protected. |
| `gust` | Schedule seeded, telegraphed pushes of the active piece. Due gusts without an active piece are dropped. |
| `mushroom_popup` | Mark a free surface one lock before an object appears. `object_kind` selects the registered content kind; `place_mode = lowest` restricts candidate surfaces. An occupied mark cancels the spawn. |
| `wobble` | Count unsupported cubes, then rigidly slip the latest surviving piece toward the heavier side; off-island pieces pop off. |
| `sprouts` | Grow identified living columns on lock intervals. Their IDs move with content, including after their original root clears. `grow_max = 0` is uncapped. |
| `hatching_eggs` | Age eggs by completed locks, then hop to the lowest reachable neighbouring column with a fixed tie order. |
| `fog` | Emit deterministic locked-content visibility and clear-triggered reveals. Collision remains unchanged. |
| `fog_ghost` | Mark tagged pieces intangible, then solidify them through the sim's legal-fit helper when tapped/dropped or landed. |
| `dandelion_puff` | Draw one spawn seam seed, choose the most balanced ground-axis cut, and settle both halves independently. |
| `topsy_tumble`, `flip` | Queue structural stack inversion; `flip` also supports an axis change and a maximum flip count. |
| `mill_belt`, `conveyor` | Simultaneously translate locked contents, preserving cube identities/status through wraparound cycles. |
| `sticky_landing` | Slow gravity and lock on first support. |
| `ice_slide`, `bounce_pad` | Slide once on landing; or hop once from a pad and continue in the last move direction. |
| `syrup_band` | Slow falling pieces over authored rows, preview their glide endpoint, then glide up to two cells once and lock. |
| `thin_ice` | Telegraph and remove an ordered rim strip at a resolution boundary while preserving minimum width. |
| `turntable`, `piston_punch` | Quarter-turn a square stack; or push an occupied row prefix into its first gap from any of the four ground-plane walls. |
| `stopwatch` | Freeze gravity/lock delay, then apply a timed catch-up rate while allowing commands. |
| `colour_pop`, `mono_layer` | Select their detectors and configure clear knobs at level start. |
| `rising_silt` | Push contents up and add a floor with sky-reachable gaps. Closed columns defer the rise until a clear. |
| `snowball` | Roll identified columns over small steps, grow them, park blocked balls, and respawn at the high end. |
| `pest`, `goo_spread` | Eat ordinary cubes / starve when trapped; or spread goo with clear-to-cancel protection. |
| `woodpecker_knock` | Telegraph a fixed highest-first subset of unsupported cubes, then pop them at resolution. |
| `mirror`, `bubble`, `ember`, `rainbow_piece` | Add mirrored copies; raise/pop tagged pieces; drill below tagged pieces; or stamp wildcard status. |
| `mascot_hint`, `angle_gem` | Announce a legal suggested placement; or expose and collect a secret through an explicit matching tap. |

These implementations describe available runtime primitives. They do not imply that every authored boss, stage swap, proposed atom, or presentation asset is complete. The campaign's implementation coverage file records authored requirements that still need their own semantics.

## Write order and deterministic state

Content writes flush at hook boundaries. Structural mask/axis/slot changes apply in Resolving. Living content moves before later rules such as the belt. A content write after the first clear pass can cause one additional clear pass; the resolve hook does not recurse.

Simultaneous moves use `move_cells`, including cycles, rather than a sequence of destructive single-cell moves. Dandelion settlement and wobble use a virtual occupancy calculation to determine final destinations before their single buffered move. This preserves correctness while the write facade buffers mutations.

Every behaviour's mutable counters are returned by `snapshot()`. Random choices use `api.rng()` and canonically ordered candidates; a one-candidate choice consumes no random draw. Growth/hatch ages and living-column IDs stored in cube status follow slice, flip, cascade, and conveyor moves.

## Verification

The mechanic tests use real boards and the real facade, flushing each simulated hook boundary. They cover exact-height coverage, flavour targets and wildcard cells, trim/rescue accounting, living-content timing, wraparound identity preservation, virtual split settlement, wobble, fog, seeded gust schedules, same-colour contributors, diagonal exclusion, rigid gummy support, silt's reachability guard, snowball parking, pests, and axis-aware arrival.

`WtPerfectFit.suggestions(api, shape, max_marks)` in `src/game/abilities/perfect_fit.gd` implements Skills F5 as a pure search. It sweeps distinct orientations and ground positions, rejects blocked drop rays and newly covered holes, deduplicates final placements, then ranks completed planes, support, landing depth and canonical orientation/position. It returns up to three cell sets and never advances RNG. Tests cover clear priority, a beam over a covered hole, repeated identical results, impossible footprints and all six gravity directions. The ability caller evaluates at spawn or after a board write and caches marks between those changes; this synchronous helper has no measured frame-budget guarantee.

After importing the project with Godot 4.7.2, run:

```bash
godot --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/mechanics --ignoreHeadlessMode
```

The expected remote-debugger port diagnostic does not determine test success. Require the report to list the discovered/executed test cases with zero failures, rather than relying solely on the process exit code.
