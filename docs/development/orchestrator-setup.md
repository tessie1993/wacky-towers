# Orchestrator setup

The project uses official Orchestrator **2.5 stable** with Godot **4.7.2**.
Native binaries are installed by a checksum-verified bootstrap rather than
committed to Git. The editable `.torch` architecture graph, bridge, extension
descriptor, and license are versioned.

```sh
python3 tools/setup/install_orchestrator.py
tools/ci/import.sh
```

An offline install can pass `--archive /path/godot-orchestrator-v2.5-stable-plugin.zip`;
the same published SHA256 and byte count are checked. The lock record is
`tools/setup/orchestrator.json`. CI must run this bootstrap before importing,
testing, or exporting. Restart an already open editor after installing the
native addon.

`src/app/architecture.torch` contains actual application-domain dispatch and
lifecycle graphs. `WtArchitecture` connects those branches to the application
and validates session, profile, result, and party authority before a dispatch.
The graph can be edited in Orchestrator. `tools/orchestrator/build_architecture.py`
regenerates the initial graph topology and lists the registered intents.

The official package supplies Linux and Windows x86-64, Linux ARM64, macOS,
iOS, Android ARM32/ARM64, and Web binaries. Android x86/x86-64 are unavailable,
so this project's Android preset selects ARM64. Web exports require
`variant/extensions_support=true`.

The official Android ARM64 library has 4 KiB ELF segment alignment. APK ZIP
alignment does not establish compatibility with 16 KiB Android page-size
devices. No Android device or emulator execution is claimed by the desktop
native-graph tests.
