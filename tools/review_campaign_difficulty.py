#!/usr/bin/env python3
"""Independent static campaign audit. Estimates are not player playtest data."""
from __future__ import annotations

import collections
import hashlib
import json
import math
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "production/qa/campaign-difficulty-audit-2026-10-10.json"


def shape_counts() -> dict[str, int]:
    result = {}
    for block in (ROOT / "assets/data/shapes/shape_bank.tres").read_text().split("[sub_resource"):
        name = re.search(r'shape_id = &"([^"]+)"', block)
        count = re.search(r"cube_count = (\d+)", block)
        if name and count:
            result[name[1]] = int(count[1])
    return result


def audit() -> dict:
    manifest = json.loads((ROOT / "assets/data/campaign/catalog.json").read_text())
    defs = {
        knob["id"]: knob
        for path in sorted((ROOT / "assets/data/knobs").glob("*.json"))
        for knob in json.loads(path.read_text()).get("knobs", [])
    }
    defaults = {key: value.get("default") for key, value in defs.items()}
    counts = shape_counts()
    rows, issues, groups, families = [], [], collections.defaultdict(list), collections.defaultdict(list)
    previous: dict[str, set[str]] = collections.defaultdict(set)
    for entry in manifest["levels"]:
        path = ROOT / entry["json"].removeprefix("res://")
        data = json.loads(path.read_text())
        knobs = defaults | data.get("knobs", {})
        board, pieces, goal, stars = data["board"], data["pieces"], data["goal"], data["stars"]
        rule_ids = [rule["id"] for rule in data.get("rules", [])]
        tier, biome = data["tier"], data["biome"]
        # Normalize defaults and discard authored length estimates that goal evaluation does not read.
        physics_goal = dict(goal)
        for key in ("T_level", "T", "ramp_per_min"):
            physics_goal.pop(key, None)
        physics_board = {"down_axis": "-y"} | board
        physics_pieces = dict(pieces)
        physics_pieces["shapes"] = sorted(physics_pieces.get("shapes", []))
        gameplay = {"board": physics_board, "pieces": physics_pieces, "knobs": knobs,
                    "goal": physics_goal, "rules": data.get("rules", [])}
        fingerprint = hashlib.sha256(json.dumps(gameplay, sort_keys=True).encode()).hexdigest()
        groups[fingerprint].append(data["id"])
        family = [goal["type"], rule_ids, knobs.get("spawn.arrival"), knobs.get("clear.detector"),
                  knobs.get("clear.collapse"), knobs.get("control.verb")]
        families[json.dumps(family, sort_keys=True)].append(data["id"])
        for key, value in data.get("knobs", {}).items():
            definition = defs.get(key, {})
            if isinstance(value, (int, float)) and not isinstance(value, bool):
                if ("min" in definition and value < definition["min"]) or ("max" in definition and value > definition["max"]):
                    issues.append({"id": data["id"], "issue": "knob_range", "field": key, "value": value})
        clearance = int(defaults.get("board.spawn_clearance", 6))
        physical = [board["width"], board["h_play"] + clearance, board["depth"]]
        down = board.get("down_axis", "-y")
        axis = {"x": 0, "y": 1, "z": 2}[down[-1]]
        plane_area = math.prod(physical[i] for i in range(3) if i != axis)
        mask = board.get("mask")
        if axis == 1 and isinstance(mask, list):
            plane_area = sum(ch != "." for row in mask for ch in row)
        target = sum(ch != "." for rows_value in goal.get("target_shape", {}).get("layers", {}).values()
                     for row in rows_value for ch in row)
        threshold = int(goal.get("win_correct", target)) if target else 0
        supply = pieces.get("fixed_list") or pieces.get("kit") or []
        raw_volume = sum(counts.get(item if isinstance(item, str) else item.get("shape", ""), 0) for item in supply)
        mirrored = "mirror" in rule_ids
        max_volume = raw_volume * (2 if mirrored else 1)
        if supply and threshold and max_volume < threshold:
            issues.append({"id": data["id"], "issue": "finite_volume_shortfall", "available": max_volume, "needed": threshold})
        if goal["type"] == "survive" and ("t2" in stars or "t3" in stars):
            issues.append({"id": data["id"], "issue": "fixed_survival_time_stars", "survival_ms": goal.get("t_ms"), "stars": stars})
        if "t2" in stars and "t3" in stars and not 0 < stars["t3"] < stars["t2"]:
            issues.append({"id": data["id"], "issue": "time_star_order", "stars": stars})
        if "s2" in stars and "s3" in stars and not 0 < stars["s2"] < stars["s3"]:
            issues.append({"id": data["id"], "issue": "metric_star_order", "stars": stars})
        new_rules = sorted(set(rule_ids) - previous[biome]) if tier <= 10 else []
        if tier <= 10:
            previous[biome].update(rule_ids)
        g0 = float(knobs.get("fall.g0", 1.0))
        row = {"id": data["id"], "source": str(path.relative_to(ROOT)), "biome": biome, "tier": tier,
               "physical_dimensions": physical, "declared_down_axis": down, "declared_plane_area": plane_area,
               "declared_danger_layer": physical[axis] - clearance, "g0_cells_s": g0,
               "g0_campaign_default": round(.6 + .045 * (min(tier, 10) - 1) + .06 * manifest["biomes"].index(biome), 3),
               "lock_delay_ms": knobs.get("fall.lock_delay_ms"), "hard_drop_grace_ms": knobs.get("fall.hard_drop_grace_ms"),
               "entry_delay_ms": knobs.get("fall.entry_delay_ms"), "goal": goal, "stars": stars,
               "rule_ids": rule_ids, "new_biome_rule_ids": new_rules, "finite_pieces": len(supply),
               "raw_supply_cubes": raw_volume, "max_supply_with_mirror": max_volume, "target_cells": target,
               "target_threshold": threshold, "fingerprint": fingerprint,
               "metadata_blockers": data.get("metadata", {}).get("blocking_gameplay", [])}
        if goal["type"] == "clear_n" and axis != 1 and not mask:
            row["empty_board_standard_piece_estimate"] = int(goal.get("n", 0)) * plane_area / 4.0
            row["eight_second_piece_estimate_s"] = row["empty_board_standard_piece_estimate"] * 8
        rows.append(row)
    return {"schema": 1, "method": "Static data/source audit; no player success-rate or timing observations.",
            "level_count": len(rows), "main_count": sum(row["tier"] <= 10 for row in rows),
            "distinct_gameplay_fingerprints": len(groups), "distinct_rule_goal_families": len(families),
            "identical_gameplay_groups": [group for group in groups.values() if len(group) > 1],
            "reused_rule_goal_families": [group for group in families.values() if len(group) > 1],
            "issues": issues, "levels": rows}


if __name__ == "__main__":
    report = audit()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({key: report[key] for key in ("level_count", "main_count", "distinct_gameplay_fingerprints", "distinct_rule_goal_families", "issues")}))
