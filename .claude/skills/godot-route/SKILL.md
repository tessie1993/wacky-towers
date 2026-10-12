---
description: Route a Godot or game-development task to the smallest relevant skill in the vendored Godot Game Dev Studio library (tools/vendor/godot-game-dev-studio). Use before broad Godot planning, implementation, debugging or review, or when asked which Godot skill to use.
---

Route this task through the library before doing any implementation. The library root is `tools/vendor/godot-game-dev-studio/` (git submodule, ignored by Godot via `tools/vendor/.gdignore`).

1. Read `tools/vendor/godot-game-dev-studio/skills_index.json`; use `tools/vendor/godot-game-dev-studio/SKILL_CATALOG.md` only if needed.
2. Choose the smallest relevant skill set: normally one skill, never more than three.
3. Read every selected `tools/vendor/godot-game-dev-studio/skills/<skill-name>/SKILL.md` fully.
4. Read only files those skills directly require.
5. State the selected skills, then continue the requested work.

Skill families: `studio-*` orchestration and production; `godot-*` Godot systems, APIs, debugging, optimisation; `godot-prompter-*` guided implementation workflows; `gamedev-*` genre and design workflows.

Project rules win over library advice: Godot 4.7.2 (check `docs/engine-reference/godot/`), statically typed GDScript, accepted ADRs in `docs/architecture/`, and the CLAUDE.md collaboration protocol. Preserve attribution in `tools/vendor/godot-game-dev-studio/NOTICE.md` and `tools/vendor/godot-game-dev-studio/LICENSE` (LGPL-3.0).
