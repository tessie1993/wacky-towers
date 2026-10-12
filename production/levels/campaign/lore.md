# Campaign lore and canon ledger

Implementation companion, 2026-10-10. This reconciles the authored narrative with the running wordless game; it does not supersede the source GDD. World-builder and level-designer guidance from `.claude/agents/` was applied to source consistency, geography and environmental staging. The user authorized implementation and this production artifact through the orchestrated build.

## The invitation

| Entry | Canon level | Player visibility | Established source | Contradictions check |
|---|---|---|---|---|
| A floating toy archipelago holds small, familiar communities, each tending a local resource or craft. | Established | Yes | `production/levels/campaign/biome-stories.md`; `production/narrative/campaign-story/visual-direction.md` | Regional cultures remain distinct; no invented war, currency or faction hierarchy. |
| Cloud helps neighbours by arranging the same chunky blocks into whatever they need. | Established | Yes | `design/gdd/game-concept.md`; `design/gdd/narrative/meadow-story.md` | Puzzle rules stay authored level data; props never add collision or goals to grid play. |
| Mizzle is shy and lonely. His strange parcels are attempts to invite everyone to a party, misread as pranks. | Established | Discoverable | `production/narrative/campaign-story/brief.md` | He is not an evil antagonist. The world never punishes his loneliness. |
| A violet ten-panel flag is an invitation assembled across the journey. | Established | Discoverable | `production/narrative/campaign-story/brief.md`; `dialogue-campaign-skits.md` | Flag clues are visual props, not an invented gameplay collectathon. |
| Meadow's Miller begins lonely and angry, then understands an invitation and joins the picnic. | Established | Yes | `design/gdd/narrative/meadow-story.md` | Later older outlines about malicious boss stomps yield to the picnic payoff. |
| Lana joins through Ice, Boulder through Lava, Glim through Cave. All four playable friends are available to multiplayer. | Established | Yes | `design/gdd/characters-perks.md`; `design/gdd/shop.md` | Friends are not sold or renamed. Their regional origin does not prohibit travelling with the player. |
| Nine earlier bosses attend the Celestial grand finale; other biome mascots do not appear as guests in earlier regional scenes. | Established | Yes, finale | Build steering; `dialogue-campaign-skits.md` | Earlier guest appearances are removed. Lava's older Miller handoff is conveyed by Cloud and the invitation prop instead of a foreign boss cameo. |
| The invitation is finally understood. Cloud offers Mizzle a chair and the communities share a party. | Established | Yes | `production/narrative/campaign-story/brief.md` | Mizzle is included, not defeated or humiliated. A six-second first-view finale preserves the hat, invitation, chair and reunion; replay keeps two final beats. |
| Quiet rim furniture and original procedural toy forms are the present art realization. | Provisional | Yes | `src/view/wt_stage.gd`; `wt_toy_actor.gd`; `tools/content/generate_stories.py` | They are original source geometry, not the promised final painted/rigged art library. |

## Regions and daily life

| Region | Mascot / local boss | Ecology and craft | Environmental story | Invitation clue |
|---|---|---|---|---|
| Meadow | Pip the harvest mouse / Miller the badger | Gardens, seed baskets, windmill flour, dew and mushrooms | A useful first block grows into a neighbourly picnic. Morning, bedtime, wind, dawn fog and golden picnic light follow the individual level arc. | Miller's single chair and hidden invitation reveal loneliness. |
| Candy | Mallow the bunny / Meringue | Cake, bakery windows and soft sugar props | Baking and deliveries turn squashing and colour matching into helpful work. | The violet hat and gift appear at the bakery edge. |
| Ice | Pebble the penguin / Sniffles the yeti | Snow, ice, egg care and wool | Keeping neighbours warm and protecting an egg welcomes Lana. | Snow chairs have an empty guest place. |
| Underwater | Puff the pufferfish / Crab | Coral, pearls, currents and bubbles | Pearl gathering and careful delivery make the water community legible. | An invitation and a distant observer peek into the current. |
| Lava | Cinder the salamander / Smolder the dragon | Warm stone, embers and heavy tools | Useful warmth, cooling and bridges welcome Boulder. | Violet parcels and the invitation suggest preparation, never arson. |
| Forest | Chip the beaver / Oak | Acorns, leaves, timber bridges and flowers | Repair and pollination make stacking a practical kindness. | Mizzle finally offers an acorn or a careful cube. |
| Cave | Nugget the mole / Geode | Lanterns, gentle crystal forms and blueprint work | Lighting and repairing a sheltered work space welcome Glim. | Mizzle catches a small wobbling tower and sighs. No painful collapse or tear follows that clue. |
| Clockwork | Tock the duck / Cuckoo | Gears, clocks, keyholes and arranged tables | Winding and timing make a busy workshop useful to its residents. | An empty table waits for its twelve guests. |
| Neon | Glitch the cat / Mirrorball | Music, dance shapes and quiet crystal-like set dressing | Rhythm becomes an exchange rather than a demand for perfection. | A clean cube and a small returning glint encourage Mizzle. |
| Celestial | Comet the fox / Moon | Stars, moon keepsakes and sky furniture | The hat-shaped venue and assembled invitation bring everyone together. | The empty chair is offered to Mizzle. |

## World rules and presentation boundaries

The block is constant; local rules reinterpret its use. The diorama reads authoritative board state and never writes gameplay cells. Mascots and bosses occupy the quiet rim, at least one cell away from the active grid. Warning markers, exact landing ghosts, colour-blind codes and stamped key faces belong to the game board and remain stronger than background decoration.

The campaign says nothing about realistic economics, borders, hereditary rule or cosmological warfare. Those facts remain unestablished. Real Jolt physics is a separate challenge family, not an explanation that changes the deterministic grid fiction.

## Source priority and conflicts

1. Current user steering and accepted build decisions.
2. Canonical Meadow story and final campaign dialogue revisions.
3. Campaign brief and visual direction.
4. Older ten-beat biome outlines.
5. Original implementation staging, always marked as an interpretation.

The older brief's fourteen-second Celestial reunion is compressed to six seconds by current steering. Cave's older falling tower is replaced with the later gentle catch and sigh. Cross-region guest cameos yield to the finale-only guest rule. The first-view Ice/Lava/Cave friendship join adds its separately authored four-second unlock vignette after the regional six-second payoff. No new player-facing prose is introduced.

Cross-references: [visual direction](visual-direction.md), [design reconciliation](../../../design/implementation/design-reconciliation.md), [as-built game](../../../docs/architecture/as-built-game.md), `assets/data/story/campaign_skits.json`.
