# Test Infrastructure

**Engine**: Godot 4.7.2
**Test Framework**: GdUnit4 6.2.1 (`addons/gdUnit4/`)
**CI**: `.github/workflows/tests.yml`
**Setup date**: 2026-10-09

## Directory Layout

```
tests/
  unit/           # Isolated unit tests (formulas, state machines, logic)
  integration/    # Cross-system and save/load tests
  smoke/          # Critical path test list for /smoke-check gate
```

```
production/qa/
  evidence/       # Screenshot logs and manual test sign-off records
```

> **Manual evidence lives under `production/qa/evidence/`, not `tests/`** — that
> is where every consumer reads it.

## Running Tests

From the repo root (`G` = the console editor, see `commands.test` in `project.yaml`):

```bash
G="/d/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe"
"$G" --headless --path . --import
"$G" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode
```

Run the import first on a fresh clone. Exit codes: 0 all pass, 100 a failure,
101 passed but leaked nodes (warning), 103/104 gdUnit4 could not run, 105 a test
script does not parse. `No test cases found` with exit 0 is **not** a pass. The
two `ERROR:` lines about the remote port `127.0.0.1:0` are expected.

In the editor: enable **Project → Project Settings → Plugins → GdUnit4** and use
the GdUnit panel.

## Test Naming

File `[system]_[feature]_test.gd`, function `test_[scenario]_[expected]`
— `board_grid_test.gd` → `test_index_of_returns_row_major_index()`.

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automated unit test — must pass | `tests/unit/[system]/` |
| Integration | Integration test OR playtest doc | `tests/integration/[system]/` |
| Visual/Feel | Screenshot + lead sign-off | `production/qa/evidence/` |
| UI | Retained screenshot of each screen touched | `production/qa/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging.
