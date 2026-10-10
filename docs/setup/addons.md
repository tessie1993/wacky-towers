# Add-ons installed per machine

These add-ons are native GDExtension binaries (~470 MB together), so they are not in git (see `.gitignore`). Install them on each machine before opening the project.

| Add-on | Version | Install to | Source |
|---|---|---|---|
| Orchestrator (visual scripting, menus/level flow — ADR-0010) | 2.5.stable | `addons/orchestrator/` | Godot Asset Store, or https://github.com/CraterCrash/godot-orchestrator/releases/tag/v2.5.stable |
| GodotSteam GDExtension (PC/Steam — ADR-0008 am.1) | GDExtension build for Godot ≥ 4.4 (check `godotsteam.gdextension`) | `addons/godotsteam/` | Godot Asset Store, or https://godotsteam.com |

After installing, open the editor once so it imports them, then enable each in Project → Project Settings → Plugins if it isn't already.
