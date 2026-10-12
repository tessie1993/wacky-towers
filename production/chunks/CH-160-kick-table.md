# CH-160 KickTable: ordered kick candidates (GDD F2)

**MB task:** MB-021 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-048
**Files:** new `src/core/sim/kick_table.gd` (`class_name KickTable`)

## API
```gdscript
class_name KickTable extends RefCounted
## Pure list builder for Movement.try_rotate (Movement & Rotation GDD F2).
static func candidates(axis: Orientations.Axis, down: Vector3i, footprint_center: Vector2, pivot: Vector3i, longest_extent: int, opts: Dictionary) -> Array[Vector3i]
## opts: {kick_off_axis: bool, kick_wide_min_extent: int, kick_enabled: bool}; returns offsets in try-order, first = Vector3i.ZERO (in place)
static func is_up_kick(offset: Vector3i, down: Vector3i) -> bool   ## offset has a component against the down axis
```

## Behaviour
- Order: `[in-place] + sort(G_in) + [up] + sort(G_in+up) + sort(G_out) + sort(G_out+up) + sort(2*G_in)`; G = the 4 one-cell ground offsets (perpendicular to `down`), split by `axis`: G_in perpendicular to the rotation axis, G_out parallel. Skip G_out terms when `kick_off_axis == false`; skip 2*G_in when `longest_extent < kick_wide_min_extent`; `kick_enabled == false` returns just `[ZERO]`.
- `sort` = ascending d^2 of the resulting pivot's ground coords vs `footprint_center`; ties by fixed order (+x, +z, -x, -z) so it is deterministic.
- Never contains a downward offset. Max 14 candidates (Turn) / 12 (Flip, Roll).
- Knob names: `control.kick_enabled`, `control.kick_off_axis`, `control.kick_wide_min_extent`, `control.kick_order` (read by the caller).

## How the integrator sees it working
Editor script eval: GDD F2 example: Turn (axis Y), down (0,-1,0), pivot (3,5,1), centre (3.5,3.5), extent 3: print the list; expect order ZERO, +z, +x, -x, -z, then up and up+offsets (10 entries below the wide extent). With extent 4 the list has 14 entries (2-cell kicks last). Flip (axis X) list has at most 12.

**Out of scope: applying candidates, up-kick budget (CH-053).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
