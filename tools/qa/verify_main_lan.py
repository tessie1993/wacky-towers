#!/usr/bin/env python3
"""Run four real Main scenes and compare per-player simulation checkpoints.

Pass the actual Linux Godot binary, not a wrapper which overrides XDG_DATA_HOME.
Each process gets a separate temporary user-data/config/cache directory. The
probe also injects a fresh MemorySaveIO-backed QA profile store after Main ready.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import tempfile
import time

parser = argparse.ArgumentParser()
parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
parser.add_argument("--output", required=True)
args = parser.parse_args()
repo = Path(__file__).resolve().parents[2]
output = Path(args.output).resolve()
output.mkdir(parents=True, exist_ok=True)
godot = shutil.which(args.godot) or str(Path(args.godot).resolve())
with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as reservation:
    reservation.bind(("127.0.0.1", 0))
    port = reservation.getsockname()[1]

with tempfile.TemporaryDirectory(prefix="main-lan-userdata-", dir=output) as directory:
    processes = []
    logs = []
    try:
        for role in ["Host", "ClientA", "ClientB", "ClientC"]:
            env = os.environ.copy()
            for variable, leaf in [("XDG_DATA_HOME", "data"), ("XDG_CONFIG_HOME", "config"), ("XDG_CACHE_HOME", "cache")]:
                folder = Path(directory) / role / leaf
                folder.mkdir(parents=True)
                env[variable] = str(folder)
            log = (output / (role + ".log")).open("w")
            logs.append(log)
            result_path = output / (role + ".json")
            if result_path.exists():
                result_path.unlink()
            command = [godot, "--headless", "--path", str(repo), "--max-fps", "90", "--audio-driver", "Dummy", "-s", "res://tests/integration/net/main_lan_probe.gd", "--", "--role", role, "--port", str(port), "--output", str(result_path)]
            command += ["--host"] if role == "Host" else ["--join", "127.0.0.1"]
            processes.append((role, subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT)))
            if role == "Host":
                time.sleep(0.5)
        outcomes = [{"role": role, "exit_code": process.wait(timeout=90)} for role, process in processes]
        for log in logs:
            log.flush()
        reports = {}
        passed = True
        for outcome in outcomes:
            role = outcome["role"]
            text = (output / (role + ".log")).read_text()
            passed = passed and outcome["exit_code"] == 0 and "MAIN_LAN_PASS" in text and "MAIN_LAN_FAIL" not in text and "SCRIPT ERROR" not in text
            report_path = output / (role + ".json")
            if report_path.exists():
                reports[role] = json.loads(report_path.read_text())
        if len(reports) == 4:
            reference = reports["Host"]
            for report in reports.values():
                passed = passed and report["seed"] == reference["seed"] and report["players"] == reference["players"] and report["checkpoints"] == reference["checkpoints"] and report["hashes"] == reference["hashes"] and report["orientations"] == reference["orientations"]
                expected_character = {"c1": "cloud", "c2": "lana", "c3": "boulder", "c4": "glim"}[report["requested_character"]]
                passed = passed and report["effective_character"] == expected_character and report["loadouts"] == reference["loadouts"]
            passed = passed and len(set(reference["hashes"].values())) == 4
        else:
            passed = False
        report = {"passed": passed, "transport": "Real Main scenes over ENet UDP localhost", "independent_processes": 4, "frames": 540, "checkpoint_comparisons_per_process": 18, "distinct_player_characters": 4, "owned_perks_per_player": 1, "same_identity_hash_compared_across_devices": True, "port": port, "outcomes": outcomes}
        (output / "result.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report), flush=True)
        raise SystemExit(0 if passed else 1)
    finally:
        for _, process in processes:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
        for log in logs:
            log.close()
