## Axis ids shared by input, camera and sim command building (ADR-0012 §3).
## Player-facing names Turn/Flip/Roll are UI text only.
class_name InputAxes
extends RefCounted

## Turntable spin around world Y (player-facing "Turn").
const SPIN: StringName = &"spin"
## Flip in the screen plane around the camera view axis (player-facing "Flip").
const TILT: StringName = &"tilt"
## Roll around the remaining axis (player-facing "Roll").
const ROLL: StringName = &"roll"
## Every rotation axis, in display order.
const ALL: Array[StringName] = [SPIN, TILT, ROLL]
