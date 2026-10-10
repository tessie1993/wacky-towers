# Open cross-doc conflicts (collected 2026-10-10, wave 2)
## ADR fixes (technical-director)
✅ 1. DATA LOSS: ADR-0013 §6 — unreadable index.json makes boot cleanup delete all 4 profile folders. Fix: skip cleanup, rebuild index from slot files (see design/gdd/ux/loading-and-save-error.md).
✅ 2. Gamepad shoulders: ADR-0014 View vs ADR-0012 Turn. Proposal: View on right stick.
✅ 3. (ADRs, ACC-41, meadow.md done; still stale: implementation-plan MDW-009, world-and-scenes EV03, scene-build-sheets 09 — outside my scope) Stack flip (island stays): ADR-0011 §5 still "islet turns", `flip_applied {axis}`; RuleApi needs a queued stack-flip request at S4a (ADR-0004 §7). Also implementation-plan MDW-009, ACC-41, world-and-scenes EV03, scene-build-sheets 09, meadow.md 09/10 diagrams.
✅ 4. Level paths: ADR-0005 assets/data/levels + scenes/levels vs ADR-0011/0017 src/levels/<biome>/<id>/.
✅ 5. Conveyor rule id `mill_belt` (ADR-0011) → biome-neutral `conveyor`?
✅ 6. M11 Pair Clear needs two boards; ADR-0004 = one RuleRuntime per board.
✅ 7. ADR-0015 forbids view sounds; camera rig must emit SFX_CAM_SETTLE (ADR-0014/0015).
✅ 8. Beehave debugger autoload strip breaks trees (ADR-0011 verification 1).
✅ 9. BL19 wrap hook (ADR-0002), FT12 undo/reset commands (ADR-0001), CV17 clear check after twist without lock (ADR-0011 §3).
✅ 10. Button squash 80 ms (interaction-patterns P2, ADR-0016 §8) vs decision 150–250 ms.
## GDD / data fixes (designers)
11. ✅ piece_locked event lacks holes_added (fall-drop-lock) — mascot reactions need it. (ADR-0001 event list should name the field.)
12. ✅ Framework closed knob list needs skill.charge_rate, item_slots; registry entities.yaml additions (skill_rule, edge_cap, C1–C4, currency, potion ids); atom_tags.json new tags. (atom_tags.json did not exist — created; new tag `stack`.)
13. "points" name clash with in-level score — pick a player-facing currency name.
14. ✅ Skills GDD C2–C4 placeholder skills → replace with story friends: Lana/Stitch, Boulder/Smash, Glim/Redraw. NEW for technical-director: framework rule 11a `veto_rank_bonus` (Stitch) needs ADR-0004 schema field.
15. ✅ art-bible §7 frame table predates painted wood. ux/hud.md + interaction-patterns P8 lack Roll, old rot ids. island-map.md needs profile chip. (title.md chip still open; Roll keys T/G pending user.)
16. ✅ systems-index rows stale (#30–37 + all revised docs). Level-maker dock row #39 added.
17. PARTIAL: Bidirectional dependency notes — done: framework, fall-drop-lock↔mascot. STILL OPEN: buffs, items, level data, scoring, tournament flow, gdd/hud.md, level goals.
- Extra decisions: ✅ 10c/10d renumbered; ✅ versus exact tie = split win (level-goals; tournament-flow both-get-points NOT yet written; ADR-0009 §5 conflicts); ✅ story unlocks Lana/Ice, Boulder/Lava, Glim/Cave (characters-perks). OPEN: ambience under SFX slider (ux/settings.md, audio.md); critter sounds yes (sfx-cue-list / mascot-reactions OQ5).
## User questions pending
- Participation points for tournament finishers? Potion use still allows ★★★? Buyable characters? Potions in quick versus (default OFF)? Edge perks in Arcade (default ON)?
- Critter sounds? Ambience 4th slider? Which Meadow levels get own tracks?
- Support e-mail for privacy note; Roll keys T/G; new atom bundles + "Secrets count 0".
18. Commit hook still demands 8 GDD sections for design/gdd/{ux,audio,narrative}/ + atom/asset lists — user chose to relax that rule (update the validation hook).
## From core GDD revision (2A-1)
✅ 19. assets/data/knobs/rules.json `rules.layer_order` has old 5 layers → replace with rule_layers.json (ADR-0011).
✅ 20. Knob JSON missing `control.kick_off_axis`, camera `settle_ms`; `view.yaw_offset_deg` stores 15 vs 45 in GDD/ADR-0014.
✅ 21. ADR-0002 lacks a RESCUE cause for rescue-wipe board changes.
22. level-goals-fail-states has two rules labelled 10c (user's edit?) — confirm with user.
✅ 23. (user: same-tick = split win, both get round points; ADR-0009 §5 amended) Versus goal ties now follow ADR-0009 (lower round clock, then first message at host) — drops "more layers cleared" tie-break; confirm with user.
## From build task list
24. SimCommand/SimEvent defined twice (src/core/model + src/core/sim) — code fix MB-008, not a doc.
## Leftovers after GDD fix pass (low priority, docs only)
25. Item 17 dependency notes still missing in buffs-debuffs, items, level-data, scoring-stars, tournament-flow, hud, level-goals.
26. tournament-flow: tie = both players get the points; settings.md + audio.md: ambience under SFX; critter sounds in audio.md; title.md profile chip; Roll keys T/G (user).
27. ADR-0004 schema needs framework rule 11a `veto_rank_bonus` (Stitch blocks twists); ADR-0001 event list should name `holes_added`; re-check ADR-0009 §5 vs split-win tie.
## Level-spec follow-ups (reconcile after all biomes are written)
28. Lava: new atom needed `active_after_clears` (rule gate dormant until N clears; finale phases). EV06 needs a campaign form (rising lava) in its GDD. Light tables differ between visual-direction and lore-world (followed visual-direction). Open rules Qs in design/levels/lava.md §10.
29. Biomes are written in parallel → "new to the player" atom counts assume only Meadow is known; run one cross-biome pass for the novelty budget once all are done.
30. Ice: new atom SP41 Rolling snowball (rolls 1 cell along slope_dir every roll_locks, grows to snow_max, parks when blocked) needs an owning-GDD write-up; EV09 + BL12 knobs defined in ice.md; lore vs skits clue-slot mismatch (followed skits); AR02 finale portrait risk.
31. Forest: new atom "Squirrel Heist" (provisional EV25; steals 1 exposed cube from fullest unfinished layer every few locks, telegraphed, cancelled by clearing/covering); EV04 `place_mode: lowest`; BL17 semantics ambiguous; followed LORE light split (others followed visual-direction).
32. Candy: new atoms Syrup band (prov. EV25 — CLASHES with Forest), Gummy cascade (CO10), Tier frosting (SC13), Bake 2-stage (BL21), Climber boss (prov. SP41 — CLASHES with Ice snowball), Bonk the boss (GO31); spawner flavour source; GO03 colour-target param; stars counted in tiers/clears. 09 tilt camera undefined; 10 budget depends on BL21 owning stage goals.
33. ATOM ID PASS NEEDED: assign final ids to all new atoms from every biome file, add them to mechanics-module.md as Proposed, then fix ids in design/levels/*.md.
34. Underwater: Crab's Claw EV16 biome event needs rule JSON; SP35/EV07/GO08+SP11 Candidate rules needed; Stitch vetoes stack rules on 08–10 → decide skill_immune; AR02 + BL11 need Board/Grid checks; followed LORE lighting.
35. MB-022 RescueTopOut reads margin via api.knob(); live RuleApi._knobs unguarded → crash if RuleApi built with null knobs. Fix at integration: guard RuleApi.knob() or build api with KnobRegistry.
