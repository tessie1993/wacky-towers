# Technical Preferences

<!-- project.yaml at the repo root is the machine-readable source of truth for
     engine, specialists, naming, performance, platform, and testing.framework.
     This file is the human-readable LEGACY FALLBACK: agents and skills resolve
     each key from project.yaml first and fall back here only when the
     project.yaml key is absent. /setup-engine dual-writes both.
     Forbidden patterns and allowed libraries are NOT migrated — they live only
     in this file. Populated by /setup-engine; updated as decisions are made. -->

## Engine & Language

- **Engine**: Godot 4.7.2 (installed: 4.7.2.stable.official, D:/TESSA/Godot_v4.7.2-stable_win64.exe (2)/)
- **Language**: GDScript (gameplay/UI scripting), C# (performance-critical systems), C++ via GDExtension (native only)
- **Rendering**: Mobile renderer (matches project.godot)
- **Physics**: Jolt (3D). Final physics configuration is an ADR.
- **Asset tool**: Blender, exported as glTF/GLB into the Godot import pipeline
- **Godot project folder**: `wacky-towers/` (holds project.godot)

## Input & Platform

- **Target Platforms**: Mobile (iOS, Android)
- **Input Methods**: Touch
- **Primary Input**: Touch
- **Gamepad Support**: None
- **Touch Support**: Full
- **Platform Notes**: 3D rotation on a phone is the biggest usability risk (see design/gdd/touch-controls.md). Local multiplayer uses one device per player over LAN, plus a 2-player shared-tablet split.

## Naming Conventions

Use GDScript conventions for `.gd` files and C# conventions for `.cs` files; the boundary is per-file.

- **Classes**: PascalCase (GDScript `PlayerController`; C# also `partial`)
- **Variables**: snake_case in GDScript (`move_speed`); C# public PascalCase, private `_camelCase`
- **Signals/Events**: snake_case past tense in GDScript (`health_changed`); C# PascalCase + `EventHandler` suffix
- **Files**: snake_case in GDScript (`player_controller.gd`); PascalCase in C# (`PlayerController.cs`)
- **Scenes/Prefabs**: snake_case for GDScript scenes; PascalCase matching root node for C# scenes
- **Constants**: UPPER_SNAKE_CASE in GDScript; PascalCase in C#

## Performance Budgets

- **Target Framerate**: 60 fps
- **Frame Budget**: 16.6 ms
- **Draw Calls**: [TO BE CONFIGURED — set once the reference phone is chosen]
- **Memory Ceiling**: [TO BE CONFIGURED]

## Testing

- **Framework**: gdUnit4
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: Balance formulas, gameplay systems, networking (if applicable)

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- [None configured yet — libraries (e.g. Jolt settings, addons) are added when needed]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]

## Engine Specialists

- **Primary**: godot-specialist
- **GDScript Specialist**: godot-gdscript-specialist (.gd files — gameplay/UI scripts)
- **C# Specialist**: godot-csharp-specialist (.cs files — performance-critical systems)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist — primary covers all UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for cross-language architecture decisions and which systems belong in which language. Invoke GDScript specialist for .gd files. Invoke C# specialist for .cs files and .csproj management. Prefer signals over direct cross-language method calls at the boundary.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Game code (.cs files) | godot-csharp-specialist |
| Cross-language boundary decisions | godot-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Project config (.csproj, NuGet) | godot-csharp-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
