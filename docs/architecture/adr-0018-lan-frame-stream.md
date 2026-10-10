# ADR-0018: Executable LAN Tournament Frame Stream

Date: 2026-10-10
Status: Implemented baseline; mobile latency and bandwidth acceptance remain open.

The executable build uses `WtLanSession` at `/root/Main/Lan`, backed by Godot
4.7.2 `ENetMultiplayerPeer`. One host admits up to three clients, owns the round
seed and player identities, and broadcasts reliable command frames. Every device
advances its authoritative board simulations only from those received frames.
The app can predict movement for presentation; this transport does not mutate
or predict the simulation.

This is a documented deviation from [ADR-0009](adr-0009-local-multiplayer.md),
which specifies independent local simulations and a 4 Hz tournament-state
stream. The present implementation sends a deterministic frame stream at the
simulation's 60 Hz. It provides one authoritative command order and avoids
trusting client-reported scores, but adds network delay to authoritative input.
It does not satisfy the original independent-board latency design by itself.

## Runtime contract

| Operation | Direction and validation | Public result |
|---|---|---|
| `host(name, port, rounds)` | Host opens UDP; four seats total; port 1024–65535; rounds 1–20 | `Error`, `lobby_changed` |
| `join(address, name, port)` | Client connects and registers protocol version 1; names capped at 48 characters | `Error`, `lobby_changed` or `disconnected` |
| `start_round(config)` | Host only; integer seed; config at most 128 KiB; authoritative sorted player list | `round_started(config)` |
| `submit(kind, args)` | Host assigns `peer_id` from the RPC sender, validates admitted membership and argument shape | Command queued for the next host frame |
| `broadcast_tick()` | Host only; called at 60 Hz; ordered reliable frame; pauses stop advancement | `frame_received(tick, commands)` |
| `set_paused(value)` | Any admitted active player requests; host broadcasts the shared value | `paused_changed(value)` |
| `finish_round(data)` | Host only; reliable result, at most 128 KiB | `round_finished(data)` |
| Peer departure | Host aborts the active round and returns remaining peers to the lobby; host departure closes clients | Aborted result or `disconnected(reason)` |
| `leave()` | Closes ENet, restores an offline peer, clears all session state | Empty lobby |

All RPCs use reliable channel 0 and carry protocol version 1. Client requests
cannot select another board's identity. Moves must be one cardinal `Vector3i`,
rotations an axis 0–2 and sign ±1, simple commands have no arguments, and item
commands carry one string identifier of at most 64 characters. Limits are 16
queued commands per player per host frame and 180 commands per player per
second. The host and clients must use identical game content; a cryptographic
content fingerprint is not implemented in this baseline.

The stable node path is required by Godot's RPC signature/path checks. Do not
rename `Main` or `Lan` independently on one device. The app translates each
frame item `{peer_id, kind, args}` into `SimCommand.make(kind, args)` and advances
all relevant simulations exactly once for the delivered tick.

## Measured verification

`tools/qa/verify_lan.py` creates an isolated fixture, then launches four separate
Godot processes that communicate through real localhost UDP sockets. It does
not mock the network or call receiver functions directly.

```bash
python tools/qa/verify_lan.py --godot /path/to/godot \
  --output production/qa/evidence/build-2026-10-10/lan
python tools/qa/verify_lan.py --godot /path/to/godot --scenario disconnect \
  --output production/qa/evidence/build-2026-10-10/lan_disconnect
```

The retained normal run exchanged all four player names, seed 81723, round
count 5, 100 consecutive frames, four valid owned-board commands, a client
pause/resume and a host pause/resume. All four processes produced the same
frame-stream hash `1956072424`, saw pause values `[true, false, true, false]`,
and exited 0 without a script error or probe failure. The test also bypasses
the public client validator to send oversized move vectors and extra arguments;
the host rejects both malformed payloads.

The separate departure run disconnected ClientC at frame 45. The host and the
other two clients ended the round at frame 46 with `aborted: true`. All four
processes exited 0. Logs and machine-readable results are retained in the two
evidence directories above.

ENet lifecycle counters in the normal run recorded 16,289 sent bytes and 4,487
received bytes on the host over 2.533 seconds. ClientA recorded 1,547 sent and
5,571 received bytes over 2.217 seconds; the other clients recorded 5,153–5,565
received bytes. These include lobby setup, deliberate malformed inputs, pause
messages, and normal frames; they are not a steady-state mobile benchmark.
ClientA's observed receive average is approximately 2.5 KB/s, above ADR-0009's
2 KB/s budget. Frame batching or a return to independent local-board simulation
must be evaluated before that budget can be marked passed.

`tools/qa/verify_main_lan.py` additionally launches four actual `Main` scenes
with fresh isolated profiles. It uses the app's host/join/start intents and
real movement, all three rotation pairs, hard drop and skill intents. One
client changes its camera view before moving, exercising camera-relative
input conversion. The retained `main_lan/result.json` records four exit-zero
processes, 540 authoritative frames and 18 shared checkpoints. Every player's
`BoardSim.state_hash()` and piece orientation matches on all four processes;
each player's hard drop locks a piece. LAN currently forces Cloud Wizard for
every board, regardless of the four distinct profile selections in this test.
Character/loadout handshake is required before other LAN characters can be
advertised.

```bash
python tools/qa/verify_main_lan.py --godot /path/to/godot \
  --output production/qa/evidence/build-2026-10-10/main_lan
```

## Remaining acceptance work

The localhost evidence establishes transport, authority, frame ordering,
shared pause, and departure behavior. It does not establish phone-to-phone
Wi-Fi latency, Android permissions, suspend/resume, poor-network behavior,
cross-platform deterministic simulation, or the original 2 KB/s budget.
Room discovery, room codes/QR, reconnection into a preserved tournament seat,
host migration, and Internet/WebRTC matchmaking remain outside this baseline.
The original ADR-0009 requirements remain the target for those features.

## Verified API references

- [Godot high-level multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html): shared node paths, authority RPCs, sender identity, reliable transfer, and Android Internet permission.
- [ENetMultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html): UDP server/client creation and connection ownership.
- [ENetConnection](https://docs.godotengine.org/en/stable/classes/class_enetconnection.html): `pop_statistic` lifecycle data/packet counters used by the probe.
