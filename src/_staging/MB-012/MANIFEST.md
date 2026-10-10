# MB-012 / CH-044 Spawner
| Final path | Action | See it working |
|---|---|---|
| src/core/sim/spawner.gd | new | In editor: `var s := Spawner.new({"shapes": PackedStringArray(["i","o","t","l","s"]), "weights": {}, "opening_set": PackedStringArray(["o","i"]), "opening_count": 2}, 3, 1)`; print 12x `s.next()`: first 2 are o/i, then permutations of all 5 per 5. Same seed -> same output. Float weights {"i":0.5,"o":1.0} -> i x1, o x2 per bag.
Notes: opening pieces are extra (bag 1 is full), per ticket. Opening refills reshuffle with part index. No tests (user rule).

## Review (godot-specialist, 2026-10-10)
- `weights_to_copies`: always applies GDD F1 `max(1, round(w/w_min))`. The old int-vs-float split broke on JSON
  (numbers parse as float) and gave {2,4} -> 2,4 copies instead of F1's 1,2. Ticket examples unchanged ({1,2} -> 1,2).
- Weight lookup now accepts StringName keys (LevelData.pieces.weights is Dictionary[StringName,int]) as well as String.
- Opening rng parts are ["spawn_open", part] (ticket text shows ["spawn_open"] for the first shuffle); deterministic either way.
- Pure: Seeds only, no Node/global RNG/time.
