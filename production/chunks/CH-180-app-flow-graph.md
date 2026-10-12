# CH-180 AppFlow Orchestrator graph (thin) - after the smoke test

**MB task:** MB-027 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-170; MB-014 pass
**Files:** new `src/game/app_flow.<ext>` (OScript extension from MB-014 evidence; do not guess)

## API
A graph with three states only: Boot -> Title (push) -> idle, calling `AppFlow.push_screen(&"title")`.

## Behaviour
- ADR-0010 §5: graphs only sequence; every node calls a typed method. Keep it trivial; if the smoke test failed this chunk is dropped (status `superseded`).

## How the integrator sees it working
Run Main with the graph: Title shows. Same behaviour as without the graph.

**Out of scope: PlaySession graph.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
