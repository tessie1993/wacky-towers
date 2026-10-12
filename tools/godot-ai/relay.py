#!/usr/bin/env python3
"""Local job relay through actual Godot AI MCP tools and its live editor addon.

Run with the matching godot-ai virtualenv Python. Xvfb, server, editor and
client share one process/network namespace; jobs contain no credentials.
"""
import argparse
import asyncio
import json
import os
from pathlib import Path
import random
import socket
import subprocess
import time

from fastmcp import Client
from fastmcp.client.transports import StreamableHttpTransport


def result_data(result):
    if hasattr(result, "model_dump"):
        return result.model_dump(mode="json")
    return {"data": getattr(result, "data", None),
        "structured_content": getattr(result, "structured_content", None),
        "is_error": getattr(result, "is_error", False),
        "text": str(result)}


async def relay(project, tool_root, lifetime):
    jobs = project / "tools/godot-ai/jobs"
    results = project / "tools/godot-ai/results"
    evidence = project / "reports/godot-ai"
    for directory in (jobs, results, evidence):
        directory.mkdir(parents=True, exist_ok=True)
    (jobs / "STOP").unlink(missing_ok=True)
    (results / "READY.json").unlink(missing_ok=True)
    usr = tool_root / "display/usr"
    display = random.randrange(110, 190)
    env = os.environ.copy()
    env.update(DISPLAY=f"localhost:{display}",
        LD_LIBRARY_PATH=str(usr / "lib/x86_64-linux-gnu"),
        PATH=str(usr / "bin") + ":" + env["PATH"],
        TMPDIR=str(tool_root / "display/tmp"),
        LIBGL_DRIVERS_PATH=str(usr / "lib/x86_64-linux-gnu/dri"),
        LIBGL_ALWAYS_SOFTWARE="1",
        VK_ICD_FILENAMES=str(usr / "share/vulkan/icd.d/lvp_icd.json"),
        __EGL_VENDOR_LIBRARY_FILENAMES=str(usr / "share/glvnd/egl_vendor.d/50_mesa.json"),
        GODOT_AI_VENV_PYTHON=str(tool_root / "godotai-venv/bin/python"),
        GODOT_AI_CAPABILITY_DIR=str(tool_root / "godot-home/config/godot-ai/capabilities"),
        GODOT_AI_DISABLE_TELEMETRY="true",
        FASTMCP_CHECK_FOR_UPDATES="off",
        NO_PROXY="127.0.0.1,localhost")
    os.environ["NO_PROXY"] = env["NO_PROXY"]
    handles = []
    processes = []
    def spawn(name, args, cwd=None):
        handle = (evidence / (name + ".log")).open("w")
        handles.append(handle)
        process = subprocess.Popen(args, cwd=cwd, env=env, stdout=handle,
            stderr=subprocess.STDOUT, start_new_session=True)
        processes.append(process)
        return process
    try:
        xvfb = spawn("xvfb", [str(usr / "bin/Xvfb"), f":{display}", "-screen", "0",
            "1280x720x24", "-nolock", "-nolisten", "unix", "-nolisten", "local",
            "-listen", "tcp", "-ac", "-noreset", "-xkbdir", str(usr / "share/X11/xkb")], usr)
        for _ in range(80):
            if xvfb.poll() is not None:
                raise RuntimeError("Xvfb failed; see reports/godot-ai/xvfb.log")
            try:
                with socket.create_connection(("127.0.0.1", 6000 + display), timeout=.1):
                    pass
                break
            except OSError:
                await asyncio.sleep(.1)
        server = spawn("server", [env["GODOT_AI_VENV_PYTHON"], "-m", "godot_ai",
            "--transport", "streamable-http", "--port", "8000", "--ws-port", "9500"])
        record_path = Path(env["GODOT_AI_CAPABILITY_DIR"]) / "http-8000.json"
        for _ in range(120):
            if server.poll() is not None:
                raise RuntimeError("Server failed; see reports/godot-ai/server.log")
            if record_path.exists():
                break
            await asyncio.sleep(.5)
        # A record from a previous clean session may still exist. Wait for
        # this child listener before reading its freshly published record.
        for _ in range(120):
            if server.poll() is not None:
                raise RuntimeError("Server exited before HTTP listener became ready")
            try:
                with socket.create_connection(("127.0.0.1", 8000), timeout=.1):
                    pass
                break
            except OSError:
                await asyncio.sleep(.25)
        else:
            raise RuntimeError("Local MCP HTTP listener did not become ready")
        record = json.loads(record_path.read_text())
        editor = spawn("editor", [str(tool_root / "bin/godot"), "--editor", "--path",
            str(project), "--rendering-method", "gl_compatibility", "--audio-driver", "Dummy",
            "--windowed", "--resolution", "1280x720", "--position", "0,0"])
        transport = StreamableHttpTransport("http://127.0.0.1:8000/mcp",
            headers={"Authorization": "Bearer " + record["http"]})
        async with Client(transport, timeout=310) as client:
            for attempt in range(180):
                if editor.poll() is not None:
                    raise RuntimeError("Editor failed; see reports/godot-ai/editor.log")
                sessions = await client.call_tool("session_manage", {"op": "list", "params": {}})
                raw = result_data(sessions)
                payload = getattr(sessions, "data", {})
                if (isinstance(payload, dict) and payload.get("count", 0) > 0) or '"count": 1' in json.dumps(raw):
                    break
                await asyncio.sleep(1)
            else:
                raise RuntimeError("Editor addon did not connect in 180 seconds")
            tools = await client.list_tools()
            catalog = [{"name": item.name, "description": item.description,
                "inputSchema": item.input_schema} for item in tools]
            (evidence / "tool_catalog.json").write_text(json.dumps(catalog, indent=2))
            connection = {"plugin_version": "4.3.0", "server_version": "4.3.0",
                "godot_version": "4.7.2", "transport": "authenticated Streamable HTTP + editor WebSocket v2",
                "session_list": raw, "started_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "tool_count": len(catalog)}
            state = await client.call_tool("editor_state", {})
            connection["editor_state"] = result_data(state)
            (evidence / "connection.json").write_text(json.dumps(connection, indent=2))
            (results / "READY.json").write_text(json.dumps(connection, indent=2))
            print(json.dumps({"ready": True, "tools": len(catalog), "jobs": str(jobs)}), flush=True)
            deadline = time.monotonic() + lifetime
            with (evidence / "tool_calls.jsonl").open("a") as transcript:
                while time.monotonic() < deadline and not (jobs / "STOP").exists():
                    if editor.poll() is not None:
                        raise RuntimeError("Live editor exited; pending jobs remain unconsumed")
                    for job_path in sorted(jobs.glob("*.json")):
                        result_path = results / job_path.name
                        if result_path.exists():
                            continue
                        try:
                            job = json.loads(job_path.read_text())
                        except (OSError, json.JSONDecodeError):
                            continue
                        output = {"id": job.get("id", job_path.stem), "status": "ok", "actions": []}
                        for action in job.get("actions", []):
                            name = action["tool"]
                            arguments = action.get("arguments", {})
                            try:
                                reply = await client.call_tool(name, arguments, raise_on_error=False)
                                data = result_data(reply)
                                entry = {"tool": name, "arguments": arguments, "result": data}
                                if getattr(reply, "is_error", False) or data.get("isError", False):
                                    output["status"] = "error"
                            except Exception as exc:
                                entry = {"tool": name, "arguments": arguments,
                                    "error": type(exc).__name__ + ": " + str(exc)}
                                output["status"] = "error"
                            output["actions"].append(entry)
                            transcript.write(json.dumps({"job": output["id"], **entry}) + "\n")
                            transcript.flush()
                            print(json.dumps({"job": output["id"], "tool": name,
                                "status": output["status"]}), flush=True)
                            # Fresh script registration and explicit scans can finish their
                            # response before Godot's class-progress task tears down.
                            # Separate writes across editor frames rather than overlap scans.
                            if name in ("script_create", "script_patch") or (name == "filesystem_manage" and arguments.get("op") == "scan"):
                                await asyncio.sleep(2)
                            if output["status"] != "ok" and not job.get("continue_on_error", False):
                                break
                        temporary = result_path.with_suffix(".tmp")
                        temporary.write_text(json.dumps(output, indent=2))
                        temporary.replace(result_path)
                    await asyncio.sleep(.25)
            await client.call_tool("project_manage", {"op": "stop", "params": {}}, raise_on_error=False)
            await client.call_tool("editor_manage", {"op": "quit", "params": {}}, raise_on_error=False)
    finally:
        for process in reversed(processes):
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=8)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
        for handle in handles:
            handle.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", required=True)
    parser.add_argument("--tool-root", required=True)
    parser.add_argument("--lifetime", type=int, default=3600)
    args = parser.parse_args()
    asyncio.run(relay(Path(args.project).resolve(), Path(args.tool_root).resolve(), args.lifetime))
