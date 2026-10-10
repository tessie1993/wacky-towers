#!/usr/bin/env python3
"""Expose the authored Neon Mono's sole cube as a GLB scene root, without changing mesh bytes."""
import json
import struct
from pathlib import Path

root = Path(__file__).resolve().parents[2]
folder = root / "assets/models/blocks/neon_voxel"
source = folder / "blk_neon_voxel_mono.glb"
raw = source.read_bytes()
length, chunk_type = struct.unpack_from("<II", raw, 12)
document = json.loads(raw[20:20 + length])
assert document["nodes"][0].get("mesh") == 0
assert document["nodes"][1].get("children") == [0]
document["nodes"][0]["name"] = "blk_neon_voxel_cube"
document["nodes"][0]["extras"] = {
    "derived_from": source.name, "look": "neon_voxel", "shape": "cube", "cubes": 1
}
document["scenes"][document.get("scene", 0)]["nodes"] = [0]
chunk = json.dumps(document, separators=(",", ":")).encode()
chunk += b" " * ((-len(chunk)) % 4)
remainder = raw[20 + length:]
total = 12 + 8 + len(chunk) + len(remainder)
result = struct.pack("<III", 0x46546C67, 2, total)
result += struct.pack("<II", len(chunk), chunk_type) + chunk + remainder
(folder / "blk_neon_voxel_cube.glb").write_bytes(result)
