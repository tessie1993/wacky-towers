# Contradictions resolved (C1–C12) and narrative flags

> **Status**: Draft v1 (narrative-director, 2026-10-10), for user review
> **Source**: `production/levels/meadow/world-and-scenes.md` §6. Rulings marked **(narrative)** are this role's call, pending user approval. Rulings marked **(endorse → owner)** are outside narrative's domain: this records the narrative view, the named owner decides.
> **Precedence used**: user decisions 2026-10-10 > `design/levels/meadow.md` > `biome-stories.md` > `biome-bible.md`.
> Nothing in other docs is edited here; the edits are listed in `meadow-story.md` §6 and below.

| # | Conflict (short) | Ruling | Why |
|---|---|---|---|
| C1 | biome-stories: the Miller "tosses mushrooms" and uses mushrooms in 10 | **(narrative)** meadow.md wins: 10 = belt + gust + flip. Mushrooms are puffed (spores from the bellows) in 04 only. Edit biome-stories mini-story line 3 ("toss" → "puff") and beat 10 ("gusts, belt and the big lever") | meadow.md is approved; one disturbance per level keeps 10 readable |
| C2 | biome-bible §2.2–2.10 casts and finales differ from biome-stories | **(narrative)** biome-stories wins (user decisions). Re-sync of the biome bible is deferred until after the Meadow MVP (world-builder + narrative) | No other biome is in MVP scope; re-syncing now is churn |
| C3 | biome-bible "Meadow critter" visits other biomes vs "mascots own their biomes" | **(narrative)** Strike the critter visitor lines. No mascot visits another biome except the Celestial finale. Cross-biome cameos are the **bosses'** job ("rivals return"), and the Miller returns as a friendly rival | Keeps each biome's identity; the user already decided this |
| C4 | Duck "under every island" vs meadow.md "01 and 02 only" | **(narrative)** Meadow: the collectible duck is in 01–02 only. Reword the gag to "**every biome** hides the duck in its first two levels" | Collectibles stay countable; the gag still runs every biome |
| C5 | biome-stories bonus: Pip in the basket dodging drops vs meadow.md ants and 60 s | **(narrative)** meadow.md wins: ants, 60 s, Pip sits on the lid. Edit the biome-stories bonus line | The ant line is the visible clock, so the story is the rule |
| C6 | Pip begs for "a bridge"; no Meadow level builds one | **(narrative)** Drop "a bridge". New list: "beds, a lookout, a bouquet and a packed basket" | Every item now maps to a level goal (tone rule 6) |
| C7 | level-data AC 9 says meadow_10 uses Spawned Objects | **(endorse → game-designer)** Update AC 9 to Conveyor + Wind + Gravity Flip | Matches C1 and the approved 10 recipe |
| C8 | level-data AC 11: every Meadow median 5–15 min | **(endorse → game-designer)** Exempt 01, 02, 06, 08, B. Narrative note: the short levels are the calm breathers in the story's pacing | The zig-zag is deliberate (meadow.md §5) |
| C9 | block-art-sets "gummy jelly" vs turf over soil | **(endorse → art-director)** Turf over soil. Narrative note: the drizzle "settles into meadow", which only reads with turf blocks | Lore and look agree |
| C10 | Lore keyed by catalog id, which maps few atoms | **(endorse → game-designer)** Key by module atom id, catalog id alongside | The recipes and JSON use atom ids |
| C11 | 02 "stone burrow" vs starter layers that clear like blocks | **(narrative + endorse → art-director)** The beds are made of yesterday's drizzle blocks, in the normal block look; stone is only the island body. Lore line: "last night's drizzle settled into beds" | "Anything that looks like a block is a block" (art bible) |
| C12 | layout.md: Pip's catch is WO06 with an old trigger | **(endorse → level-designer)** Use WO11 and meadow.md's trigger. Narrative: the catch reaction is Pip `exclaim` + catch pose, ≤ 300 ms, no skit | meadow.md is approved and newer |

## New conflicts from the 2026-10-10 user decisions

| # | Conflict | Ruling | Why |
|---|---|---|---|
| C13 | biome-stories tone rule 5: "bosses never join the party" vs the Miller joins the picnic | **User decision wins for the Meadow.** Scope for other bosses is open (hand-back Q1) | The user decided the Miller's redemption |
| C14 | meadow.md / world-and-scenes: the Miller "stomps off vowing a rematch" | Replaced by the revised 10 payoff (`meadow-story.md` §4); the fist-shake is kept as a fake-out and a friendly wink | Keeps the slapstick, adds the redemption |
| C15 | Tone rule 1 allows 3 words on cards vs "no words" | No words anywhere; icons only | User decision: wordless skits + emote bubbles |
| C16 | Tone rule 7 "it rains blocks, nobody explains" vs the wizard drops the blocks | The wizard casts the drizzle (visible wand glint at each spawn); *why* it is blocks stays unexplained | Both hold: the player is the cause, the absurdity stays |

## Narrative flags from world-and-scenes §6

| Flag | Ruling |
|---|---|
| **F1 Day cycle** | Recommend the **three-day** arc (postponed picnic, golden-hour finale). Cheaper fallback: one sunny day. User call (hand-back Q2) |
| **F3 Mill mechanisms** (bellows spores, chimney fog, flour-paste dew, lever rope) | **Approved** as story flavour. They keep "every disturbance from 03 comes from the mill" true, which the lonely thread needs (every prank is him reaching out) |
| **F4 The Miller's hidden blanket** | **Adopted and paid off**: seen from high angles in 10, it flutters down in the payoff and is what makes Pip understand. Also add it to the 05 spyglass view |
| F2, F5 | Not narrative (game-designer + tech-artist; tech lead) |
