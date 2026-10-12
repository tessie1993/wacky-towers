# Narrative: index and rules

> **Status**: Draft v1 (narrative-director, 2026-10-10), for user review
> **Scope**: Meadow MVP (01–10, bonus; H1–H3 brief). Later biomes stay in `production/levels/campaign/biome-stories.md`.
> **Binding user decisions (2026-10-10)**: the player is **the cloud wizard**; the story is told by **wordless skits + emote bubbles**; **the Miller is secretly lonely** and gets a small redemption at the end of the Meadow.
> **Every name, beat and timing here is a tunable default.**

## Files

| File | What it holds |
|---|---|
| `characters.md` | The cloud wizard, Pip, the Miller, the meadow friends: role, want, personality, silhouette, emotes |
| `meadow-story.md` | The Meadow arc beat by beat, the Miller's lonely thread, the keepsake, and a per-level skit brief for the writer |
| `emote-bubbles.md` | The shared emote set (ids, meaning, who uses them) |
| `contradictions-resolved.md` | Rulings on C1–C12 from `production/levels/meadow/world-and-scenes.md` §6, plus the narrative flags F1, F3, F4 |

Source of truth for rules, numbers and level beats: `design/levels/meadow.md`. Where this folder changes a beat (the 10 payoff, the lonely thread), the change is listed under "Proposed changes to other docs" and is not applied until approved.

## Tone rules (Meadow)

1. **No words. Ever.** No text in skits, bubbles or story cards. Icons, poses, props and light carry everything. (Stricter than biome-stories rule 1, which allowed 3 words.)
2. **Never in the way.** A skit never costs play time and is always skippable with one tap. The game concept's "no story campaign" anti-pillar holds: a player who ignores the story loses nothing.
3. **Failure is a gag.** Nobody is hurt, only bonked, floured, stuck or rained on (the grumpy cloud).
4. **The Miller is a prankster, not a villain.** He is smug on the surface and lonely underneath. His clues are small and optional; a player who misses them still gets a happy ending.
5. **One disturbance near the board.** Story motion near the grid never competes with the level's single disturbance (meadow.md "gentle weather"). Story lives at the rim and in the backdrop.
6. **The wizard is you.** The wizard never acts against the player's input. It reacts to what the player did, and the friends react to the wizard.

## How the story shows up in play

| Channel | When | Length | Rules |
|---|---|---|---|
| **Intro skit** | During the Countdown (`countdown_ms` 3 000) | ≤ 3 s | Shows the level's problem. Ends with the **hand-off**: Pip looks up at the wizard with a bubble, the wizard's wand glints, the first piece spawns. No play time is lost |
| **Payoff skit** | On a win, before the results card | ≤ 5 s, tap to skip | The tiny story resolves. In 03–10 it carries the Miller's clue for that level, in the backdrop |
| **Reactions** | On board events (clear, warning, catch, trim, gust, flip...) | ≤ 1 s each | An emote bubble plus a pose on Pip, the wizard or the Miller. One reaction at a time per character; see `emote-bubbles.md` |
| **Backdrop** | Always | ambient | The mill gets closer across the biome; the light tells the day (see `meadow-story.md` §1); the Miller's silhouette from 03 |
| **Island map** | Menu | ambient | The cloud wizard floats over the 10 islands. Each won island keeps its payoff prop (the sunflower, the bouquet...). After 10, the Miller is on the map too, at the picnic |

**Skip and repeat.** Payoff skits play in full the first time, then shortened (the last beat only) on replays. Intro skits always play, because they sit inside the countdown.

**Reduced motion** (accessibility MVP): bubbles appear without bounce; skits keep their poses but drop camera moves and shakes.
