#!/usr/bin/env python3
"""Verify four independent Godot/ENet processes on real localhost UDP sockets.

Usage: GODOT_BIN=/path/to/godot python tools/qa/verify_lan.py --output /path/to/evidence
The fixture is isolated from editor addons and cleans up all subprocesses.
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
parser.add_argument("--scenario", choices=["normal", "disconnect"], default="normal")
args = parser.parse_args()
repo = Path(__file__).resolve().parents[2]
output = Path(args.output).resolve()
output.mkdir(parents=True, exist_ok=True)
godot = shutil.which(args.godot) or str(Path(args.godot).resolve())

with tempfile.TemporaryDirectory(prefix="lan-fixture-", dir=output) as directory:
    fixture = Path(directory)
    (fixture / "project.godot").write_text('config_version=5\n[application]\nconfig/name="LAN Verification"\n')
    (fixture / "src/net").mkdir(parents=True)
    shutil.copyfile(repo / "src/net/lan_session.gd", fixture / "src/net/lan_session.gd")
    (fixture / "assets/data/shop").mkdir(parents=True)
    shutil.copyfile(repo / "assets/data/shop/catalog.json", fixture / "assets/data/shop/catalog.json")
    shutil.copyfile(repo / "tests/integration/net/lan_process_probe.gd", fixture / "probe.gd")
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as reservation:
        reservation.bind(("127.0.0.1", 0))
        port = reservation.getsockname()[1]
    processes = []
    files = []
    try:
        for role in ["host", "ClientA", "ClientB", "ClientC"]:
            log = (output / (role + ".log")).open("w")
            files.append(log)
            process = subprocess.Popen([godot, "--headless", "--path", str(fixture), "--max-fps", "60", "-s", "res://probe.gd", "--", role, str(port), args.scenario], stdout=log, stderr=subprocess.STDOUT)
            processes.append((role, process))
            if role == "host":
                time.sleep(0.3)
        outcomes = []
        for role, process in processes:
            code = process.wait(timeout=18)
            outcomes.append({"role": role, "exit_code": code})
        for log in files:
            log.flush()
        passed = True
        for item in outcomes:
            text = (output / (item["role"] + ".log")).read_text()
            passed = passed and item["exit_code"] == 0 and "LAN_PROBE_PASS" in text and "LAN_PROBE_FAIL" not in text and "SCRIPT ERROR" not in text
        report = {"passed": passed, "transport": "ENet UDP on localhost", "scenario": args.scenario, "independent_processes": 4, "port": port, "outcomes": outcomes}
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
        for log in files:
            log.close()
