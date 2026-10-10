# ADR-0008: GDScript First, C++ GDExtension Only on Profiler Evidence (Android First)

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-09

## Last Verified

2026-10-09 (machine state probed read-only; godot-cpp 4.7 support NOT verified, see Engine Compatibility)

## Decision Makers

User (decision: "build in Godot engine first"), godot-gdextension-specialist (author), godot-specialist (architecture lead).

## Summary

The project wants GDScript plus C++ via GDExtension, running on Android, but native code has a real cost (per-ABI builds, CI, rebuild on every Godot upgrade). Decision: all gameplay is GDScript now; C++ is added later only for a profiler-proven hotspot, behind a coarse packed-array API with a GDScript twin and parity tests. No native scaffold exists until then.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 (4.7.2.stable.official.ed1daf0bf installed) |
| **Domain** | Scripting |
| **Layer** | Foundation |
| **Knowledge Risk** | HIGH: GDExtension / godot-cpp behaviour for 4.7 is post-cutoff |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (line 74: Android 16 KB page support) |
| **Post-Cutoff APIs Used** | None now. Future: godot-cpp targeting 4.7 (unverified) |
| **Verification Required** | When the first native class is added: (1) godot-cpp tags checked at that time (as of 2026-10-09 the newest tag found was `godot-4.5-stable`, no 4.6/4.7 tag or branch; only `master`); (2) NDK version Godot 4.7 expects; (3) JDK version Godot 4.7 accepts (machine has JDK 25); (4) 16 KB alignment of produced `.so` files on a real device or emulator |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (tick budget, pure sim), ADR-0002 (coarse packed-array board API) |
| **Enables** | Any future native-optimisation story |
| **Blocks** | None (no native work is scheduled) |
| **Ordering Note** | Revisit when profiling (ADR-0001 tick budget; candidates are ADR-0002 board queries and ADR-0004 clear strategies) shows a hotspot on a target Android device. A native class is registered like any other implementation (ADR-0004 plugin registry / factory), never hard-wired. |

## Context

### Problem Statement

The user chose GDScript plus C++ GDExtension, and the game must run on Android. We must decide when native code is justified, so the build is not burdened early and so a later port is cheap and safe.

### Current State

No native code, no `export_presets.cfg`, no `.gdextension`, no SConstruct. CI (`.github/workflows/tests.yml`) runs GdUnit4 on Ubuntu only. Phase: Concept.

### Constraints

- Godot 4.7.2 standard build (no C#), Mobile renderer, Windows 10 dev machine.
- Android first, iOS later (iOS has no dynamic-library loading for third-party GDExtensions without static linking or xcframework packaging; revisit then).
- GDExtension binaries are forward-compatible only: an extension built for 4.7 will not load in any earlier version; rebuild and re-test on every Godot upgrade.
- Solo/small team: avoid maintenance cost that is not paying for itself.

### Requirements

- Gameplay iterates fast in the editor.
- Any later native class must be a drop-in replacement, provably equivalent.
- Native code must never be required for the game to run in the editor or CI.

## Decision

1. **GDScript first.** All gameplay, UI, rules and simulation are GDScript. No native scaffold, submodule, SConstruct, CI workflow or export preset is created now.
2. **Profiler-evidence rule.** A system moves to C++ only if (a) a profile on a mid-range Android device (or the slowest supported target) shows it exceeds its frame-time budget after GDScript-level optimisation (typed arrays, packed arrays, less allocation, caching), or (b) it is an obvious algorithmic hot loop (>1000 iterations per frame) of pure data. The profile is attached to the story.
3. **Candidates** (pure, Godot-free simulation only): board queries, clear detection, orientation tables. Never scene-tree, UI, input or rule-twist flow.
4. **Coarse packed-array API.** Native classes take and return `PackedInt32Array` / `PackedByteArray` / simple scalars, in few calls per tick. No per-cell Godot API calls across the boundary; no `Variant`/`Dictionary` in hot paths.
5. **GDScript twin + parity tests.** The GDScript implementation stays as the reference and the editor/CI fallback. A native class `WtX` has a GDScript twin with an identical API. A single factory chooses `ClassDB.class_exists("WtX")` else the twin. The same gdUnit4 suite runs against both implementations on identical fixtures (determinism is already a project test rule, so seeded fixtures are fine). A missing library is a logged warning, not an error.
6. **godot-cpp pinning (when it happens).** Add godot-cpp as a git submodule pinned to a recorded commit SHA. If a `godot-4.7-stable` tag exists then, use it; otherwise pin a `master` SHA. Generate the API with `godot --dump-extension-api` from the installed 4.7.2 editor and pass it as `custom_api_file=`. Set `compatibility_minimum = "4.7"` in the `.gdextension`. The manifest uses `;` comments only.
7. **Android notes (for later).** SCons builds with the Android NDK; NDK r28.x is installed (28.0.13004108, 28.2.13676358). ABIs: `arm64` (devices) and `x86_64` (emulator). Set `ANDROID_NDK_ROOT`. Android native libraries must be 16 KB page aligned (Google Play requirement, see `breaking-changes.md`); NDK r28+ aligns by default, but verify the output. Confirm Godot 4.7's expected NDK and JDK versions before the first build.
8. **Windows desktop build** (editor and tests) uses MSVC, `x86_64`, debug and release. CI later: native matrix windows / linux / android; tests run where the lib loads.

### Machine checklist (recorded "for later", nothing installed)

| Item | Status 2026-10-09 |
|---|---|
| Python 3.13 | present |
| Godot 4.7.2 editor + export templates (android_debug/release.apk, android_source.zip) | present |
| Android Studio, JDK 25 (JBR) | present (compatibility with Godot 4.7 unverified) |
| Android SDK (`ANDROID_HOME` set), cmdline-tools, platform-tools, emulator | present |
| NDK 28.0.13004108, 28.2.13676358 | present; `ANDROID_NDK_ROOT` not set |
| Debug keystore | present |
| CMake | present |
| SCons (`pip install scons`) | MISSING |
| MSVC Build Tools 2022 ("Desktop C++") | MISSING (VS 2022 folders empty); MinGW is a fallback |
| Android export preset | not created (also not needed until an Android build is wanted) |

### Architecture

```
GDScript gameplay --(factory)--> BoardQuery API (same signature)
                                   |-- GDScript twin (default, always present)
                                   '-- WtBoardQuery (C++ GDExtension, optional)
                                         in: PackedInt32Array  out: PackedInt32Array
```

## Amendment 1 (2026-10-10, user decision): PC/Steam ships with Android; export hygiene

Accepted with the user's Wave 1 decisions. Does not change the GDScript-first rule above.

1. **Platforms.** Android and PC (Windows, via Steam) ship **together** at MVP. "Android first" above now means "Android is the tightest budget", not "PC later". Every story is verified on both. MVP input is touch + keyboard/mouse + gamepad (ADR-0012).
2. **Third-party native modules are exceptions, not a native scaffold.** Orchestrator (ADR-0010) and GodotSteam are prebuilt GDExtensions. They do not trigger rule 2's profiler-evidence requirement (no project C++), but each must load on every platform it ships to and is rechecked on every Godot upgrade.
3. **GodotSteam is excluded from Android.** It is used only behind a feature-tag check (`OS.has_feature("steam")`, a custom feature set on the Steam/PC export preset) through one thin GDScript wrapper (`src/game/platform/steam_service.gd`), with a no-op twin on every other platform. The Android preset excludes `addons/godotsteam/**` from export, and the `.gdextension` lists no Android library. Nothing outside the wrapper references a Steam class.
4. **Dev/AI autoloads are stripped from release exports.** `_mcp_game_helper` (godot_ai), `MCPRuntimeServer` (godot_mcp_toolkit) and the beehave debugger autoloads (`BeehaveGlobalMetrics`, `BeehaveGlobalDebugger`) must not run in a release build: release presets exclude their addon folders (or each autoload self-frees unless `OS.is_debug_build()` / a `dev` feature tag), and an export smoke test fails if any of them is present in a release `.pck`.
5. **Monetization seam.** No ads/IAP SDKs now (and none on Android without a new ADR). Any future store SDK goes behind the same feature-tagged wrapper pattern as rule 3.

Validation added: [M] Android release APK contains no GodotSteam or dev/AI autoload files and boots clean; [M] Steam/PC release build initialises GodotSteam only when the `steam` feature is present and runs without Steam (no-op twin) otherwise.

## Alternatives Considered

### Alternative 1: Scaffold C++ now
- **Pros**: pipeline proven early, Android issues found early.
- **Cons**: build/CI cost with no measured benefit; slows iteration.
- **Rejection Reason**: user decided engine-first; no evidence of need.

### Alternative 2: Rust (godot-rust) or C#
- **Rejection Reason**: Rust adds a second toolchain; C# excluded (standard build, no Mono).

### Alternative 3: GDScript only, forever
- **Rejection Reason**: leaves no sanctioned path if a hotspot appears; this ADR keeps that path cheap.

## Consequences

### Positive
- Fast iteration, no native toolchain required to develop or test.
- A defined, low-risk path if profiling demands native code.

### Negative
- A later port needs the toolchain setup (SCons, MSVC, NDK) at that point.
- Twin plus parity tests double the maintenance for any ported class.

### Neutral
- iOS native support deferred.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| godot-cpp lacks a 4.7 tag | Medium | Medium | Pin a `master` SHA + `custom_api_file` from 4.7.2 |
| Extension does not load after a Godot upgrade | Medium | High | Rebuild all platforms, update `compatibility_minimum`, re-test |
| 16 KB alignment missed | Low | High (Play rejection) | Verify produced `.so` before release |
| JDK 25 / NDK mismatch with Godot 4.7 | Medium | Low | Verify before first build; install the documented JDK if needed |
| Twin and native drift | Medium | Medium | Shared parity suite in CI |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | GDScript baseline, unmeasured | Per-hotspot, measured at port time | Set per system by the tick ADR |
| Memory | n/a | +1 shared lib per ABI (small) | TBD |
| Load Time | n/a | negligible | TBD |

## Migration Plan

Nothing to migrate now. When triggered: (1) attach profile; (2) install SCons/MSVC; (3) add `native/` + pinned submodule + `.gdextension`; (4) write the native class and parity tests; (5) factory switch; (6) CI matrix.

**Rollback plan**: the factory falls back to the GDScript twin; remove the `.gdextension`.

## Validation Criteria

- [ ] No native files exist until a profile justifies them.
- [ ] Every ported class has a profile, a twin and a passing parity suite.
- [ ] The game runs in the editor and CI with the native library absent.
- [ ] Android `.so` files verified 16 KB aligned before release.

## GDD Requirements Addressed

Foundational: no GDD requirement. Constrains: board, clear detection and shape/orientation systems (they must expose a coarse, array-based API so a native swap stays possible).

## Related

- Logic/visual split + tick ADR, board data model ADR, shape/orientation math ADR (candidate hotspots).
- `docs/engine-reference/godot/breaking-changes.md` (Android 16 KB pages).
- Existing CI: `.github/workflows/tests.yml`.
