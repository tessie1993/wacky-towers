# Shared look, round 1: world builder review (blind)

Reviewer speciality: world building (sense of place, block-to-world fit, board-to-scene fit, backdrop support).
Method: viewed lighting-v1 after_contact.png and before_contact.png, after/biome_underwater.png and after/biome_lava.png at full size, blocks-v4/ingame_vs_ref13_set.png, and reference board style/15_title_and_hud.png. I did not open every per-biome frame at full size; the 12-up contact sheet carries most of the per-biome judgments, and any point I could not confirm at full size is marked as contact-sheet only.

## Scoreboard

| Item | Score | Why it is not higher |
|---|---|---|
| A1 Lighting mood and shading | 7.0 | Biome grading now reads (lava red, night blue, ice cool). Black unlit silhouettes remain, and there is no directional sun or rim, so the islands lack the volume of board 15. |
| A2 Colour and value hierarchy | 7.0 | Blocks are dark on a light board in most biomes, so the stack reads. Pirate, clockwork, cave, celestial and neon blocks all collapse to near-black navy with a starfield. Backdrops and floors compete at mid-value. |
| A3 Block material quality | 6.5 | blocks-v4 shows tinted, rimmed blocks that vary per biome. The lighting-v1 after frames show most biomes' blocks as near-identical dark crystal cubes. Board 13 and board 15 have bright, saturated, themed blocks (grass-topped, jelly, wood). |
| A4 Post finish | 7.5 | The after set has bloom, vignette and grade. The contact sheet is cleaner and more cohesive than the before set. Some blown or banded highlights remain (lava vents, neon tower), and the flat grid overlay is still visible. |
| A5 Per-biome identity | 6.0 | Silhouette props and palette differ. The backdrop recipe, floor and satellite islands are shared, so places feel like recolours. |
| A6 Overall screen quality | 6.5 | Cohesive, but not at the level where it passes next to board 15. |

Caps applied: open visible defects cap everything at 8.5. Blocks-v4 captures pre-date the lighting pass, which caps A3 as stale for the blocks-in-final-lighting claim. Nothing is scored above 8.

## Ranked defects

1. **Black unlit set pieces.** The lava smoke plume and volcano base are flat black silhouettes (lighting-v1/after/biome_lava.png, right of board). The pirate wreck is a near-black block with only a few lit dots (lighting-v1/after/biome_underwater.png, right-hand island). Both are very noticeable. They read as missing materials, not as shadow. Board 15 has no black masses.
2. **Backdrop recipe repeated across biomes.** Pale grey-pink mesa pillars on a flat haze appear in candy, carnival, pirate, underwater and clockwork (lighting-v1/after_contact.png, top row cols 1, 2, 5 and bottom row cols 5, 6). Underwater shows the same mesas with no water: no caustics, no surface, no depth fog, so the biome does not read as underwater (lighting-v1/after/biome_underwater.png). Board 15 gives each biome its own panorama (waterfalls and cliffs for meadow, a castle in snow, a nebula for celestial).
3. **Shared satellite islands.** The same green forest island and snow-castle island float in the upper corners of meadow, candy, carnival, clockwork, forest, ice, pirate and underwater (lighting-v1/after_contact.png). They do not belong in a lava or underwater place, and they weaken the sense of place.
4. **Block colours do not belong to their world.** Pirate, clockwork, neon, celestial and cave blocks are all dark-navy cubes with starfield faces and only a thin tint change (lighting-v1/after_contact.png, top row cols 3 and 4, bottom row cols 4 and 5). Ref 13 sets wood, jelly, cracked stone with lava, and gold-and-navy gears (blocks-v4/ingame_vs_ref13_set.png, left column). The blocks-v4 in-game column was closer, with themed colour rotation. It was captured before lighting, so it cannot be treated as the current state.
5. **Board floors are the same beige tile.** Meadow, forest, pirate, clockwork and carnival share a near-identical cream or stone checker (lighting-v1/after_contact.png). Only candy, ice, lava and neon change the floor. Pirate should be planks, clockwork brass plate, forest packed earth and moss. The underwater floor is grey slab with no water cue (lighting-v1/after/biome_underwater.png).
6. **Flat isometric wireframe grid is visible behind the board in every biome** (lighting-v1/after/biome_lava.png, background lines). It breaks believability and has no in-world explanation.
7. **Time of day and lighting direction.** There is no consistent key light, cast shadow or rim on the island sides. Dusk, noon and night read only through the tint (lighting-v1/after_contact.png). Reference 15 has a sun side and a shadow side (style/15_title_and_hud.png, meadow and ice).
8. **Board-to-island integration.** Candy, meadow and ice islands carry rim props and match the references. Pirate, clockwork and cave rims are sparse or dark, and the board looks placed on top of the island, not set into it.

## Concrete fixes and owners

| # | Fix | Owner |
|---|---|---|
| 1 | Give the smoke plume and wreck lit materials with emission, albedo and ambient fill; no pure-black meshes | world / props maker, technical artist |
| 2 | Per-biome backdrop: underwater gets surface light shafts, caustics, depth fog and kelp or coral spires; lava gets a lava sea and ash sky; pirate gets a sea horizon; candy gets a sweet-hill panorama | world maker, art director |
| 3 | Filter satellite islands by biome (lava rock for lava, coral for underwater, clouds for celestial) | world maker |
| 4 | Re-capture blocks after the lighting pass. Push per-biome base colours and top-cap materials toward ref 13 (wood and moss, jelly, brass gears) | blocks maker |
| 5 | Biome-specific floor materials | world maker |
| 6 | Remove or fade the grid wireframe, or theme it per biome | technical artist |
| 7 | Add a key directional light with a visible shadow side and a rim per biome; document the time of day in the art bible | technical artist, art director |
| 8 | Add rim props and a bevelled inset so the board sits inside the island | world maker |
| 9 | Capture a fresh full-size set after fixes, including a same-lighting blocks stack per biome | all makers |

## Notes for the orchestrator

- The lighting pass is a real improvement over before_contact.png: the before set has washed-out beige and grey haze, and the after set has biome grading. That is not a score.
- Lore note for the narrative-director: the shared satellite island set contradicts the idea of 12 distinct places. If it is intentional ("same sky, different islands"), document it in the art bible as a deliberate choice.
