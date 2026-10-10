class_name ArrivalPlan extends RefCounted
## Where and how a new piece arrives (ArrivalStyle result). Usage: `plan.blocked` means top-out.

## Spawn origin cell.
var origin: Vector3i = Vector3i.ZERO
## Orientations index.
var orient: int = 0
## Any of the 6 unit directions (ADR-0001).
var travel_dir: Vector3i = Vector3i.ZERO
## True = spawn blocked (top-out).
var blocked: bool = false
