#!/usr/bin/env python3
"""Register authored campaign levels that are missing from the catalog.

Usage: python3 tools/content/register_campaign_levels.py [--names production/qa/level-team-remixes-a.md ...]

For every src/levels/<biome>/<id>/<id>.json whose id is not in
assets/data/campaign/catalog.json, this writes the presentation scene
(<id>.tscn, the level_stage_base instance every official level uses) when it is
missing and inserts a catalog entry after the biome's highest existing tier.
English display names come from the level-team QA tables (| id | name | ...).
It never edits or removes existing entries.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "assets/data/campaign/catalog.json"
SCENE = """[gd_scene format=3]

[ext_resource type="PackedScene" path="res://src/levels/_template/level_stage_base.tscn" id="1"]
[ext_resource type="Script" uid="uid://bget2chj4yyf3" path="res://src/view/wt_stage.gd" id="2"]

[node name="{id}" instance=ExtResource("1")]
level_json = "res://src/levels/{biome}/{id}/{id}.json"
biome = &"{biome}"

[node name="MascotSpot" parent="." index="1"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 0, 2)

[node name="World" type="Node3D" parent="." index="2"]
script = ExtResource("2")

[node name="StoryOrigin" type="Marker3D" parent="World" index="0"]
"""


def display_names(paths: list[Path]) -> dict[str, str]:
    names: dict[str, str] = {}
    for path in paths:
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            cells = [cell.strip().strip("`*") for cell in line.strip().strip("|").split("|")]
            if len(cells) >= 2 and re.fullmatch(r"[a-z]+_(h\d|bonus)", cells[0]):
                names[cells[0]] = cells[1]
    return names


def main(argv: list[str]) -> int:
    name_files = [ROOT / arg for arg in argv[argv.index("--names") + 1:]] if "--names" in argv else sorted((ROOT / "production/qa").glob("level-team-remixes-*.md"))
    names = display_names(name_files)
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    known = {entry["id"] for entry in catalog["levels"]}
    added: list[str] = []
    for biome in catalog["biomes"]:
        for source in sorted((ROOT / "src/levels" / biome).glob("*/*.json")):
            level_id = source.stem
            if level_id in known or source.parent.name != level_id:
                continue
            level = json.loads(source.read_text(encoding="utf-8"))
            scene = source.with_suffix(".tscn")
            if not scene.exists():
                scene.write_text(SCENE.format(id=level_id, biome=biome), encoding="utf-8")
            tier = int(level["tier"])
            suffix = "BONUS" if tier == 11 else level_id.split("_")[-1].upper()
            entry = {"id": level_id, "biome": biome, "tier": tier, "name": names.get(level_id, level_id.replace("_", " ").title()),
                     "name_key": level.get("name", f"LVL_{biome.upper()}_{suffix}_TITLE"),
                     "json": f"res://src/levels/{biome}/{level_id}/{level_id}.json",
                     "scene": f"res://src/levels/{biome}/{level_id}/{level_id}.tscn",
                     "bonus": tier >= 11, "status": "Authored; awaiting playtest", "unsupported": [], "blocking_gameplay": []}
            position = max((i for i, e in enumerate(catalog["levels"]) if e["biome"] == biome and int(e["tier"]) < tier), default=len(catalog["levels"]) - 1) + 1
            catalog["levels"].insert(position, entry)
            known.add(level_id)
            added.append(level_id)
    CATALOG.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("registered", len(added), "levels:", ", ".join(added))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
