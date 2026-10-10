# Toy-Box Trials validation — 2026-10-10

Delivery: Wacky Towers PR #17, branch `codex/complete-game-studio-2026-10-10`.
Three standalone minigames, nine selectable levels, nine authored Shadow
blueprints, three original Blender stages. The package is single-player practice.

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf` (the repository pin).
- Blender 4.5.9 LTS, build `8bf95cbd38d1`.
- Graphical checks: X11/Xvfb, 1280×720, Compatibility renderer, Mesa llvmpipe
  OpenGL 4.5. These are real Godot viewport captures, not concept renders.
- Godot AI editor integration: see [relay evidence](godot-ai-arcade-integration.md).

## Automated results

| Check | Result | What it establishes |
| --- | --- | --- |
| `tests/minigames/run_arcade_tests.gd` | PASS, zero failures | All three rule suites; all nine levels; deterministic seeds and legal solutions |
| `tests/minigames/arcade_ui_smoke.gd` | PASS, zero failures; 15 captures | Every level can win through public gameplay actions; actual keyboard events; readable HUD, briefings, pause and results |
| Full gdUnit4 regression suite | PASS, 412 cases across 55 suites; zero errors, failures or orphans | Existing campaign, core simulation and data regressions |
| Main-menu navigation smoke | PASS, real graphical Godot, exit zero | Arcade → Trials → active minigame → Hub → Original game; profile playing lock cleared |
| Blender source/export verification | PASS | Original source, deterministic builder, glTF bounds/counts/hashes/materials and unobstructed play space |

Stack checks include real overlap trimming, alternating axes, misses, snaps,
wind/rhythm determinism, timer partitioning, terminal events and restart.
Gate checks include the 24 cube orientations, reachable holes, both projection
axes, focus, bonuses, pass boundaries and seeded replay. Clockwork's timing
threshold allows every manual beat bonus and a three-star finish together.
Shadow checks include all nine authored witness solutions, alternative valid
builds, extra silhouette cells, budget refunds, blocked sockets, undo and timeout.

The graphical runner checks every briefing and play screen, a natural stack
failure, a win, pause-key repeat, frozen gameplay while paused, restart and
finished-round input rejection. It restores the previous local best-score file.
Shadow uses a fixed view that keeps both target panels visible. Gate alignment
has an exact 2D projection map alongside the 3D wall. Score celebration effects
are cleared before individual screenshots only to make the evidence readable.

## Retained evidence

- [Hub](evidence/arcade_pack/godot_hub.png)
- [Main Arcade menu entry](evidence/arcade_pack/pr17-arcade-entry.png)
- [Perfect Stack / Clockwork Lift](evidence/arcade_pack/godot_play_stack_clockwork.png)
- [Parcel Gates / Star Thread](evidence/arcade_pack/godot_play_wall_star_thread.png)
- [Shadow Workshop / Clockwork Sign](evidence/arcade_pack/godot_play_shadow_clockwork_sign.png)
- [Pause](evidence/arcade_pack/godot_pause.png), [win](evidence/arcade_pack/godot_result_win.png), [failure](evidence/arcade_pack/godot_result_fail.png)
- [Blender front/rear/top contact sheet](evidence/arcade_pack/blender_arcade_contact_sheet.png)
- [Blender export report](../../assets/source/blender/arcade_pack/VERIFICATION.md)

All nine gameplay screenshots and both introductory briefings are in the same
evidence folder. Rule and graphical runs exited zero with no script/runtime
errors. The restricted host emits `/proc/self/exe` and unsupported VSync warnings;
neither changes gameplay or the rendered evidence.

## Scope and remaining checks

Meadow teaches each verb, Clockwork combines constraints, and Celestial adds
recovery decisions. Story-matched props and authoring briefs connect the lessons
to Pip, Tock and Comet. Skits are briefs; implemented runtime help presents rules
and controls. No human novice playtest or subjective fun/balance sign-off has
been performed. No mobile-device performance, target Mobile renderer,
multiplayer, matchmaking or tournament reward validation is claimed.

Campaign input maps, autoload configuration and the default main scene remain
unchanged. The menu card/navigation hook is isolated. Two pre-existing PR
defects were repaired: the missing closing parenthesis in `ItemsRule` that
blocked main-scene compilation, and a deferred-damage call to nonexistent
`BoardState.idx` in `BoardSim`, corrected to its public `index` method. The
existing damage regression was observed failing before the latter fix; its
21-case suite and the full 55-case simulation folder then passed. The arcade
saves to its own `wt_arcade_pack.cfg`.
