# Awesome-gamedev and awesome-godot: full pass

> **Date**: 2026-10-10
> **Sources**: `Calinou/awesome-gamedev` README (every section read) and `godotengine/awesome-godot` README (every section read).
> **Checked**: repo licence, last push and archived flag via `gh api` on 2026-10-10. Items marked *(memory)* come from the author's knowledge or a site licence page, not a repo check.
> **Not repeated**: the previous pass already adopted gdUnit4, godot-ci, Kenney CC0, rFXGen/jsfxr, kenyoni QR and webrtc-native, and rejected godot-jolt, netfox and float noise in the sim. They appear below only as one-line pointers.
> **Rule used**: only CC0, CC-BY, public domain and permissive code licences (MIT, BSD, zlib, Apache, Unlicense, OFL for fonts) are usable in a commercial phone game. NC, SA, GPL and AGPL content or code shipped in the game is **not usable**. GPL *tools* are fine, because their output is ours.

Verdicts: **Adopt** (use it), **Evaluate** (try it when the need arrives), **Reference** (read it or use it for ideas, ship nothing), **Skip**.

## 0. Findings that need attention

1. **The .NET version for Android is not simply "8 or 9".** The 4.7 docs (`c_sharp_basics.rst`, branch `4.7`) say: "Godot 4.5 requires .NET 8 or later, but exporting to Android requires .NET 9 or later." The `master` (4.8) docs say "Godot 4.8 requires .NET 10 or later." Both the basics page and the Android export page still call C# on Android **experimental** (supported since 4.2, "some limitations apply"). Plan: install the .NET 9 SDK now, expect .NET 10 when we move to 4.8. The 4.7 sentence mentions 4.5, so it may be stale. Re-check it against the real 4.7.2 editor.
2. **Starship Olympics** (the closest party-arena game on the list) is licensed **CC BY-NC-SA 2.0**. Not usable. Ideas only, and we do not copy its arenas, art or code.
3. **FluentAssertions** now ships an Xceed Community License, which is not a plain open-source licence. Skip it. Shouldly (BSD-3) is the safe alternative.
4. The AdMob plugin on the awesome-godot list (`poing-studios/godot-admob-android`) is **archived**. A maintained one lives under `godot-sdk-integrations/godot-admob` (licence not checked). We do not plan ads anyway.
5. **PowerKey** (translation helper) is archived. **Godot Mixing Desk**, **godot-lod** and **GodotRx** are stale. All skipped.
6. **gdquest-demos/godot-shaders**: its art assets are CC-BY-NC-SA 4.0. Do not import its textures or models.

## 1. Open-source games to mine for mechanics

The licence column is the code and asset licence from the list or repo. None of these ship in our game, so the licence only matters for "do not copy files". Rules are ideas and are not copyrightable, but we write our own versions.

| Name | URL | Category | Licence | Use | Verdict |
|---|---|---|---|---|---|
| Librerama | https://codeberg.org/Librerama/librerama | Party / micro-games (Godot 4.6, active Sep 2026) | Free/libre (repo licence not checked) | 5-second "nanogames" chained with rising speed. Its wiki documents how to author a nanogame, useful for our minigame scene contract | Reference |
| Super Tux Party | https://gitlab.com/SuperTuxParty/SuperTuxParty | Party game (Godot 4, active Jul 2026) | GPL (code, per list) | Mario Party style: minigame rounds, awards, items | Reference |
| Starship Olympics | https://github.com/notapixelstudio/starship-olympics | Local party arena (Godot 3) | CC BY-NC-SA 2.0, **not usable** | Short arena rounds with score zones | Reference (ideas only) |
| Hurry Curry! | https://hurrycurry.org | Co-op party (Godot 4) | AGPL-3.0 only | Orders with patience. Co-op atoms are parked in our module | Reference |
| ROTA | https://github.com/HarmonyHoney/ROTA | Gravity-bending puzzle (Godot 3, 2026-06) | MIT | Player-triggered 90 degree world rotation | Reference |
| Flappy Race | https://github.com/Jibby-Games/Flappy-Race | Online race (Godot 3) | MIT | Ghost opponents on a shared course, lobby flow | Reference |
| DynaDungeons | https://github.com/akien-mga/dynadungeons | Bomberman clone (Godot 2) | GPLv3 code, CC assets | Bomb chains, pickups from broken blocks | Reference |
| Wizznic | list: C games | Puzznic-style block puzzle | GPLv3 (code and assets) | Slide a block one cell, touching same colours vanish, lifts. *(memory of the Puzznic genre, repo not read)* | Reference |
| The Powder Toy | list: C++ games | Falling-sand physics | GPLv3 | Granular and liquid fill rules | Reference |
| Blockrain.js | https://github.com/Aerolab/blockrain.js | Tetris in JS (last push 2018) | MIT | Plain falling-piece baseline. Nothing new | Skip |
| BlockPop, Breakable, Three Hungry Mice | awesome-godot, 2D Godot 2 and 3 | Breakout clones | see repos | A ball that breaks cells | Reference |
| osu! | list: C# games | Rhythm | MIT | On-beat timing windows and a judgement ladder | Reference |
| PuzzleScript | list: HTML5 engines | Puzzle rule prototyping language | MIT | Prototype atom rules as rewrite rules in a browser before coding | Evaluate |
| Free Hero Mesh | list: Engines | Grid puzzle engine | Public domain | Pushable-object rule sets | Reference |
| 2048, Prism, Zop, Parity | list: ECMAScript | Merge and colour games | MIT (code) | Merge (we have CL12) and colour links | Skip (covered) |
| Pop Pop Win, Drunken Viking, Ned et les maki | list: Dart, ECMAScript, Java | Minor puzzles | BSD / MIT, assets vary | Hint numbers, slide rules. Nothing we lack | Skip |
| Minetest, Terasology, Craft, Blackvoxel | list | Voxel sandboxes | LGPL / Apache / MIT code, CC-BY-SA assets | Dig is the only overlap, and we have it (GO21) | Skip |
| Wesnoth, Mindustry, Unciv, Teeworlds and other strategy/shooter entries | list | Strategy, shooters | GPL mostly | No fit | Skip |

## 2. New mechanic atoms suggested from open-source games

Format follows `design/gdd/mechanics-module.md`: `| ID | Atom | One line | From | Tags | Cost | Status |`. IDs continue after the current highest in each slot (EV16, CV13, CO07, SP33, SC08, GO22). Status **C** = Candidate. These are proposals for the game-designer, not edits to the module. Two atoms (SC10, GO24) overlap existing ones and say so.

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| EV17 | Lift tiles | A few floor cells rise and sink on a short cycle, so the same drop lands one cell higher or lower depending on timing. The tile is marked and bobs | Puzznic / Wizznic lifts *(memory)* | grid fall | M | C |
| EV18 | Nanogame interlude | Every N pieces the board freezes for a 5-second one-tap challenge (tap the bobbing bubble, stop the spinner). Win it and the next piece is a free pick; lose it and nothing happens | Librerama | grid | M | C |
| CV14 | Tilt charges | The player owns 1 to 3 charges per level. Spending one rotates the down axis 90 degrees for the current piece only | ROTA | grid fall | M | C |
| CO08 | Pour | A "liquid" piece does not lock as a solid. It spreads sideways and down to fill the lowest open cells, then sets as a flat layer | The Powder Toy | grid fall | M | C |
| SP34 | Bouncy ball | A ball bounces inside the tower for a few seconds and pops jelly cells it touches. Physics boards only; it ends when it leaves the board | Breakout clones | phys | L | C |
| SP35 | Pickup crate | A block marked with a bow breaks (chisel, bomb or clear) into a pickup the next piece carries: a size-1 bonus cell or one free rotation. Overlaps SP04 and SP11; this is the carrier, not the reward | DynaDungeons | grid | S | C |
| SC09 | Party awards | At the end of a round, three silly awards (Tidiest Tower, Most Bonks, Comeback Kid) each give fixed points to the winner. Rewards style over raw score and pairs with SC06 | Super Tux Party | grid | S | C |
| SC10 | On-beat lock | Locking a piece inside the beat window grants a small bonus and a visible pulse. Overlaps EV08, which sets the tempo; this is only the scoring half | osu! | grid fall | S | C |
| GO23 | Slide-clear | Clear the whole board using at most M cell-slides. A Puzznic-style move-budget puzzle on top of CV09 | Wizznic *(memory)* | grid nofall | M | C |
| GO24 | Impatient order | An order's reward bar shrinks over time, so early delivery pays more. Overlaps GO06 and GO19; this adds the decaying value | Hurry Curry! | grid | S | C |

Already in the module, so **not new**: gravity flip (EV03) and turntable (BL11) cover ROTA's rotating world; board slide (CV09) and mascot path (GO10) cover labyrinth games; sticky landing (PL01), colour pop (CL05) and merge (CL12) cover the 2048 and Prism family; bomb (SP01), treasure (SP11) and chisel (CV07) cover the Bomberman family; ghost sends (IN13) covers ghost racing; stage medley (BL15) and mystery event card (EV15) are the closest to Librerama.

## 3. Free assets and sources (3D, textures, SFX, music, fonts, icons, UI)

| Name | URL | Category | Licence | Use | Verdict |
|---|---|---|---|---|---|
| Kenney | https://kenney.nl | 3D, UI, audio, icons | CC0 | Already adopted. Includes the Kenney Game Icons font | Adopt |
| Quaternius | https://quaternius.com | Low poly 3D models | CC0 *(site FAQ: all models CC0)* | Meadow scenery and props | Adopt |
| Poly Haven | https://polyhaven.com | HDRIs, PBR textures, models | CC0 *(licence page)* | Sky HDRI and tileable textures for the meadow | Adopt |
| ambientCG | https://ambientcg.com | PBR textures | CC0 *(licence page)* | Wood, fabric and jelly-surface references | Adopt |
| Poly Pizza | https://poly.pizza | Low poly 3D | CC0 or CC-BY 3.0 **per model** (per list) | Filter to CC0; log any CC-BY in `credits.json` | Evaluate |
| Kator Legaz 3D Models | list: Graphics Assorted | 3D | CC-BY 3.0 | Attribution needed | Evaluate |
| OpenGameArt.org | https://opengameart.org | Mixed | Per asset: CC0, CC-BY, CC-BY-SA, GPL and others | Filter to CC0 and CC-BY. SA, GPL and NC are not usable | Evaluate |
| Blend Swap, Blender 3D Model Repository | list | 3D | Mixed CC, many NC or SA | Per-file check; default skip | Skip |
| Freesound | https://freesound.org | SFX | Per sound: CC0, CC-BY, CC-BY-NC | Filter to CC0 and CC-BY. NC is not usable | Evaluate |
| Audioaugust sound effects | list: Sound Effects | SFX | CC-BY 4.0 | Attribution | Evaluate |
| SoundBible royalty-free section | list | SFX | CC or PD, per sound | Per-sound check | Evaluate |
| Opsound | list | SFX, music | CC-BY-SA 3.0, **not usable** | | Skip |
| rFXGen, jsfxr, sfxr-sdl | https://github.com/raysan5/rfxgen, https://github.com/chr15m/jsfxr | SFX generators | zlib (pushed 2026-08), Unlicense (2026-05), MIT (per list) | Already adopted; generated output is ours | Adopt |
| Glasan-FX | list: Audio Editors | SFX generator | MIT (per list; repo not located) | Alternative to rFXGen | Reference |
| Incompetech (Kevin MacLeod) | https://incompetech.com | Music | CC-BY 4.0 *(FAQ page; the list says 3.0)* | Large cheerful library. Credit line required | Adopt |
| CC0 Music | list: Music | Music | CC0 | Zero-attribution tracks | Adopt |
| Silverman Sound Studios tracks | list | Music | CC-BY 4.0 | Attribution | Evaluate |
| Free Music Archive, Jamendo, ccMixter, Bandcamp CC, SoundCloud CC | list | Music | Mixed CC, many NC or SA | Per-track check. NC and SA are not usable | Evaluate |
| Musopen, Open Music Archive | list | Classical, archive recordings | Public domain compositions; recordings vary | Classical covers for a silly menu theme | Evaluate |
| LibreFM, Musical Artifacts, GameSounds.xyz | list | Music, sound | Mixed | Per-item check | Skip |
| Google Fonts | https://fonts.google.com | Fonts | OFL (some Apache) | Rounded display fonts for cute UI. Embedding in an app is allowed under OFL | Adopt |
| The League of Moveable Type, Open Font Library | list | Fonts | OFL | Backup sources | Evaluate |
| ParaType fonts | list | Fonts | Custom ParaType licence | Not needed | Skip |
| Kenney Game Icons | list | Icon font | CC0 | HUD and icon glyphs | Adopt |
| Material Design Icons | https://fonts.google.com/icons | Icons | Apache 2.0 | Settings, pause, share, wifi | Adopt |
| Font Awesome Free | list | Icons | Icons CC-BY 4.0, fonts OFL, code MIT *(memory)* | Attribution for icons | Evaluate |
| Game-icons.net | https://game-icons.net | Icons (black and white) | CC-BY 3.0 | Power-up and badge icons. Credit authors | Evaluate |
| Tango icons, Openclipart | list | Icons, clip art | Public domain / CC0 | Fallbacks | Reference |
| FatCow icons | list | 16 and 32 px icons | CC-BY 3.0 | Too small and dated for phones | Skip |
| Controller and Keyboard Prompts | https://thoseawesomeguys.com/prompts | Input glyphs | CC0 | We are touch-first; only for a later controller option | Skip |
| LPC Spritesheet Generator, Vecteezy, ZipUp, SpriteLib, 7Soul1 | list | 2D sprites and art | SA, mixed or custom | 2D and pixel only. SA is not usable | Skip |

Textures can also come from **Material Maker** (MIT, section 4), which makes our own tileable maps with no licence trail.

## 4. Tools (audio, 3D, 2D, textures, profiling)

GPL and AGPL appear here because they are tools. Their output is ours and they are never linked into the game.

| Name | URL | Category | Licence | Use | Verdict |
|---|---|---|---|---|---|
| Blender | https://blender.org | 3D | GPL (tool) | Already the asset pipeline | Adopt |
| Material Maker | https://github.com/RodZill4/material-maker | Textures | MIT, pushed 2026-10-07 | Procedural PBR and stylised materials, built on Godot | Adopt |
| Krita, GIMP, Inkscape | list | 2D, vector | GPL (tools) | Icons, store art, SVG UI | Evaluate |
| Pixelorama | https://github.com/Orama-Interactive/Pixelorama | Pixel art | MIT, 2026-10-08 | Only if we do pixel UI | Reference |
| GodSVG | awesome-godot Projects | SVG editor | Not checked | Optimised SVG for UI | Reference |
| MSDF Atlas Studio | https://github.com/sachinthankachan/msdf-atlas-studio | Font atlases | MIT, 2026-10-07 | Godot has built-in MSDF fonts; exotic cases only | Reference |
| AwesomeBump, NormalMapOnline, TextureGeneratorOnline | list | Textures | LGPL / MIT | Material Maker covers these | Skip |
| MeshLab, Dilay, Sproxel, MakeHuman, ngPlant | list | Mesh, voxel, characters | GPL / BSD | Not needed for cute blocks | Skip |
| ProtonScatter | https://github.com/HungryProton/scatter | Scene scatter (Godot) | MIT, 2026-09-27 | Meadow grass, flowers, decor placement | Evaluate |
| pngquant, Trimage | list | Image compression | pngquant is GPL-3 now *(memory; list says BSD)*, Trimage MIT | Godot VRAM compression usually makes these unnecessary | Reference |
| Audacity | https://audacityteam.org | Audio editor | GPL (tool) | Trim and normalise SFX | Adopt |
| Bosca Ceoil Blue | https://github.com/YuriSizov/boscaceoil-blue | Easy music maker (Godot) | MIT, 2025-04 | Fast jingles and loops, exports WAV | Evaluate |
| MilkyTracker | https://milkytracker.org | Music tracker (.mod, .xm) | GPL tool, player lib BSD | Tracker jingles, export to WAV or OGG | Evaluate |
| LMMS, Ardour, Hydrogen, Beast, Musagi | list | DAW, drums, synth | GPL / LGPL tools | LMMS is the easy DAW pick | Evaluate |
| Godot Mixing Desk | https://github.com/kyzfrintin/Godot-Mixing-Desk | Adaptive music | MIT, last push 2022 | Layered adaptive music idea (calm vs chaos). Stale for Godot 4 | Reference |
| Event Audio | https://github.com/bbbscarter/event-audio-godot | Audio events | MIT, 2024 | Pattern for data-driven SFX events | Reference |
| RenderDoc | https://renderdoc.org | GPU debugger | MIT (baldurk/renderdoc, 2026-10) | Capture Vulkan frames on the Android device | Evaluate |
| Tracy | https://github.com/wolfpld/tracy | Frame profiler | BSD-3 (C++ only) | Only if GDExtension code ever needs it | Skip |
| Perfetto | https://perfetto.dev | Android tracing | Apache 2.0 *(outside the lists)* | System-level Android frame traces | Evaluate |
| Godot Shader Warmup | https://github.com/Koisuji02/GodotShaderWarmup | Shader stutter | MIT, 2026-03 | Prevents first-use hitches on mobile. Compare with the engine shader baker first | Evaluate |
| Godot Shaders site | https://godotshaders.com | Shaders | Per shader (many CC0, some GPL) | Per-shader licence check | Evaluate |

## 5. Godot add-ons from awesome-godot (every section scanned)

| Name | URL | Category | Licence | Use | Verdict |
|---|---|---|---|---|---|
| gdUnit4, gdUnit4Net | https://github.com/godot-gdunit-labs/gdUnit4 | Tests | MIT, 2026-10-08 and 2026-10-06 | Already adopted. gdUnit4Net runs C# tests in the same runner | Adopt |
| godot-ci | https://github.com/abarichello/godot-ci | CI | MIT, 2026-10-05 | Already adopted | Adopt |
| godot-gdscript-toolkit | https://github.com/Scony/godot-gdscript-toolkit | Lint, format | MIT, last push 2025-10 | `gdlint` and `gdformat` in CI. Check it parses 4.7 syntax first | Evaluate |
| Godot Doctor | https://github.com/codevogel/godot_doctor | Scene and resource validation | MIT, 2026-08 | Overlaps our `LevelValidator`, but validates scenes | Evaluate |
| License Manager (kenyoni) | https://github.com/kenyoni-software/godot-addons | Credits UI | MIT, 2026-08 | Same family as the QR add-on; could feed the credits screen | Evaluate |
| GATO accessibility toolkit | https://github.com/Nokorpo/gato-godot-accessibility-toolkit | Accessibility | MPL-2.0 | Colourblind and text-size demos. MPL is file-level copyleft, so keep its files separate | Evaluate |
| Maaack's Game Template | https://github.com/Maaack/Godot-Game-Template | Menus, options, credits, scene loader | MIT, 2026-09 | Menu scaffolding | Evaluate |
| Crystal Bit game template | https://github.com/crystal-bit/godot-game-template | Template with CI | MIT, 2026-06 | Pause and transition reference | Reference |
| Godot C# Template (CSharpGodotTools) | https://github.com/CSharpGodotTools/Template | C# template with ENet | MIT, 2026-06 | ENet in C# reference | Reference |
| Phantom Camera | https://github.com/ramokz/phantom-camera | Camera | MIT, 2026-10-07 | Camera blends for tower tilt and zoom. Check mobile cost | Evaluate |
| Juicee, Shaker | https://github.com/Kelpekk/Juicee | Game feel | MIT (Juicee 2026-09, Shaker 2024) | Screen shake, hit stop. A 20-line script may do | Evaluate |
| Sentry Godot | https://github.com/getsentry/sentry-godot | Crash reports | MIT, 2026-10-09 | Android native crash and script error reports. The SDK is MIT; the Sentry service has its own plans and privacy terms | Evaluate |
| Talo | https://github.com/TaloDev/godot | Leaderboards, stats backend | MIT, 2026-10-09 | Self-hostable daily-challenge leaderboard, later | Evaluate |
| godot-play-game-services | https://github.com/godot-sdk-integrations/godot-play-game-services | Google Play Games | MIT, 2026-07 | Achievements and cloud save | Evaluate |
| godot-google-play-billing | https://github.com/godot-sdk-integrations/godot-google-play-billing | In-app purchase | MIT, 2026-09 | Only if we sell content packs | Evaluate |
| godot-admob | https://github.com/godot-sdk-integrations/godot-admob | Ads | Not checked | No ads planned. The list's `poing-studios` plugin is archived | Skip |
| System Bar Color Changer | https://github.com/syntaxerror247/godot-android-system-bar-color-changer | Android UI | MIT, 2025-10 | Edge-to-edge look | Evaluate |
| godot-playfab | https://github.com/Structed/godot-playfab | Backend, analytics | MIT, 2026-06 | Service lock-in; not needed | Skip |
| PlayerConnect | https://github.com/rayzorite/PlayerConnect | Bug reports via Discord webhook | CC0 | The webhook URL ships in the client and can be abused | Skip |
| Beehave, LimboAI | https://github.com/limbonaut/limboai | Behaviour trees | MIT, 2026 | Bot opponents for single-phone testing, maybe later | Reference |
| Dialogue Manager, Dialogic, Sprouty Dialogs | https://github.com/nathanhoad/godot_dialogue_manager | Dialogue | MIT | Mascot barks are short lines in the translation CSV; no need | Skip |
| Input Helper | https://github.com/nathanhoad/godot_input_helper | Input remap | MIT, 2025-06 | Touch-first; skip | Skip |
| Virtual Joystick | https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot | Touch | MIT, 2025-01 | We use swipes and taps | Skip |
| Netfox, Vest | https://github.com/foxssake/netfox | Netcode, tests | MIT | Rejected earlier (no rollback; gdUnit4 is the test tool) | Skip |
| godot-jolt | https://github.com/godot-jolt/godot-jolt | Physics | MIT, 2026-03 | Rejected earlier. Jolt is built in | Skip |
| webrtc-native | https://github.com/godotengine/webrtc-native | Online play | MIT, 2026-09 | Already adopted for later | Adopt |
| friflo ECS, Godex | list | ECS | MIT | Our sim is not an ECS. ADR-0001 owns the data model | Skip |
| Godot Demo Projects | https://github.com/godotengine/godot-demo-projects | Official demos | MIT, 2026-10 | Reference for ENet, WebRTC, Android and touch input | Reference |
| ShipThis CLI | https://github.com/shipth-is/cli | Build and publish | MIT, 2026-10-09 | Alternative to hand-run Play Console uploads | Evaluate |
| Editor support (VS Code godot-tools, Rider, Zed and others) | awesome-godot "editor support" | Editors | Mixed | Developer choice, not game content | Reference |
| Terrain3D, HTerrain, godot_voxel, Waterways, Cyclops, Roommate | awesome-godot | Terrain, level tools | MIT mostly | Not needed for a box board | Skip |
| Quest, inventory, spell, Gedis, SQLite, FMOD, Wwise, GodotSteam, Agones, NobodyWho, Torrent | awesome-godot | RPG, backend, middleware | Various | No fit | Skip |
| Godot 3 only items (Anima, Goost, GodotRx, godot-lod, godot-simple-state, Godot GamePad and others) | awesome-godot | Old | Various | Godot 3 or stale | Skip |

## 6. C# libraries for Godot .NET (Android caveats)

**Platform facts (docs, branch 4.7):** C# on Android has been supported since 4.2 and is still labelled experimental. Android export needs .NET 9 or later in the 4.7 docs, and Godot 4.8 needs .NET 10 or later. C# web export is not supported. Android builds can be trimmed or ahead-of-time compiled, so **prefer source-generator libraries over reflection-based ones**, and export one test build to a real phone before depending on any package. The docs do not list known-good NuGet packages, so every verdict below means "expected to work", not "verified on Android".

| Name | URL | Category | Licence | Use | Verdict |
|---|---|---|---|---|---|
| System.Text.Json (source generated) | built into .NET | JSON | MIT | Level and knob JSON if C# parses them. Source generation is the trim-safe route | Adopt (if C# parses levels) |
| gdUnit4Net | https://github.com/godot-gdunit-labs/gdUnit4Net | Tests | MIT | C# tests in the existing runner | Adopt |
| NUnit, xUnit | https://github.com/nunit/nunit | Tests | MIT (NUnit), Apache-2.0 (xUnit) | Pure C# sim tests outside the editor (`dotnet test`) if the sim moves to C# | Evaluate |
| Shouldly | https://github.com/shouldly/shouldly | Assertions | BSD-3 | Readable asserts | Evaluate |
| FluentAssertions | https://github.com/fluentassertions/fluentassertions | Assertions | Xceed Community License (not plain OSS) | | Skip |
| NSubstitute | https://github.com/nsubstitute/NSubstitute | Mocks | BSD-3 | Dependency-injected tests | Reference |
| Moq | https://github.com/devlooped/moq | Mocks | MIT (repo); has had a telemetry controversy *(memory)* | | Skip |
| Chickensoft LogicBlocks | https://github.com/chickensoft-games/LogicBlocks | State machines | MIT, 2026-10-05 | Rule-runtime lifecycle and mascot moods | Evaluate |
| Chickensoft AutoInject, GodotNodeInterfaces, Introspection, Serialization, GodotEnv, GameTools | https://github.com/chickensoft-games | DI, typed nodes, .NET version manager | MIT, all pushed Sep to Oct 2026 | A well-maintained C# Godot ecosystem. GodotEnv also pins Godot and .NET versions | Evaluate |
| MessagePack-CSharp | https://github.com/MessagePack-CSharp/MessagePack-CSharp | Binary serialisation | MIT | LAN messages if we go C#. Use the source-generated (AOT) mode | Evaluate |
| MemoryPack | https://github.com/Cysharp/MemoryPack | Binary serialisation | MIT | Faster option, source generator | Evaluate |
| LiteNetLib | https://github.com/RevenantX/LiteNetLib | UDP networking | MIT, 2026-10-04 | Fallback if ENet via `SceneMultiplayer` hits limits. ADR-0009 stays on ENet | Reference |
| ZString | https://github.com/Cysharp/ZString | Zero-allocation strings | MIT | HUD text without GC churn | Evaluate |
| R3 | https://github.com/Cysharp/R3 | Reactive | MIT | Godot signals are enough | Skip |
| UniTask | https://github.com/Cysharp/UniTask | Async | MIT | Unity-specific. Godot has `await ToSignal` | Skip |
| HCoroutines | https://github.com/Inspiaaa/HCoroutines | Coroutines | MIT, 2025-03 | Tween and event sequences in C# | Reference |
| GodotRx | https://github.com/semickolon/GodotRx | Reactive | MIT, 2024-07 | Stale | Skip |
| Stateless | https://github.com/dotnet-state-machine/stateless | State machine | Apache 2.0 | LogicBlocks fits Godot better | Reference |
| Polly | https://github.com/App-vNext/Polly | Retry | BSD-3 | No server calls | Skip |
| CommunityToolkit.dotnet | https://github.com/CommunityToolkit/dotnet | Helpers, source generators | MIT *(memory; repo reports no SPDX)* | Source-generated helpers | Reference |
| Sentry for .NET | https://github.com/getsentry/sentry-dotnet | Crash reporting | MIT, 2026-10-09 | Only if the game is C#. Test it on Android first | Evaluate |
| friflo ECS | https://github.com/friflo/Friflo.Engine.ECS | ECS | MIT, 2026-09 | Supports Godot, but our sim data model is already decided | Skip |
| 2dog | https://2dog.dev | .NET control of Godot for CI | Not checked | Possible headless .NET test driver | Reference |
| codetranslator, gd2cs.py | awesome-godot "Other" | GDScript to C# converters | WIP | Not trustworthy | Skip |

Hot-path note: the plan keeps the sim in GDScript, with C# or C++ only after profiling. Nothing here changes that. If the sim does move to C#, the libraries that matter most are System.Text.Json source generation, MessagePack or MemoryPack, and LogicBlocks.

## 7. Localization, playtesting, analytics, release and docs

| Name | URL | Category | Licence | Use | Verdict |
|---|---|---|---|---|---|
| Godot built-in translations (CSV or PO) | https://docs.godotengine.org | Localisation | MIT (engine) | Already planned: translation CSV stub, keys everywhere | Adopt |
| Poedit | https://github.com/vslavik/poedit | PO editor | MIT *(outside the lists)* | Translator-friendly editor if we move CSV to PO | Evaluate |
| Weblate | https://github.com/WeblateOrg/weblate | Translation platform | GPL-3.0 (self-host; tool only) *(outside the lists)* | Community translations later. Hosted plans are paid for non-libre games | Reference |
| PowerKey | https://github.com/phosxd/PowerKey | Dynamic translation | MIT, **archived** | | Skip |
| GATO accessibility toolkit | see section 5 | Accessibility | MPL-2.0 | Colourblind modes, text scale | Evaluate |
| Sentry Godot | see section 5 | Crash reporting | MIT | The first thing a solo dev needs after the first external tester | Evaluate |
| Talo | see section 5 | Stats, leaderboards | MIT | Optional | Evaluate |
| GameAnalytics, Firebase, PlayFab | not on the lists | Analytics | Proprietary SDKs | Skip for now (privacy review, store data-safety forms) | Skip |
| fastlane | https://github.com/fastlane/fastlane | Store upload | MIT, 2026-10 *(outside the lists)* | Play Console upload and metadata automation | Evaluate |
| ShipThis CLI | https://github.com/shipth-is/cli | Build and publish | MIT | Godot-specific alternative to fastlane | Evaluate |
| itch.io butler | https://github.com/itchio/butler | Distribution | MIT *(outside the lists)* | Push desktop test builds to itch | Evaluate |
| godot-actions | https://github.com/bend-n/godot-actions | CI to itch | Not checked | Overlaps godot-ci | Reference |
| Play Console internal testing | https://play.google.com/console | Playtest distribution | Service | Internal track needs no review | Adopt |
| Godot docs | https://github.com/godotengine/godot-docs | Documentation | CC-BY 3.0 *(memory; repo reports no SPDX)* | Source for the version-pinned references | Reference |
| Godot Recipes, GDQuest tutorials | awesome-godot | Learning | Mixed (GDQuest assets are NC-SA) | Read only | Reference |
| Procedural Content Generation Wiki | list: Learning | Design reading | CC-BY-SA 3.0 | Read for the daily generator. SA means do not paste its text | Reference |
| Wikiversity School of Game Design | list | Design reading | CC-BY-SA 3.0 | Read only | Reference |
| Libregamewiki, FreeGameDev forums, /r/godot | list: Communities | Community | none | Where to find playtesters and feedback | Reference |
| Learning-resource entries (Python, Java, Haskell, C++, Lua) | list | Programming courses | CC-BY, CC-BY-SA | Not relevant to our stack | Skip |
| Other engines, HTML5 libs, math libs, GPU monitors (NVTOP, RadeonTop), Recast and DotRecast, Kcp, raylib, SDL | list | Other engines and libs | Various | We are on Godot. ENet is adopted, Jolt is built in, no navmesh | Skip |

## 8. Anything else a solo developer needs

Gaps the lists do not fill, noted so they are not forgotten.

- **Privacy policy and data-safety form** for Google Play. The LAN design collects no accounts, which keeps this short. Any crash reporter or leaderboard changes the answers.
- **Credits.** Every CC-BY item needs a `credits.json` entry from day one (already a rule). Incompetech, Game-icons.net and Poly Pizza CC-BY models are the likely first ones.
- **Android signing key and Play App Signing.** Back up the upload keystore offline.
- **Device test matrix.** One low-end and one mid-range phone, because the Mobile renderer with Jolt and shader-compile hitches are the likely problems (see Shader Warmup and Perfetto above).
- **Not relevant:** controller prompt packs, Steam bindings and AI NPC add-ons on the lists.

## 9. Suggested next steps

1. Add to the asset-source list: Quaternius, Poly Haven, ambientCG, Incompetech, Google Fonts, Kenney icons and Material Design Icons.
2. Try Material Maker, Bosca Ceoil Blue and Audacity for the first textures and sounds.
3. When C# starts, install .NET 9 first, make one Android smoke export before adding any NuGet package, and prefer source-generator libraries.
4. Send section 2 to the game-designer (10 candidate atoms, 2 flagged as overlaps).
5. Re-check the "experimental on Android" wording in the real 4.7.2 docs and again at 4.8.
