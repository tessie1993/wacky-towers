# Godot AI arcade integration evidence

The main game's existing **Arcade** menu now contains a **Play Toy-Box Trials** card inside its scrolling content. The new intent pauses the main session, clears the profile's playing lock, resets input, and opens `res://minigames/arcade_pack/arcade_hub.tscn`. A failed scene change shows a toast. The title menu's height is unchanged.

The changes were authored through the actual Godot AI editor tools, using the repository's `tools/godot-ai/relay.py`. Godot AI addon and Python server were both **4.3.0**, and the live editor reported **Godot 4.7.2-stable (official)**. The relay discovered **47 tools** over authenticated local Streamable HTTP and editor WebSocket v2. The editor, server and client ran in one network namespace; optional telemetry and update checks were disabled.

| Actual request | Observed result |
| --- | --- |
| `script_patch(path="res://src/mechanics/behaviour/items.gd", old_text=sort callback ending, new_text=ending plus closing parenthesis)` | One replacement committed. Fixed the existing missing `sort_custom` closing parenthesis that blocked main-game dependencies. |
| `filesystem_manage(op="scan", params={})` | `scan_completed: true`, `scan_settle: "settled"`. |
| `script_patch(path="res://src/app/main.gd", old_text=start_arcade branch, new_text=open_minigames branch plus original branch)` | One replacement, `diagnostics_status: "checked"`, `diagnostics: []`, `reloaded: true`. |
| `script_patch(path="res://src/ui/game_ui.gd", old_text=show_arcade opening, new_text=opening with Trials card)` | One replacement committed; normalised the description's newline with a second anchored patch. |
| Final `script_patch` on the card description | One replacement committed: “Time a tower, turn parcels through gates,\nand build matching shadows. Three games, nine levels.” |
| `script_create` for temporary GameUi, ItemsRule and hub validation copies | Each returned `diagnostics_status: "checked"` and `diagnostics: []`. |
| `scene_open(path="res://minigames/arcade_pack/arcade_hub.tscn", force_reload=true)` | `switched: true`, `reloaded_from_disk: true`, `settle: "settled"`. |
| `editor_state()` | `readiness: "ready"`, current scene was the arcade hub, editor Godot version was 4.7.2. |

Godot AI's temporary unpathed GDScript validator reported duplicate global-class diagnostics for existing `class_name GameUi` and `class_name ItemsRule`. Its temporary source has no resource path, so it collides with the already registered class. Validation copies omitted only that declaration, retained the real parent and all implementation code, and parsed cleanly through the actual `script_create` tool. The anonymous main and hub scripts parsed without this workaround. No addon code was changed.

The toolkit's `filesystem_manage(remove, permanent=true)` refused probe cleanup because an unrelated owner, `assets/data/shapes/shape_bank.tres`, exceeded its 262144-byte dependency-discovery limit. Its response stated `outcome: "unchanged"`. Only the three known, newly created validation scripts were then removed directly; no validation files remain in the project.

Raw connection, catalogue, job responses and tool-call transcript are retained locally under `reports/godot-ai/` and `tools/godot-ai/results/`. These contain no capability credentials. They are development evidence rather than release assets.

The final integration passed a separate real Godot graphical navigation smoke on Xvfb display 98 with Mesa llvmpipe, OpenGL 4.5, at **1280 × 720**, exit code **0**. The runner emitted the actual visible buttons' `pressed` signals and verified this complete route:

1. Main title → **Arcade**.
2. **Play Toy-Box Trials** → arcade hub, with the main session paused and the profile's playing lock cleared.
3. First chapter → briefing → **Let's play** → an active stack minigame with a fresh round model.
4. **Hub** → **Original game** → `res://src/app/main.tscn`.

The runner reported `ARCADE_NAVIGATION_SMOKE {"passed":true,...}` with no script/runtime errors. [Arcade entry screenshot](evidence/arcade_pack/pr17-arcade-entry.png) was captured from the real viewport and visually inspected: the Trials card and its button are fully visible; the existing endless Arcade card remains below in the same scroll area. This verifies desktop navigation and rendering, not physical Android input.
