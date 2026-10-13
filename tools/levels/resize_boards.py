#!/usr/bin/env python3
"""Grow every single-board campaign level to at least an 8x8 footprint.

User decision 2026-10-13: "If only one grid is in a level make it 8x8 gameplay or
bigger." (board-grid GDD: W, D are 4+ with no max; layer-clearing default 8x8.)

Padding is symmetric so mirror/turntable puzzles keep their centre: a side under 8
grows to 8 when the gap is even, else 9. Square boards stay square. Every cell
coordinate (layer strings, masks, rule params, goal targets, packing proofs) is
shifted by the same offset. clear_n goals and time stars are re-scaled so a level
asks for at most CLEAR_BUDGET times its original cube volume.

Usage: python3 tools/levels/resize_boards.py [--dry-run]
"""
import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "assets/data/campaign/catalog.json"
PROOFS = ROOT / "assets/data/campaign/puzzle_proofs.json"
MIN_SIDE = 8
# A resized clear level may ask for up to this many times its original cube count.
CLEAR_BUDGET = 1.6
# Count-star targets (clears) scale with the same per-layer volume ratio.
CENTRED_RULES = ("mirror", "turntable", "spin", "rotate")
SKIP_DOWN_AXES = {"-x", "+x", "-z", "+z"}  # sideways gravity frames are hand-tuned


def grown(side: int, centred: bool) -> int:
    if side >= MIN_SIDE:
        return side
    if not centred:
        return MIN_SIDE
    return MIN_SIDE if (MIN_SIDE - side) % 2 == 0 else MIN_SIDE + 1


def pad_rows(rows, ox, oz, new_w, new_d, fill):
    width = len(rows[0]) if rows else 0
    out = [fill * new_w for _ in range(oz)]
    for row in rows:
        out.append(fill * ox + row + fill * (new_w - width - ox))
    while len(out) < new_d:
        out.append(fill * new_w)
    return out


def shift_layers(block, ox, oz, new_w, new_d, fill="."):
    if isinstance(block, dict) and "layers" in block:
        block["layers"] = {k: pad_rows(v, ox, oz, new_w, new_d, fill) for k, v in block["layers"].items()}
    return block


def shift_xyz(v, ox, oz):
    return [v[0] + ox, v[1], v[2] + oz]


def shift_param(rule_id, key, value, ox, oz, old_w, new_w):
    if key in ("cells",) and isinstance(value, list):
        return [shift_xyz(c, ox, oz) for c in value]
    if key == "cell" and isinstance(value, list) and len(value) == 3:
        return shift_xyz(value, ox, oz)
    if key == "tiles" and isinstance(value, list):
        return [[t[0] + ox, t[1] + oz] for t in value]
    if key == "magnet_col" and isinstance(value, list):
        x = new_w - 1 if value[0] == old_w - 1 else value[0] + ox  # edge magnets stay on the edge
        return [x, value[1] + oz]
    if key == "band_rows" and isinstance(value, list):
        return [r + oz for r in value]
    return value


def resize(level, proofs_by_id):
    board = level["board"]
    if board.get("down_axis", "-y") in SKIP_DOWN_AXES:
        return None
    w, d = board["width"], board["depth"]
    # Mirror and turntable rules act about the board centre, so those boards pad evenly.
    centred = any(k in r["id"] for r in level.get("rules", []) for k in CENTRED_RULES)
    nw, nd = grown(w, centred), grown(d, centred)
    if w == d:
        nw = nd = max(nw, nd)
    if (nw, nd) == (w, d):
        return None
    ox, oz = (nw - w) // 2, (nd - d) // 2
    board["width"], board["depth"] = nw, nd
    if "starting_contents" in board:
        shift_layers(board["starting_contents"], ox, oz, nw, nd)
    if "mask" in board:
        board["mask"] = pad_rows(board["mask"], ox, oz, nw, nd, "#")
    if "spawn_anchor" in board:
        anchor = board["spawn_anchor"]
        if isinstance(anchor, dict):
            board["spawn_anchor"] = {"x": anchor["x"] + ox, "z": anchor["z"] + oz}
        else:
            board["spawn_anchor"] = [anchor[0] + ox, anchor[1] + oz]
    for rule in level.get("rules", []):
        params = rule.get("params", {})
        for key in list(params):
            params[key] = shift_param(rule["id"], key, params[key], ox, oz, w, nw)
    goal = level["goal"]
    if goal.get("type") == "shape":
        shift_layers(goal.get("target_shape"), ox, oz, nw, nd)
    for hole in goal.get("keyholes", []):
        hole["row"] = hole["row"] + (oz if hole["wall"] in ("-x", "+x") else ox)
    note = f"Board {w}x{d} -> {nw}x{nd} (offset x{ox} z{oz})"
    if goal.get("type") == "clear_n":
        old_area, new_area = w * d, nw * nd
        n = goal["n"]
        n_new = max(1, min(n, round(CLEAR_BUDGET * n * old_area / new_area)))
        goal["n"] = n_new
        ratio = (n_new * new_area) / (n * old_area)
        stars = level.get("stars", {})
        for key in ("t2", "t3"):
            if key in stars:
                stars[key] = int(round(stars[key] * ratio / 5000.0) * 5000)
        note += f"; clear_n {n} -> {n_new}; time stars x{ratio:.2f}"
    stars = level.get("stars", {})
    if "s2" in stars and "s3" in stars:
        scale = (w * d) / (nw * nd) * CLEAR_BUDGET
        s2, s3 = max(1, round(stars["s2"] * scale)), max(2, round(stars["s3"] * scale))
        stars["s2"], stars["s3"] = s2, max(s3, s2 + 1)
        note += f"; clear stars -> {stars['s2']}/{stars['s3']}"
    proof = proofs_by_id.get(level["id"])
    if proof:
        for place in proof.get("placements", []):
            place["pivot"] = shift_xyz(place["pivot"], ox, oz)
            place["cells"] = [shift_xyz(c, ox, oz) for c in place["cells"]]
            place["mirror_cells"] = [shift_xyz(c, ox, oz) for c in place.get("mirror_cells", [])]
    level.setdefault("metadata", {}).setdefault("design_amendments", []).append(
        {"date": "2026-10-13", "source": "user decision: single-board levels are 8x8 or bigger", "change": note})
    return note


def main():
    dry = "--dry-run" in sys.argv
    catalog = json.loads(CATALOG.read_text())
    proofs = json.loads(PROOFS.read_text())
    by_id = {p["id"]: p for p in proofs["proofs"]}
    for entry in catalog["levels"]:
        path = ROOT / entry["json"].replace("res://", "")
        level = json.loads(path.read_text())
        note = resize(level, by_id)
        if note:
            print(f"{level['id']}: {note}")
            if not dry:
                path.write_text(json.dumps(level, indent=2) + "\n")
    if not dry:
        PROOFS.write_text(json.dumps(proofs, indent=2) + "\n")


if __name__ == "__main__":
    main()
