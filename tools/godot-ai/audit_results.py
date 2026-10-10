"""Preserve compact, credential-free proof of actual editor-addon calls."""
import json
from collections import Counter
from pathlib import Path

repo = Path(__file__).resolve().parents[2]
calls = []
counts = Counter()
jobs = []
for path in sorted((repo / "tools/godot-ai/results").glob("*.json")):
    result = json.loads(path.read_text())
    if "actions" not in result:
        continue
    jobs.append({"id": result["id"], "status": result["status"], "result": str(path.relative_to(repo))})
    for action in result["actions"]:
        arguments = action["arguments"]
        response = action["result"]
        data = response.get("data") or response.get("structured_content") or {}
        target = arguments.get("path", arguments.get("params", {}).get("path", ""))
        item = {"job": result["id"], "tool": action["tool"], "target": target,
                "is_error": response.get("is_error", False)}
        if isinstance(data, dict):
            item["diagnostics"] = data.get("diagnostics", [])
            for key in ("committed", "saved", "success", "replacements", "reloaded", "diagnostics_status"):
                if key in data:
                    item[key] = data[key]
        if response.get("is_error"):
            item["error"] = response.get("text", "")[:1800]
        if action["tool"] == "batch_execute":
            item["native_commands"] = [entry.get("command", entry.get("tool", "")) for entry in arguments.get("commands", [])]
        calls.append(item)
        counts[action["tool"]] += 1
output = {"schema": 1, "engine": "4.7.2", "addon": "godot_ai 4.3.0",
          "server": "godot-ai 4.3.0", "transport": "authenticated MCP HTTP + editor WebSocket v2",
          "call_count": len(calls), "tools": dict(sorted(counts.items())), "jobs": jobs, "calls": calls}
path = repo / "production/qa/godot-ai-authoring-evidence-2026-10-10.json"
path.write_text(json.dumps(output, indent=2) + "\n")
print(json.dumps({"calls": len(calls), "tools": dict(counts), "scene_jobs_ok": sum(j["status"] == "ok" for j in jobs if j["id"].startswith("scenes-"))}))
