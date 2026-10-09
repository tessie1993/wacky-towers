# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Game launches to main menu without crash
2. New game / session can be started from the main menu
3. Main menu responds to all inputs without freezing

## Core Mechanic (update per sprint)

4. A piece spawns, can be moved and rotated with touch, drops and locks in the 3D grid (once implemented)
5. A full layer clears (once implemented)

## Data Integrity

6. Save completes without error (once save system is implemented)
7. Load restores correct state (once load system is implemented)

## Performance

8. No visible frame rate drops on the reference phone (60 fps target)
9. No memory growth over 5 minutes of play (once core loop is implemented)
