# Neon: Glowtown

Status: Proposed implementation design (2026-10-10). No Neon level design existed in the source repository. These ten levels are new proposals awaiting author review and playtest. They connect Clockwork to Celestial through Mizzle’s lonely billboard. All story plays wordlessly.

| Level | Name | Board | Goal | Rule | 2★ / 3★ |
|---|---|---|---|---|---|
| 01 | Welcome to Glowtown | 4×4, H8 | clear_n 3 | classic | 145 / 105 s |
| 02 | Traffic Lights | 5×5, H10 | clear_n 4 | stopwatch | 260 / 185 s |
| 03 | Moving Sidewalk | 8×4, H10 | clear_n 4 | conveyor | 310 / 220 s |
| 04 | Looking Glass Arcade | 6×6, H10 | clear_n 4 | mirror | 340 / 240 s |
| 05 | Cloud Nine Sign | 5×5, H12 | height 9 | build_race | 260 / 185 s |
| 06 | Pixel Picture | 4×4, H6 | shape 40 cells | fill_shape | 80000 / 55000 s |
| 07 | Neon Shower | 6×6, H10 | clear_n 5 | bubble | 360 / 255 s |
| 08 | Rush Hour | 5×5, H10 | survive 150 | stopwatch | 240 / 170 s |
| 09 | Power Surge | 6×6, H12 | clear_n 5 | turntable, gust | 410 / 290 s |
| 10 | The Lonely Billboard | 7×7, H14 | clear_n 4 | conveyor, mirror, gust | 390 / 275 s |

Each level keeps one legible new idea, then remixes familiar ones. Level 05 offers a trim tower breather; 06 is an eight-piece stepped neon-sign puzzle; 08 is a timed sprint. Level 10 lights an empty second chair beside Mizzle’s billboard and points toward the final island. Art is a bright toy city with violet dusk, painted signposts and cyan/peach accents; no flashing effects. Track ids mus_neon_01–10 are user-supplied placeholders. Stars are initial estimates, not tuned medians. Local physics use existing deterministic grid rules.
