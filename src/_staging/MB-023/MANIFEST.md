# MB-023 / CH-088 ScoreKeeper, CH-087 StarRater (+ LevelResult value type)
Paths relative to src/ (stage mirrors final path under _staging/MB-023/src/). All NEW.
- core/sim/score_keeper.gd, core/sim/star_rater.gd, core/model/level_result.gd (ADR-0010 type; did not exist yet; StarRater and BoardSim need it)

Deviations
- StarRater relaxed scale is 1500 milli (onboarding-accessibility F1 `relaxed_time_scale` 1.5, round5), not the ticket's 2.0. Optional 3rd arg overrides; knob `relaxed_time_scale` is not in assets/data/knobs yet.
- ScoreKeeper: `on_place(cubes=1)` and `on_clear(layers, round, active_cells=64)` have extra optional args (F2 needs A, F3 is per cube). Combo counts once per `on_clear` call, so the sim calls it once per lock. No obstacle points, no survive stars (not in the tickets).

See it working (editor script eval)
- `ScoreKeeper.new({})`: on_clear(1,1) = 100; then on_clear(2,1) = 300 + 50 = 350 (combo 2, total 450); reset_combo() -> combo() == 0. Fresh keeper on_clear(2,1,36) = 169. F3 example: on_place(4) + on_drop(9,true) + third consecutive on_clear(1,1) = 4 + 18 + 100 + 100 = 222.
- `StarRater` with {t2:145000,t3:105000}: won 100000 ms 0 warnings -> 3; 1 warning -> 2; 200000 -> 1; lost -> 0. Relaxed: star_times = (220000, 160000); won 200000 ms -> 2; 150000 ms 0 warnings -> 3.
