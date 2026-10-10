# Campaign hazard implementation

The runtime follows the authored encounters in `design/levels/lava.md`,
`forest.md`, `underwater.md`, `cave.md`, and `celestial.md`. Rules operate through
`RuleApi`; changes occur at hook boundaries and structural changes wait for the
simulation's resolving phase. Each rule owns a seeded random stream.

| Authored atom | Runtime rule | Behavior and counterplay |
| --- | --- | --- |
| EV04 | `lava_rock_spawn` | Warns one lock before placing a vent or a two-hit rock on an empty surface cell. Occupying the warning cell cancels the spawn. The authored maximum bounds live objects. |
| EV06 | `lava_rise` | Warns before making the lowest plane inactive. Masks its contents without awarding a clear or collapsing survivors. Stops permanently after `melt_max`. |
| EV06 lid variant | `lava_lid` | Warns, then lowers the danger line one plane. Trims excess cubes softly, respects protected vines, and never requests rescue. Depth is bounded by `lid_max`; each cleared layer lifts one step up to the original height and cancels a pending warning. |
| EV12 | `quake` | Selects a fixed, capped cohort of unsupported ordinary cubes, highest first. Removes that cohort at the next resolution, without a cleanup chain. A replacement cube with a different piece identity survives. Vines and locked or fixed content survive. |
| SP30 | `locked_cube` | Cannot move or clear while locked. A face-adjacent clear unlocks it; a diagonal clear does not. Permanent anchored geometry cannot be unlocked. |
| EV25 | `squirrel_heist` | Warns one lock before taking an exposed cube from the fullest unfinished layer above layer zero. Ties favor the lowest layer. Covering or clearing the marked layer cancels; the last cube in a layer is protected. |
| SP12 | `vines` | Selects the exact quota from each real dealt bag. Opening, fixed-list, and injected pieces do not consume bag slots. Protects the piece and face-contact neighbors against trim and quake effects; normal clears still work. |
| BL17 | `anchored_shelf` | The authored deck remains fixed and solid, with exact opening cells. Deck volume is excluded from the live clear denominator and forms a barrier between collapse chambers. |
| BL18 | `rock_obstacle` | Cave rock is permanent inactive solid geometry. It never moves or clears and is excluded from the active plane denominator. This differs from the spawned EV04 two-hit rock. |
| EV16 | `crab_claw` | Activates after the required cleared layers. Warns a top-surface column, then takes at most its highest cube. Any warning-time clear cancels. Avoids small stacks and columns under the falling piece. |

Locked, fixed, static geometry, clear protection, and vine trim immunity are
enforced centrally by `BoardState`, so another rule cannot bypass these contracts.
Vines do not globally forbid movement: that would break simultaneous movement
and duplicate blocks when the source removal is refused.

The real-board regression suite `tests/unit/mechanics/campaign_hazards_test.gd`
passed 19/19 cases on Godot 4.7.2, with zero failures, errors, or orphan nodes.
It checks warning timing, fixed cohorts, cancellation, object caps, two distinct
rock hits, clear denominators, protected content, true bag quotas, and bounded
ceiling pressure. The full campaign content validator supplies geometry and
reachability checks; a rule unit test does not establish campaign balance.

Production scripts were created through the authenticated GodotAI 4.3.0 editor
bridge. Job records are retained under `tools/godot-ai/jobs/engine-biome-rules-*`
and corresponding results. The addon's live validation of a rewritten global
class can report a transient duplicate-class reload error; the fresh runtime
suite is the execution evidence.
