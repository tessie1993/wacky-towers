# Native add-ons

These add-ons are native GDExtension binaries (~470 MB together). They are committed to git (user 2026-10-13), so a fresh clone has them — no per-machine install.

| Add-on | Version | Path | Source |
|---|---|---|---|
| Orchestrator (visual scripting, menus/level flow — ADR-0010) | 2.5.stable | `addons/orchestrator/` | Godot Asset Store, or https://github.com/CraterCrash/godot-orchestrator/releases/tag/v2.5.stable |
| GodotSteam GDExtension (PC/Steam — ADR-0008 am.1) | GDExtension build for Godot ≥ 4.4 (check `godotsteam.gdextension`) | `addons/godotsteam/` | Godot Asset Store, or https://godotsteam.com |

To upgrade one, replace its folder from the source above, open the editor once so it re-imports, and commit the folder.
