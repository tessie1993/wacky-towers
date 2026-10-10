#!/usr/bin/env python3
"""Inspect a real exported APK; does not claim emulator/device execution."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--apk", required=True)
parser.add_argument("--output", required=True)
parser.add_argument("--sdk", default=os.environ.get("ANDROID_HOME"))
parser.add_argument("--java", default=os.environ.get("JAVA_HOME"))
parser.add_argument("--build-tools", default="35.0.1")
args = parser.parse_args()
if not args.sdk or not args.java:
    parser.error("Set ANDROID_HOME and JAVA_HOME or pass --sdk/--java")
apk = Path(args.apk).resolve()
output = Path(args.output).resolve()
output.mkdir(parents=True, exist_ok=True)
sdk = Path(args.sdk).resolve()
java = Path(args.java).resolve()
tools = sdk / "build-tools" / args.build_tools
env = os.environ.copy()
env["JAVA_HOME"] = str(java)
env["PATH"] = str(java / "bin") + os.pathsep + env.get("PATH", "")
env["LD_LIBRARY_PATH"] = os.pathsep.join([str(java / "lib"), str(tools / "lib64"), env.get("LD_LIBRARY_PATH", "")])
commands = {
    "signing": [str(tools / "apksigner"), "verify", "--verbose", "--print-certs", str(apk)],
    "alignment": [str(tools / "zipalign"), "-c", "-P", "16", "4", str(apk)],
    "manifest": [str(tools / "aapt2"), "dump", "badging", str(apk)],
    "manifest_xml": [str(tools / "aapt"), "dump", "xmltree", str(apk), "AndroidManifest.xml"],
}
checks = {}
texts = {}
for name, command in commands.items():
    result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=30)
    checks[name] = result.returncode
    texts[name] = result.stdout + result.stderr
    (output / ("android-" + name + ".log")).write_text(texts[name])
badging = texts["manifest"]
package = re.search(r"package: name='([^']+)'", badging)
minimum = re.search(r"(?:minSdkVersion|sdkVersion):'(\d+)'", badging)
target = re.search(r"targetSdkVersion:'(\d+)'", badging)
architectures = re.search(r"native-code: (.+)", badging)
report = {
    "passed": all(code == 0 for code in checks.values()),
    "artifact": str(apk),
    "bytes": apk.stat().st_size,
    "sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
    "package": package.group(1) if package else None,
    "minimum_api": int(minimum.group(1)) if minimum else None,
    "target_api": int(target.group(1)) if target else None,
    "native_architectures": re.findall(r"'([^']+)'", architectures.group(1)) if architectures else [],
    "internet_permission": "android.permission.INTERNET" in texts["manifest_xml"],
    "build_tools": args.build_tools,
    "signature_v2": "v2): true" in texts["signing"],
    "signature_v3": "v3): true" in texts["signing"],
    "native_library_page_alignment": 16384,
    "device_runtime_verified": False,
    "checks": checks,
}
(output / "android-result.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report), flush=True)
raise SystemExit(0 if report["passed"] else 1)
