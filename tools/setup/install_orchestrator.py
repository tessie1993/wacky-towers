#!/usr/bin/env python3
"""Install the pinned official Orchestrator native addon for Godot 4.7.

Usage: python3 tools/setup/install_orchestrator.py [--archive /path/plugin.zip]
Downloads only the public release asset, verifies its published SHA256, then
extracts into this project. No system installation or Python packages required.
"""
from __future__ import annotations

import argparse
import hashlib
import shutil
import tempfile
import urllib.request
import zipfile
from pathlib import Path

VERSION = "v2.5.stable"
URL = "https://github.com/CraterCrash/godot-orchestrator/releases/download/v2.5.stable/godot-orchestrator-v2.5-stable-plugin.zip"
SHA256 = "3e4bab7811b89002627495973e1aa0fdf502bb8cec718a2693cce354d203efd7"
SIZE = 63_914_270


def install(archive: Path, project: Path) -> int:
    digest = hashlib.file_digest(archive.open("rb"), "sha256").hexdigest()
    if archive.stat().st_size != SIZE or digest != SHA256:
        raise ValueError(f"Official archive verification failed: size={archive.stat().st_size}, sha256={digest}")
    count = 0
    with zipfile.ZipFile(archive) as files:
        for entry in files.infolist():
            relative = Path(entry.filename)
            if relative.is_absolute() or ".." in relative.parts or not entry.filename.startswith("addons/orchestrator/"):
                raise ValueError(f"Unexpected archive path: {entry.filename}")
            if entry.is_dir() or relative.suffix in (".import", ".exp", ".lib"):
                continue
            destination = project / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            with files.open(entry) as source, destination.open("wb") as output:
                shutil.copyfileobj(source, output)
            count += 1
    print(f"Installed Orchestrator {VERSION}: {count} verified files in {project / 'addons/orchestrator'}")
    print("Run the Godot editor once to register the GDExtension before running tests or exporting.")
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=Path, help="Use an already downloaded official ZIP (still verified)")
    parser.add_argument("--project", type=Path, default=Path(__file__).resolve().parents[2])
    args = parser.parse_args()
    if args.archive:
        install(args.archive, args.project.resolve())
    else:
        with tempfile.TemporaryDirectory(prefix="wt-orchestrator-") as temporary:
            archive = Path(temporary) / "orchestrator.zip"
            with urllib.request.urlopen(URL, timeout=120) as source, archive.open("wb") as output:
                shutil.copyfileobj(source, output)
            install(archive, args.project.resolve())


if __name__ == "__main__":
    main()
