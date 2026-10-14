# Addon Audit: 2026-10-14

**Scope:** every folder under `addons/`, checked for enabled state, real use in `src/`, Godot 4.7.2
compatibility and a keep / wire in / remove recommendation. Nothing was removed or edited in `src/`,
`project.godot` or `.mcp.json`. The full gdUnit suite was **not** run, as the user asked.
**Engine probed:** `godot --version` = `4.7.2.stable.official.ed1daf0bf` (Linux, `/usr/local/bin/godot`).

## How compatibility was checked

1. **Compile pass.** A throwaway SceneTree script loaded every `.gd` under each addon with
   `CACHE_MODE_IGNORE` on 4.7.2. The result was 0 failures in all 12 addons (789 scripts).
2. **Editor boot.** `godot --headless --path . --editor --quit` with the 5 enabled plugins and 2
   GDExtensions. The only addon error was phantom_camera's **updater**
   (`panel/updater/update_button.gd:62`: it assigns a Dictionary to an Array when GitHub's
   releases API returns an error object, which happens behind the proxy). The error is editor-only
   and harmless.
3. **Runtime.** The 720x1280 capture run (below) booted `main.tscn` with all runtime autoloads and
   showed no addon errors.
4. **Declared minimums.** Orchestrator `compatibility_minimum="4.7"`, GodotSteam `"4.4"`, godot_ai
   "4.7+", MCP Toolkit "tested up to 4.7.0, 4.8+ not blocked".

## Addon table

| Addon (version) | Enabled in project.godot | Used in `src/` | 4.7.2 | Shipped in exports | Recommendation |
|---|---|---|---|---|---|
| **gdUnit4** 6.2.1 | yes | no; it is the test framework for `tests/` (`GdUnitTestSuite`) and `tools/ci/test.sh` | OK | excluded | **Keep** |
| **guide** (G.U.I.D.E.) 0.14.0 | yes, plus the `GUIDE` autoload | **yes**, heavily: `src/game/input/*`, `src/app/player_input.gd` and 11 action `.tres` | OK | yes (runtime) | **Keep**, core dependency |
| **beehave** 2.9.3 | yes, plus 2 autoloads (`BeehaveGlobalMetrics`, `BeehaveGlobalDebugger`) | **yes**: `core/rules/runtime/rule_runtime.gd`, `view/wt_toy_actor.gd`, `physics/wt_physics_challenge.gd` and one staging scene | OK | yes | **Keep**. Follow-up: check that the metrics and debugger autoloads cost nothing in release builds |
| **phantom_camera** 0.11.0.3 | yes, plus the `PhantomCameraManager` autoload | **dormant**: only `src/view/camera_rig.gd/.tscn` and `src/dev/pcam_probe.tscn`. Gameplay uses a hand-built `Camera3D` in `src/view/wt_stage.gd`, and `CameraRig` is instanced only by `src/dev/camera_rig_preview.tscn` | OK (updater error only) | yes, autoload ships | **Keep, do not wire in for framing** (see the camera spike). Decide later: wire `CameraRig` in for blends, or retire it and the autoload |
| **godot_ai** 4.3.0 | yes, plus the `_mcp_game_helper` autoload | no (tooling) | OK; requires 4.7+ | excluded. Its export plugin strips the autoload (#740) | **Keep** as the working MCP bridge (`tools/godot-ai/relay.py`) |
| **orchestrator** (GDExtension) | not a plugin; registered in `.godot/extension_list.cfg` | **yes**: `src/app/wt_architecture.gd` loads `src/app/architecture.torch` from `main.gd` | OK; requires 4.7 | yes (163 MB on disk, one platform lib per export) | **Keep** (a hard dependency: `assert` on load) |
| **godotsteam** 4.23.1 (GDExtension) | not a plugin; registered in `extension_list.cfg` | **no** (0 refs) | OK; requires 4.4+ | **yes**, not in `exclude_filter`. 106 MB on disk; Linux, Windows and Android ship the `.so`/`.dll` plus `libsteam_api`. It has no web library | **Keep, but exclude from non-Steam presets** (Android, Web) until a Steam story lands; or remove if Steam is not in the plan. Producer decides |
| **godot_mcp_toolkit** 1.0.3 | **no** | no (tooling) | OK by compile; vendor-tested to 4.7.0 | excluded | **Wire in** only if the MCP fix below is adopted. Otherwise it duplicates godot_ai |
| **TileMapLayer3D** 1.2.0 | no | comment only (`levels/_kit/platform/meadow_platform.gd`: "only paints flat atlas quads") | OK by compile | excluded | **Remove candidate** (8.8 MB). It was evaluated and rejected for platforms |
| **GDQuest_GDScript_formatter** 0.27.0 | no | n/a (editor tool) | OK by compile | excluded | **Keep, optional**: enable per developer, or run it in CI as a formatter |
| **script-ide** 2.2.5 | no | n/a (editor tool) | OK by compile | excluded | **Keep, optional** (per-developer preference) |
| **xesa** (Expose Them Properties) v0.2.1 | no. Its `plugin.cfg` is nested at `xesa/ExposeThemProperties/`, so it is not discoverable as `res://addons/xesa/plugin.cfg` | no | OK by compile | **not excluded**, ships about 132 KB of editor scripts | **Remove candidate**, or move it to `addons/ExposeThemProperties/` and add it to `exclude_filter` |

All licenses are MIT, except Orchestrator (Apache-2.0). GUIDE's license is MIT-style. None blocks
shipping.

### Findings that affect playtesting and screenshots

- **Two MCP bridges are installed.** godot_ai is enabled and working (relay in `tools/godot-ai/`).
  godot_mcp_toolkit is disabled, and its `.mcp.json` launcher is broken on Linux. Pick one per
  session. Running both registers two runtime autoloads and binds two port bands.
- **Screenshots do not need either MCP.** The `tools/qa/*_capture.gd` and `story_playthrough`
  scripts under `xvfb-run ... --rendering-driver opengl3 --resolution 720x1280` already produce
  deterministic evidence. This audit's prototype reuses `tools/qa/island_capture.gd`.
- **phantom_camera's updater** fires an HTTP request on every editor start and errors behind the
  proxy. It is cosmetic; it can be turned off in the plugin's Project Settings, if exposed.

## MCP: godot_mcp_toolkit launcher fix (proposal only, `.mcp.json` not edited)

**Root cause.** The current `.mcp.json` is the Windows form:

```json
"command": "cmd", "args": ["/c", "npx", "-y", "@npgamedev/godot-mcp-server"]
```

Linux has no `cmd`, so Claude Code reports `Executable not found in $PATH: cmd`. A second blocker
remains after the launcher is fixed: **the plugin is not enabled in `project.godot`**, so nothing
listens on `127.0.0.1:6550`. The bridge then starts but loops on `ws://127.0.0.1:6550 disconnected`.

**Verified here:** Node 22.22 (`/opt/node22/bin/npx`) runs `npx -y @npgamedev/godot-mcp-server`.
It answers an MCP `initialize` with `serverInfo godot-mcp-toolkit 1.0.3` (matching the plugin) and
36 tools, then retries the editor port. **Not verified:** the full editor round trip, because
enabling the plugin needs a `project.godot` change.

### 1. Proposed `.mcp.json` (checked in; Linux, macOS, WSL)

This matches the addon's own `addons/godot_mcp_toolkit/.mcp.json.template`, with the port pinned so
the headless editor and the bridge agree without discovery:

```json
{
  "mcpServers": {
    "godot-mcp-toolkit": {
      "command": "npx",
      "args": ["-y", "@npgamedev/godot-mcp-server@1.0.3"],
      "env": {
        "GODOT_MCP_CONFIG_VERSION": "1",
        "GODOT_MCP_EDITOR_PORT": "6550"
      }
    }
  }
}
```

The version pin `@1.0.3` keeps the bridge in lockstep with the vendored plugin. Bump both together.

### 2. Windows developers: local override instead of a shared `cmd /c`

Native Windows cannot spawn `npx.cmd` without a shell. A single checked-in file therefore cannot
serve both platforms. A local-scope server with the same name takes precedence over the project
file, so Windows developers keep the `cmd` form out of git:

```powershell
claude mcp add --scope local godot-mcp-toolkit `
  --env GODOT_MCP_CONFIG_VERSION=1 --env GODOT_MCP_EDITOR_PORT=6550 `
  -- cmd /c npx -y @npgamedev/godot-mcp-server@1.0.3
```

### 3. Editor side on Linux (headless or Xvfb)

The plugin must be enabled first. Two options, both needing the user's approval:

- **(a) Commit it:** add `"res://addons/godot_mcp_toolkit/plugin.cfg"` to
  `[editor_plugins] enabled`. The plugin then writes its runtime autoload into `project.godot` (the
  same pattern as godot_ai's `_mcp_game_helper`). `addons/godot_mcp_toolkit/*` stays in
  `exclude_filter` (already present).
- **(b) Per session, untracked:** a gitignored `override.cfg` at the repo root carrying the same
  `editor_plugins/enabled` list plus the toolkit. **Caveat:** the toolkit re-asserts its autoload
  and may save `project.godot`. Check `git diff project.godot` after the first run.

Launch the editor before Claude Code connects. The proposed helper is
`tools/mcp/godot-mcp-editor.sh` (not created):

```bash
#!/usr/bin/env bash
# File tools only (scene/script/node edits): true headless editor.
export GODOT_MCP_EDITOR_PORT=6550   # must match .mcp.json env (an env var is not a sync channel)
exec godot --path "$(git rev-parse --show-toplevel)" --editor --headless
# Viewport tools (screenshots, game_start captures) return HEADLESS_UNSUPPORTED headless.
# For those use a virtual display instead:
#   exec xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --editor --rendering-driver opengl3
```

Run it with `run_in_background`, wait for `[MCPServer] listening on 127.0.0.1:6550`, then
`/mcp` → reconnect `godot-mcp-toolkit`.

**Recommendation:** do not enable both MCPs by default. godot_ai already works here. Adopt the
toolkit fix only if a specific toolkit tool is needed (e.g. `input_simulate`, `debug_set_breakpoint`).
Until then, change `.mcp.json` to the Linux form (or delete the entry) so every Linux session stops
logging the connection failure.

## phantom_camera: portrait framing spike (720x1280)

**Prototype:** `prototypes/camera_pcam/` (README, `pcam_framing_capture.gd/.tscn`). It is
throwaway, and nothing in `src/` references it.

**Method.** The prototype boots the real `main.tscn` and starts `meadow_01` and `celestial_01` with
the `island_capture.gd` piece fixture and the sim frozen. It shoots BEFORE with the stock
`WtStage` camera. It then hands the same `Camera3D` to a `PhantomCameraHost` plus a priority-10
`PhantomCamera3D` (ortho resource). Size and offset come from projecting the board AABB (footprint
+ 0.6, floor to `h_play + 1`) at all 12 yaw snaps into the HUD board rect.

| Level | Camera | Ortho size | Board y px | Board rect y px (`game_ui.board_area()`) | Board inside rect |
|---|---|---|---|---|---|
| meadow_01 | stock | 23.13 | 143 to 947 | 192 to 1050 | **no**: top 49 px under the goal chip and NEXT row |
| meadow_01 | pcam | 23.13 | 219 to 1023 | 192 to 1050 | yes |
| celestial_01 | stock | 23.13 | 113 to 964 | 192 to 1050 | **no**: top 79 px under the HUD |
| celestial_01 | pcam | 23.13 | 196 to 1046 | 192 to 1050 | yes |

**Verdict: no gain from phantom_camera itself. Do not wire it into gameplay for framing.**

- Portrait is width-bound, so zoom is identical. Phantom camera has no orthographic auto-fit:
  `auto_follow_distance` only moves the camera, which does nothing in ortho. The prototype had to
  compute the size itself, and that is the same math `WtStage._frame_camera()` already does.
- The real improvement is **centring**. `WtStage._update_camera()` aims at `(0, h_play * 0.36, 0)`
  and adds the board-rect offset. That pushes the top of the playable volume 50 to 80 px above the
  board rect, behind the goal chip, exactly where a near-top-out stack is read. Aiming at the centre
  of the projected AABB keeps the whole stack inside the rect. The island floor moves about 75 px
  closer to the control row, without overlapping it. This is a few lines in `src/view/wt_stage.gd`
  and needs no addon. **Suggested story:** "Portrait framing: centre the projected board AABB in
  `board_area()`." It is a UI story, so it needs before/after evidence.
- The NEXT preview and the HOLD/THEN tray are 2D HUD. Both camera variants leave them unobstructed.
  The issue is the 3D stack running up under the HUD, not the HUD being cut off.
- phantom_camera's real value is camera **blending** (tweened yaw, results or pause shots).
  `src/view/camera_rig.gd` already wraps it but is unused. Decide whether to adopt `CameraRig` for
  that or retire it with the autoload.

### Evidence (retained)

```
production/qa/evidence/playtest-2026-10-14/addons/pcam_before_meadow_720x1280.png
production/qa/evidence/playtest-2026-10-14/addons/pcam_after_meadow_720x1280.png
production/qa/evidence/playtest-2026-10-14/addons/pcam_before_celestial_720x1280.png
production/qa/evidence/playtest-2026-10-14/addons/pcam_after_celestial_720x1280.png
```

Reproduce:

```bash
timeout 300 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
  --resolution 720x1280 res://prototypes/camera_pcam/pcam_framing_capture.tscn
```

## Open decisions (for the user / producer)

1. GodotSteam: exclude from Android and Web presets, or remove? (106 MB, unused.)
2. TileMapLayer3D and xesa: remove? (Unused; xesa ships in exports.)
3. MCP: fix `.mcp.json` to the Linux form, and enable the toolkit or stay on godot_ai only?
4. phantom_camera: adopt `CameraRig` for blends, or retire it plus the `PhantomCameraManager` autoload?
5. Open the WtStage centring story?
