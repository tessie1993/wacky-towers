# Credits and privacy note

> **Status**: Draft (ux-designer, 2026-10-10) · **MVP**: yes (user decision 2026-10-10: credits + privacy note are the only extra screens).
> Opens from **Settings → ⓘ Info** tab (settings.md). One screen, two sections (Credits, Privacy), a stack entry on the layer of whoever opened Settings (ADR-0016 §2). Look: [ui-theme.md](ui-theme.md). Values are tunable defaults.

These are the only text-heavy screens in the game. They are legal/info screens, so the wordless rule (P6) does not apply here; every line is still a translation key (ADR-0016 §9), except names, titles and licence texts, which are shown as written.

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Top bar | ◀ back · two tabs: ♥ Credits / 🛡 Privacy | Same |
| Body | Scrolling `PanelSheet`, Body 14 pt, H3 group headers | Same, max line width 640 pt, centred |
| Footer | Version `0.1.0` (Small 12 pt) | Same |

- No auto-scroll. Scroll by drag, mouse wheel, d-pad / stick, Page Up/Down. Focus moves header to header; each link-like line is a focusable row.
- No outbound links in the MVP (no browser opening): URLs are shown as text only, so a child cannot leave the app from here.
- Text scale 100/125/150% applies; lines wrap, nothing clips.

## Credits content (order)

1. **Game**: Wacky Towers, by Tessa (and the studio name when chosen).
2. **Music**: one track per level, supplied by the user; each track gets one entry in the attribution format below. Until the final tracks arrive, the placeholder is listed:
   - *"Carefree"* Kevin MacLeod (incompetech.com). Licensed under Creative Commons: By Attribution 4.0. creativecommons.org/licenses/by/4.0/
   - **CC-BY entries always carry title, author, source and licence (with link text)**. If a track was changed (cut, looped, remixed), the entry adds "changed: <what>". Remove "Carefree" when it leaves the build.
3. **Sound effects**: "Sound FX Starter Pack Vol. 1" (royalty-free; attribution only if its licence PDF asks for it; audio owner to confirm and fill in the exact line).
4. **Fonts**: Fredoka and Nunito (or the families finally picked, ui-theme.md §5), each with "SIL Open Font License 1.1" and its copyright line from `OFL.txt`.
5. **Engine**: "Made with Godot Engine" + Godot's MIT notice and third-party notices, **generated at runtime** from `Engine.get_license_text()` and `Engine.get_copyright_info()` so they never go out of date.
6. **Addons shipped in release builds**: GUIDE, phantom_camera, Orchestrator, beehave, GodotSteam (PC only), with the licence named in each `addons/<name>/LICENSE*`. Dev-only addons (gdUnit4, godot_ai, mcp toolkit, script-ide, formatter) are stripped from release exports and not listed.
7. **Placeholder 3D models** (generate_3d Pip/Miller): listed under "Placeholder art" until replaced; remove when replaced.
8. **Thanks**: playtesters (names only with permission).

A unit test fails the build if a file under `assets/audio/music/` has no matching credits entry (owner: audio; proposed).

## Privacy note (short, plain language)

Shown as short bullets (keys `UI_PRIVACY_*`), written for parents:

- Wacky Towers collects **no personal data**. There are **no ads, no analytics, no accounts** and nothing is sent to us.
- **Profile names, stars and settings stay on this device** (ADR-0013 §1).
- **Device backups**: Android may include the game's save in your Google device backup; Steam may sync it with Steam Cloud if you turn that on. Those copies are handled by Google or Valve under their own privacy policies. (Steam Cloud is not built yet; keep this line accurate to the shipped build.)
- **Local Wi-Fi play** (when it ships): talks only to other phones on your own network, never the internet (ADR-0009).
- **Deleting**: delete a profile in Profile select, or uninstall the game to remove everything.
- Contact: `[support e-mail to be decided]`.

The note must be re-checked whenever a network feature, SDK, or cloud save is added (monetisation is undecided; any SDK changes this text). Owner: producer.

## Edge cases

- **Opened from Pause**: allowed (board frozen); Back returns to Settings, then Pause.
- **Very long licence text** (Godot third-party list): collapsed under one "Engine licences ▸" row that expands in place.
- **Orientation change**: scroll position and focused row kept (ADR-0016 §4).

## Acceptance criteria

1. [I] Every music file in the build has a credits entry with title, author, source and licence; "Carefree" is listed while it ships.
2. [I] Engine notices come from `Engine.get_license_text()` at runtime, not a copied file.
3. [I] Keyboard-only and gamepad-only can scroll both sections to the end and get back.
4. [M] P and L at 150% text: nothing clipped, no line wider than the sheet.
5. [M] Privacy bullets match the shipped build (checked at each release gate).
