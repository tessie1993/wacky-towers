# Content and meta verification — 2026-10-10

Godot4.7.2 stable, local headless gdUnit4, per the production QA authorization. Executable wrapper: `../tools/bin/godot`.

| Evidence | Result |
|---|---|
| Meta suite, `reports/content-meta/report_5/results.xml` | 12/12, zero errors/failures/skips/orphans, 762ms. |
| Assets/palette/biome/meta, `reports/content-assets/report_1/results.xml` | 27/27, zero errors/failures/skips/orphans, 763ms. |
| Trusted catalog/official files | 118/118 structurally valid;100 mains,18 extras. |
| Source feature coverage | 73 eligible for playtest;45 gameplay-blocked.69 eligible mains. |

Tests read real official JSON and real imported block meshes, use isolated MemorySaveIO profiles, and exercise checksum-valid disk backup recovery/newer-schema write protection in a disposable `user://meta_tests` folder. No real user profile directory is deleted by the test.

The full suite first exposed incomplete Candy hue coverage and an art-set path that named an absent model directory. The Candy palette now covers stable hue ids0–10; biome art references point to actual live Candy Toy models. The existing Neon Mono contains exactly one authored cube mesh. Its mesh node was exposed as a standalone cube GLB without changing binary mesh bytes, imported with the same post-import flags, and saved as the matching Mesh `.res`. `tools/asset-pipeline/derive_neon_cube.py` and `extract_neon_cube.gd` reproduce the repair. No asset assertion was weakened.

Coverage is not a tuning claim. Original source specs are preserved, unsupported gameplay is explicit and the application must disable those entries. Cave07, Cave bonus and Celestial bonus have insufficient finite piece volume; they remain blocked pending an authored specification correction. Remaining fixed puzzles need solution replay/placement checks. Mobile recovery, storage-full errors, interrupted process tests, profile migration beyond schema1 and performance timing on the reference phone remain unmeasured.

See `docs/architecture/content-meta-runtime.md` for the public API and boundaries, and `assets/data/campaign/implementation_coverage.json` for every source issue. Full-suite validation is coordinated separately by the core integration owner.
