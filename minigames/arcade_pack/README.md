# Toy-Box Trials — Wacky Towers arcade pack

Three independent Godot 4.7.2 minigames with nine levels and original Blender
floating-island stages, integrated into the existing Arcade menu.

## Play

Open `arcade_hub.tscn` in the existing Godot project and press **F6**. Or run:

```bash
godot --path . res://minigames/arcade_pack/arcade_hub.tscn
```

From the game's title menu, choose **Arcade → Play Toy-Box Trials**. The hub
opens every level. Pick a challenge, read its objective, then play.
Keyboard and on-screen controls use the same semantic actions.

| Game | Main action | Additional controls | Level mix |
|---|---|---|---|
| Perfect Stack | Space: lock slab | U/E: limited magnet snap | X/Z timing, overhang trim, wind, pendulum rhythm |
| Parcel Gates | Space: send parcel | E/Q: rotate; arrows: align; U: focus in Celestial | Reachable holes, changing projection axes, beat bonuses |
| Shadow Workshop | Space: add/remove cube | Arrows: move across pad; E/Q: raise/lower; U: undo | Dual silhouettes, shared cube budgets, blocked sockets |

**P/Esc** pauses, **R** restarts. **Z/C** rotates the camera in Stack and Gates;
Shadow keeps a fixed view so both panels remain readable. Best stars, score and
time save separately to `user://wt_arcade_pack.cfg`. Existing player profiles
are not changed. The hub's **Original game** button returns to the game's main menu.

Meadow introduces the verb, Clockwork combines it with a second constraint, and
Celestial tests recovery. Shadow includes three blueprints per level (nine
authored puzzles). Pip, Tock and Comet's story beats are recorded as wordless
art/skit briefs in the level design; runtime help stays functional.

## Merge and integrate

Delivery branch: `codex/complete-game-studio-2026-10-10` in PR #17. The package
was developed independently. Files live under this folder, the new
`assets/models/arcade_pack`, `assets/source/blender/arcade_pack`, and dedicated
test/evidence paths. Godot AI added the Arcade menu card and a navigation intent
in `src/ui/game_ui.gd` and `src/app/main.gd`. Input maps, autoloads and the default
main scene are unchanged. Two existing PR compile/runtime defects were repaired
to pass main-game regression checks; details are in the validation report.

To add a button to a future main menu, use:

```gdscript
get_tree().change_scene_to_file("res://minigames/arcade_pack/arcade_hub.tscn")
```

Every model implements `round_base.gd` and emits `round_finished(result)`.
`interaction_requested(event)` is a future tournament-adapter boundary; this
package is single-player practice and does not implement LAN play, matchmaking
or tournament rewards. Match state lives in models, never in the HUD.

## Assets and checks

Blender source, deterministic builder script, GLB bounds/hashes and licensing:
`assets/source/blender/arcade_pack/`. Rebuild with Blender's background Python
using that folder's instructions. Hero cubes reuse the existing candy-toy mesh.

```bash
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/minigames/run_arcade_tests.gd
```

Graphical smoke (run with a real/virtual display, not `--headless`):

```bash
godot --path . --windowed --resolution 1280x720 \
  --script res://tests/minigames/arcade_ui_smoke.gd
```

Evidence and exact validation limits are recorded in
`production/qa/arcade-pack-validation.md`. Design:
`design/gdd/arcade-pack.md`, `design/levels/arcade-pack.md`.
