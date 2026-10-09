# ADR-0009: Local Multiplayer — One Phone per Player

## Status

Proposed

> **Who may move this to `Accepted`: the user, or `technical-director` on the
> user's explicit confirmation. No other agent, and no skill on its own.**

## Date

2026-10-09

## Last Verified

2026-10-09 (API names checked against `docs/engine-reference/godot/` only — see Verification Required)

## Decision Makers

Tessa (user decisions 2026-10-09), network-programmer (author), architecture team led by godot-specialist. The online-play integrity compromise is pending agreement with security-engineer.

## Summary

Tournaments are played by 2–4 players on their own phones on the same Wi-Fi or phone hotspot, and later online. Each phone simulates only its own board as a deterministic sim. One phone hosts a `TournamentHost` that owns the seed, round control, standings and attack routing. All traffic is a small set of versioned byte messages over Godot's `SceneMultiplayer`, carried by `ENetMultiplayerPeer` on a LAN now and by `WebRTCMultiplayerPeer` peer-to-peer later.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 (GDScript only for now) |
| **Domain** | Networking |
| **Layer** | Feature |
| **Knowledge Risk** | MEDIUM — the networking API is reported stable from 4.4 to 4.7, but the Android/iOS platform details are post-cutoff and unverified |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/networking.md`, `breaking-changes.md` (no networking breaks listed from 4.4 to 4.7) |
| **Post-Cutoff APIs Used** | None knowingly. Used: `ENetMultiplayerPeer`, `SceneMultiplayer` (`auth_callback`, `send_auth`, `complete_auth`), `@rpc` with `transfer_channel`, `ENetPacketPeer.set_timeout`, `PacketPeerUDP` (`set_broadcast_enabled`, `bind`, `set_dest_address`), `IP.get_local_addresses`, `Time.get_ticks_msec`, `Crypto.generate_random_bytes`, `WebRTCMultiplayerPeer` (later) |
| **Verification Required** | (1) Check every API above against the 4.7.2 class reference. (2) On a real Android device: does a broadcast beacon arrive with `CHANGE_WIFI_MULTICAST_STATE` set in the export permissions, i.e. does Godot's Android layer take a `WifiManager.MulticastLock` itself? If not, a small Android plugin must take it. (3) Whether `CameraServer`/`CameraFeed` delivers frames on Android in 4.7.2 (only relevant to QR option B). (4) Whether the `webrtc-native` GDExtension ships an Android build compatible with 4.7.2 (online phase). |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (logic/visual split + tick), ADR-0004 (rule-twist runtime), ADR-0005 (data format), ADR-0006 (RNG/seeds). They must give the sim the properties in *Requirements on the core simulation* below. |
| **Enables** | A future online-play ADR (signaling, STUN/TURN hosting) and Tournament Minigames sync |
| **Blocks** | Local Multiplayer epic, Tournament Flow epic (networked parts), Items' versus targeting |
| **Ordering Note** | Nothing here blocks the single-player build. The sim requirements (section below) **must** be in the first sim code, because retrofitting them later is expensive. |

## Context

### Problem Statement

The user decided (2026-10-09) that in tournaments every player uses their own phone, nearby. That needs discovery, a session model, round synchronisation, attacks between devices, standings, and disconnect handling. It also needs a path to online play that does not rewrite the gameplay messages. The sim is being designed now, so its network-facing requirements must be fixed now.

### Current State

No networking code exists. `design/gdd/local-multiplayer-setup.md` describes the behaviour (host authority, `sync_hz` 4, 1 s lagging, 5 s timeout, attacks applied on arrival and never rolled back) and leaves the stack open for this ADR.

### Constraints

- Android first, iOS later; GDScript only for now (no C#; GDExtension allowed later).
- 2–4 players, same Wi-Fi or a phone hotspot; no server for local play.
- The deterministic sim: one RefCounted per board, fixed integer-ms tick, command queue, seeded RNG streams. "Determinism" is currently defined as the same seed giving the same pieces, plus the same-device input replay.
- Tournament minigames are separate scenes and **all** have player interaction or sabotage (Mario Party / Mario Kart style), so the messages must carry minigame-specific events generically.
- The project states no latency target, so this ADR uses **150 ms one-way, with jitter spikes up to 500 ms**.

### Requirements

- Join a 4-player lobby in under 30 s (GDD acceptance 1).
- Every device plays the same round with the same pieces (GDD acceptance 2).
- Attacks arrive and apply on the target (GDD acceptance 3); goal-reached tie-breaks use round clocks (GDD acceptance 4).
- A device silent for 5 s is out for the round, and rejoins next round in the same seat with its wins (GDD acceptance 5; user Q4).
- The debuff target "leader" is the player with the **most points**, computed by the host and broadcast (user Q2).
- Bandwidth: at most 2 KB/s per phone each way.

## Decision

### 1. Topology: a star with a host in charge of the tournament, and each phone running its own board

- Each phone runs **only its own board's sim**. Boards never interact physically, so there is no lockstep and no rollback. Local input never waits on the network.
- One phone **hosts**. The host logic is `TournamentHost`, a RefCounted with no scene or network dependencies. It owns:
  - the lobby and seats
  - `tournament_seed` and the round picks (Randomizer)
  - the countdown and start time
  - pause and resume
  - standings and the leader
  - round results and tie-breaks
  - attack routing
  - session tokens
- The host's own player talks to `TournamentHost` through an in-process loopback, exactly like a remote client. The host has no special-case code path. The same class can later run on any peer (WebRTC).

### 2. Transport: `SceneMultiplayer` + byte messages

- One autoload, `NetSession` at `/root/NetSession`, owns the `MultiplayerPeer`. It exposes two RPCs that each carry a `PackedByteArray`:
  - `_rx_reliable`: channel 0, reliable
  - `_rx_unreliable`: channel 1, `unreliable_ordered`
- **No `MultiplayerSynchronizer` or `MultiplayerSpawner`.** Game state lives in RefCounted sims, not nodes.
- LAN: `ENetMultiplayerPeer`. Server on `game_port`, max 3 clients, `server_relay` on (clients reach each other through the host).
- Online, later: `WebRTCMultiplayerPeer` (section 9). **The message set does not change.**
- **Handshake.** `SceneMultiplayer.auth_callback` exchanges `{proto_ver, content_hash, session_token, player_name}`. If `proto_ver` or `content_hash` differs, the join is refused with "update the app". `content_hash` is computed once at startup from the gameplay data files.

### 3. Discovery and joining (user Q1: list + room code + QR)

1. **Nearby list (UDP broadcast).**
   - The host sends a beacon every `beacon_ms` from a `PacketPeerUDP` with broadcast enabled, to `255.255.255.255:beacon_port`.
   - The beacon is about 40 B: `{magic "WTWR", proto_ver, room_code, host_name, game_port, players, max_players}`.
   - Clients listen on `beacon_port` and list the hosts they hear. A host disappears from the list after `beacon_stale_ms`.
2. **Room code (4 characters).** The 32-letter alphabet has no 0/O/1/I. The code's 20 bits hold the host's IPv4 last octet (8 bits), a port slot (2 bits) and a 10-bit check value. The client combines the octet with its own address prefix (`IP.get_local_addresses`, assuming /24). This works where broadcast is blocked, and on a hotspot.
   - The code also serves as the lobby's display name.
   - Ceiling: networks larger than /24 need the QR code.
3. **QR code.**
   - The host shows a QR code for `wt://join?v=1&ip=<ipv4>&p=<port>&c=<room_code>`. It carries the full IP, so there is no /24 assumption.
   - *Generation* is pure GDScript: a small QR encoder (an MIT-licensed Asset Library addon, or roughly 300 lines written in-house), drawn into an `Image`.
   - *Scanning*, options (to be chosen at implementation, see Open Questions):
     - **A (recommended for Android): an Android plugin around Google's ML Kit "code scanner" (`GmsBarcodeScanning`).** Google Play services shows the camera UI and returns the string. Per Google's documentation this needs **no `CAMERA` permission** in the app (verify). The cost is native Kotlin/Java plugin code, outside "GDScript only". iOS later would use `AVFoundation`/VisionKit through an iOS plugin.
     - **B: Godot `CameraFeed` plus a decoder.** This stays in Godot, but needs the Android `CAMERA` permission (a dangerous permission with a runtime prompt), Android camera-feed support in 4.7.2 (unverified), and a decoder. A GDScript decoder is too slow per frame, so in practice it would be a GDExtension (e.g. ZXing-cpp, quirc).
     - **C: the phone's own camera app.** Register `wt://` as an Android intent filter, so scanning with the system camera opens the game. No camera code is needed in the app. It depends on the system camera app supporting QR (most current Android phones do).
   - If scanning is unavailable on a device, the room code is always shown under the QR code.
4. **Bluetooth and Wi-Fi Direct: not used** (user Q3). Godot has neither built in, each needs a native plugin per OS plus runtime permissions, and a phone hotspot covers the "no router" case with zero extra code. The hotspot owner may host or join. Some Android hotspots isolate clients from each other, which shows up as "can't reach host". Hosting on the hotspot phone itself avoids that.

### 4. Messages

Envelope: `type u8 | seq u16 | body`, little-endian, written with `PackedByteArray.encode_*`. The protocol version is checked once at the handshake. A **new message type or a new field appended at the end** stays backward-compatible, because readers ignore unknown types and trailing bytes. Anything else bumps `proto_ver`.

| Priority | Message | Direction | Channel | Body (approx.) |
|---|---|---|---|---|
| T0 | `lobby_state{seats[], settings}` | host → all | reliable | ≤ 200 B |
| T0 | `round_setup{round_idx, template_id, twist_ids[], round_seed u64, minigame_id}` | host → all | reliable | ~30 B |
| T0 | `round_start{start_at_host_ms u32}` | host → all | reliable | 8 B |
| T0 | `round_end{reason, results[]}` | host → all | reliable | ≤ 40 B |
| T0 | `pause{by_seat}` / `resume{by_seat}` | any → host → all | reliable | 4 B |
| T0 | `goal_reached{seat, sim_ms u32}` / `player_out{seat, sim_ms}` | phone → host | reliable | 8 B |
| T0 | `apply_effect{effect_id u16, src_seat, instance_id u32, params ≤16 B}` | host → target | reliable | ≤ 26 B |
| T1 | `use_debuff{effect_id, instance_id}` | phone → host | reliable | 8 B |
| T1 | `debuff_routed{instance_id, target_seat}` / `refund{instance_id}` | host → sender | reliable | 6 B |
| T1 | `standings{leader_seat, points[], roll_rank[], wins[]}` | host → all, on change, at most `standings_hz` | reliable | ≤ 24 B |
| T1 | `mg_event{mg_id u16, kind u8, src_seat, target u8, instance_id u32, sim_ms u32, payload ≤ mg_payload_max}` | phone → host → target(s) | reliable | ≤ 80 B |
| T2 | `progress{seat, sim_ms, goal_permille u16, points u32, height u8, danger u8, col_heights 4-bit packed}` | phone → host → all | unreliable, newest `seq` wins | 30–90 B |
| T2 | `mg_state{mg_id, tick u32, blob ≤ mg_state_max}` | host → all | unreliable | ≤ 200 B |
| — | `ping{t}` / `pong{t, host_t}` | both | reliable | 8 B |

- **Pieces are never sent.** With `sequence_mode = shared`, `round_seed` decides every piece stream (Spawner rules 1, 13).
- **Debuff targeting (user Q2):**
  1. The phone sends `use_debuff`.
  2. The host picks the target as the player with the most points among those not out. Ties go to the higher round wins, then the lower seat number. If the user is the leader, the next player down is the target.
  3. The host sends `apply_effect` to the target and `debuff_routed` back to the sender, which plays the streak animation.
  4. If no player can be targeted, the host sends `refund` and the item goes back to its slot.

  The `target` field also allows manual targeting later.
- **Standing for item rolls** (Items F2) varies per minigame (decision 2026-10-09). The host computes `roll_rank` with that minigame's `standing_fn`, a pure function named in the round template's data. `leader_seat` is always "most points". Phones use the latest `standings` they received.
- **Minigame events are generic.** The `(mg_id, kind)` pair names the event, and each minigame scene owns its `kind` table and its payload layout. `target` is either a seat, `0xFE` = "host decides" (routing goes through the minigame's `route(kind, src, standings)` on the host) or `0xFF` = everyone. Two sync profiles are allowed per minigame:
  - **Independent boards + events (the default).** Same as versus rounds.
  - **Host-owned shared object.** For a minigame with a shared thing every player touches, the host runs that object's sim and broadcasts `mg_state` at `mg_state_hz`. Clients send their actions as `mg_event` and render `mg_state` with an `interp_buffer_ms` delay.
  - `# ponytail:` no client prediction for shared objects. Add per-minigame prediction only if a playtest shows the 100–250 ms feels laggy.

### 5. Clocks, countdown and tie-breaks

- During the lobby and between rounds, each client sends `clock_pings` pings. It keeps the one with the lowest round-trip time and estimates `offset = host_t − (t_send + rtt/2)` using `Time.get_ticks_msec()` (a monotonic clock).
- The host sends `round_start` with `start_at_host_ms = now + countdown_ms + start_margin_ms`. Each phone starts its sim at that moment on its own clock and shows the 3-2-1 countdown up to it. The expected error is under 30 ms on a LAN.
- **The round clock is sim time** (`now_ms() = (tick × 1000) / SIM_HZ`, ADR-0001), not wall-clock time. Pauses and frame hitches therefore do not count. The host decides goal ties by the lower `sim_ms`, then by arrival order (GDD rule 5).

### 6. Latency handling

- Local input never crosses the network, so the 150 ms target only affects:
  - attack delivery: about 150–300 ms through the host, hidden by the 200 ms attack streak animation
  - mini-boards: up to 250 ms behind at 4 Hz, which is fine for silhouettes
- Attacks apply when they arrive, at the next tick boundary of the target's sim, and are **never rolled back**. If the target is in Resolving, the attack is queued until Resolving ends (Items edge case). If the target has already finished the round, it is dropped.
- **Deviation from `items.md` Game Feel:** "effect visible on the target within one frame of the tap" cannot hold across devices. The sender sees the streak at once; the target sees the effect on arrival.

### 7. Disconnect, rejoin and backgrounding

- Per remote seat: Connected → **Lagging** (no message for `lagging_ms`) → **Disconnected** (`timeout_ms`, also set as the ENet peer timeout).
  - A Disconnected seat is out for the round with no round win.
  - If fewer than 2 seats remain, the tournament ends with the current standings.
- **Rejoin (user Q4):** at join the host issues a `session_token` (16 random bytes). The phone keeps it in memory and in `user://` until the tournament ends. A joiner presenting a known token gets **the same seat, colour, badge and round wins**. It watches the rest of the current round and plays from the next one.
- **Host loss:**
  - Clients auto-pause when the host is silent for `lagging_ms`.
  - After `timeout_ms`, the tournament ends with the results so far (Tournament Flow edge case).
  - Host migration: no. Add it only if host loss turns out to be common in playtests.
- **Backgrounding:** on `NOTIFICATION_APPLICATION_PAUSED`, a phone sends `pause` before it suspends. The screen is kept on during a tournament (`DisplayServer.screen_set_keep_on`).
- All network anomalies are logged by `NetSession`: late or duplicate messages, unknown types, auth refusals and timeouts. Each kind is logged at most `log_rate_per_s` times per second.

### 8. Tunable defaults

All values live in one knob file, `res://assets/data/knobs/net.json` (JSON, ADR-0005; knob registry, ADR-0004). None are constants in code.

| Knob | Default | Safe range | Why this default |
|---|---|---|---|
| `sync_hz` (progress) | 4 | 2–10 | GDD; mini-boards only |
| `standings_hz` (max) | 4 | 1–10 | matches progress |
| `lagging_ms` | 1 000 | 500–3 000 | GDD |
| `timeout_ms` | 5 000 | 2 000–10 000 | GDD |
| `countdown_ms` | 3 000 | 2 000–5 000 | 3-2-1 |
| `start_margin_ms` | 300 | 100–1 000 | covers 2 × the 150 ms latency target |
| `clock_pings` | 5 | 3–10 | lowest-RTT sample |
| `beacon_ms` / `beacon_stale_ms` | 1 000 / 3 500 | 500–2 000 / 2 000–6 000 | the list fills in about 1 s |
| `beacon_port` / `game_port` | 47800 / 47801 (UDP) | 1024–65535 | unassigned range |
| `mg_state_hz` | 15 | 10–30 | shared minigame objects |
| `interp_buffer_ms` | 100 | 50–250 | about 1.5 snapshots at 15 Hz |
| `mg_payload_max` / `mg_state_max` | 64 / 200 B | — | keeps each message in one packet |
| `log_rate_per_s` | 2 | 1–10 | rate-limited anomaly log |
| debug `net_fake_delay_ms` / `net_fake_loss` | 0 / 0 | 0–500 ms / 0–0.3 | debug builds only |

### 9. Path to online play: peer-to-peer WebRTC (user Q6)

- Swap `ENetMultiplayerPeer` for `WebRTCMultiplayerPeer` in `create_client`/`create_server` mode, so the topology stays a star around the host peer. Same `NetSession`, same messages, same `TournamentHost` on the host peer.
- **Native plugin:** on Android, iOS and desktop, WebRTC needs the `webrtc-native` GDExtension (it is built in only on the web export). This needs checking for 4.7.2.
- **Signaling:** a small WebSocket signaling and lobby service (room code → SDP/ICE exchange). It is the one server online play cannot avoid; hosting it is devops-engineer's call.
- **NAT:** STUN (public or self-hosted) handles most home NATs. **TURN is required** for symmetric NATs and many mobile carriers, so a share of sessions will relay through TURN. TURN costs bandwidth, which is low at about 2 KB/s per player.
- **No neutral referee.** Each peer is trusted for its own board, and the host peer is trusted for routing and results.
  - **Mitigation (to be agreed with security-engineer):** every phone sends `checkpoint{sim_ms, state_hash u32}` every `checkpoint_ms` (default 5 000), and its full command log at round end.
  - A non-host peer re-simulates one other player's board from `round_seed` and that log, and compares the hashes. The assignment rotates.
  - A mismatch is flagged in the results, and the round can be voided by vote.
  - **This needs cross-device determinism, which is more than today's "same-device replay" definition** (see Open Questions).

### 10. Testing on one PC

- In the Godot editor, use Debug → Customize Run Instances to start 2–4 instances, each with `--net-instance=N`.
- Instance N binds `beacon_port + N` for listening, and the host beacons to `beacon_port + 0..3`. Windows does not let several processes share one UDP port, so instances need separate ports.
- `game_port` is bound only by the host, and clients use ephemeral ports.
- To simulate bad Wi-Fi, use the debug `net_fake_delay_ms` / `net_fake_loss` in `NetSession`, or the Windows tool clumsy.
- Unit and integration tests replace the peer with an in-memory loopback transport, so `TournamentHost` and 4 sims run headless under gdUnit4 with deterministic delivery order.

### 11. Platform permissions

- **Android** (export Permissions):
  - `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`. All are "normal" permissions with no prompt.
  - Receiving broadcasts on many devices needs a held `WifiManager.MulticastLock` (Verification Required item 2).
  - QR scanning with option B adds `CAMERA` (runtime prompt). Option A needs none (verify). Option C needs an intent filter for `wt://`.
- **iOS (later):**
  - `NSLocalNetworkUsageDescription` (the user is prompted on first use).
  - Broadcast needs Apple's restricted `com.apple.developer.networking.multicast` entitlement, which must be requested from Apple. Until it is granted, iOS joins by room code or QR only.
  - Scanning in the app needs `NSCameraUsageDescription`.

### Architecture

```
 Phone A (host)                                  Phone B/C/D (client)
 +-------------------------------+               +---------------------------+
 | BoardSim (RefCounted)         |               | BoardSim (RefCounted)     |
 |   ^ commands   | events       |               |   ^ commands  | events    |
 | MatchClient (seat 0)          |               | MatchClient (seat n)      |
 |   | loopback   ^              |               |   |           ^           |
 | TournamentHost (RefCounted)   |               |   |           |           |
 |   | bytes      ^              |               |   v           |           |
 | NetSession (autoload)         | <--ENet/UDP-->| NetSession (autoload)     |
 |   ch0 reliable / ch1 unrel.   |    (LAN)      |                           |
 | Beacon (PacketPeerUDP bcast)  | -- beacon --> | Beacon listener           |
 +-------------------------------+               +---------------------------+
 Later: ENet -> WebRTCMultiplayerPeer (+ signaling, STUN/TURN); nothing else changes.
```

### Key Interfaces

```gdscript
# NetSession (autoload) — the only node that touches MultiplayerPeer.
signal message(from_peer: int, bytes: PackedByteArray)
func host(cfg: NetConfig) -> Error
func join(ip: String, port: int, token: PackedByteArray) -> Error
func send(to_peer: int, bytes: PackedByteArray, reliable: bool) -> void  # to_peer 0 = all

# TournamentHost (RefCounted, no nodes) — pure; driven by NetSession or a test loopback.
func on_message(seat: int, bytes: PackedByteArray) -> Array[Outgoing]  # Outgoing = {to_seat, bytes, reliable}
func tick(now_host_ms: int) -> Array[Outgoing]                          # timeouts, countdown, standings_hz

# MatchClient (RefCounted) — bridges one BoardSim and the network.
func on_message(bytes: PackedByteArray) -> void   # -> sim.enqueue(command) at the next tick
func on_sim_event(ev: SimEvent) -> void           # -> NetSession.send(...)
```

### Implementation Guidelines

- Message codecs live in one `net_messages.gd` (encode/decode per type) with a round-trip unit test for every type.
- Never pass a `Dictionary` or `Variant` over the wire. Use only the byte layouts above, which avoids `var_to_bytes` versioning problems and object decoding risks.
- Every received message is validated before use: length, enum ranges, seat exists, `instance_id` not already seen. Bad messages are dropped and logged.

## Requirements on the core simulation (must exist from day one)

1. The sim never reads wall-clock time, OS randomness, the network or globals. Its only inputs are `step()` (one fixed tick, ADR-0001) and queued commands.
2. **Everything from outside is a command**, stamped with the tick it applies on: input, `apply_effect`, `set_standings`, `pause`, `round_end`, `refund`, `mg_event`. The command log is the replay and the online cross-check.
3. **The sim emits events instead of calling the network:** `goal_reached(sim_ms)`, `player_out`, `debuff_used`, `item_collected`, `mg_event` out. It also offers a cheap `progress()` snapshot.
4. Item rolls read standing from the latest `set_standings` command, never by live lookup. `standing_fn` per minigame is pure and data-driven.
5. RNG streams are derived from `(round_seed, scope, stream tag or rule_id, instance_id)` with a fixed integer hash; `String.hash()` and `randi()` are forbidden. Attack randomness (such as Junk Rain's gap) uses the **attack's** `instance_id`, so it can be replayed on the target.
6. `instance_id` = `(seat << 24) | per-seat counter`, unique per round, used for refunds, routing and duplicate rejection.
7. `state_hash() -> int` over the board, queue, active rules and RNG states, cheap enough to call every second.
8. Integer-only gameplay math (fixed-point where fractions are needed). It is needed for same-device replay anyway, and it is what makes cross-device checks possible later.

## Alternatives Considered

### Alternative 1: Host simulates every board
- **Pros**: one referee; a single source of truth.
- **Cons**: every move waits for a round trip; Wi-Fi jitter is felt as input lag; the host phone does 4× the work.
- **Rejection Reason**: the boards don't interact, so all that cost buys nothing locally.

### Alternative 2: Lockstep or rollback
- **Pros**: frame-exact fairness.
- **Cons**: needs cross-device determinism, and one slow phone stalls everyone.
- **Rejection Reason**: built for frame-exact interacting play (fighting games); our boards are independent.

### Alternative 3: Raw `PacketPeerUDP` for everything
- **Pros**: full control, no ENet framing.
- **Cons**: we would rebuild reliability, ordering, timeouts and connection state.
- **Rejection Reason**: ENet already provides them. Raw UDP is kept for discovery only.

### Alternative 4: Bluetooth or Wi-Fi Direct
- **Rejection Reason**: needs native plugins and permissions on each OS; the user chose a phone hotspot (Q3).

### Alternative 5: Relay or dedicated server for online play
- **Pros**: a neutral referee; NAT is solved.
- **Cons**: server cost and operations.
- **Rejection Reason**: the user chose peer-to-peer WebRTC (Q6). `TournamentHost` stays free of nodes, so this remains possible.

## Consequences

### Positive
- Local play has no input lag and degrades gracefully: a lost peer only greys out a mini-board.
- About 0.5 KB/s sent per phone; the host sends about 1.5 KB/s to each phone.
- The move to online play is a peer swap, with the same messages.
- Minigames add sync by declaring `kind` tables, not by adding new message types.

### Negative
- Each phone is trusted for its own board. That is fine among friends; online needs the cross-check (section 9).
- QR scanning needs native code or a GDExtension, which breaks "GDScript only" for that one feature.
- iOS discovery needs an Apple entitlement; until then, room code or QR only.
- The room code assumes a /24 subnet.

### Neutral
- `items.md` "visible on the target within one frame" becomes "visible on arrival", and the 200 ms streak hides the gap.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Broadcast beacons dropped (no multicast lock, AP isolation) | Medium | Nearby list empty | Room code and QR always available; device test item 2 |
| Hotspot client isolation | Low–Medium | Can't reach host | Host on the hotspot phone; documented in the join help |
| Host phone backgrounded or killed | Medium | Tournament ends | Auto-pause; keep-screen-on; pause on `APPLICATION_PAUSED` |
| `webrtc-native` unavailable for 4.7.2 Android | Medium | Online slips | Online is later; verify before the online ADR |
| Cross-device determinism not achieved | Medium | No P2P integrity check | Integer-only sim from day one (requirement 8) |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | 0 | < 0.2 ms (decode at most 30 messages/s) | 0.5 ms |
| Memory | 0 | < 1 MB | 2 MB |
| Load Time | 0 | lobby join < 30 s end to end | 30 s |
| Network (per phone) | 0 | up ~0.5 KB/s, down ~1.5 KB/s (more with shared-object minigames: 15 Hz × 200 B ≈ 3 KB/s down) | 4 KB/s |

## Migration Plan

New system; nothing to migrate. Order:
1. Sim requirements 1–8 land in the first sim code.
2. Codecs + loopback transport + `TournamentHost`, unit-tested headless.
3. ENet + beacon + room code.
4. QR.
5. Device tests.

**Rollback plan**: the transport sits behind `NetSession.send`/`message`, so it can be replaced without touching the sim or the host logic.

## Validation Criteria

- [ ] 4 Android phones on one Wi-Fi join and start in under 30 s; the same on a phone hotspot.
- [ ] Join by room code and by QR succeeds with broadcast blocked.
- [ ] Two phones on the same `round_seed` deal identical 100-piece sequences (GDD acceptance 2).
- [ ] An attack is applied on the target within 300 ms at 150 ms simulated one-way delay.
- [ ] Goal tie at 92.30 s vs 92.45 s sim time → the first wins, regardless of arrival order.
- [ ] A phone silent for 5 s is out; it rejoins with its token into the same seat with its wins and plays the next round.
- [ ] Measured traffic is ≤ 2 KB/s per phone in versus rounds.
- [ ] Every message type round-trips through its codec; a message from a higher `proto_ver` is refused at the handshake.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/local-multiplayer-setup.md` rules 1–7 | Local Multiplayer | Host/join on LAN; own board; host authority; progress at `sync_hz`; attacks on arrival; pause; 5 s timeout | Sections 1–8 |
| `design/gdd/local-multiplayer-setup.md` Open Question | Local Multiplayer | Networking stack | ENet over Wi-Fi/hotspot; no Bluetooth; WebRTC later |
| `design/gdd/tournament-flow.md` rules 1–2, edge cases | Tournament Flow | Seed, round loop, countdown, disconnect/host-leave | `round_setup`, `round_start`, section 7 |
| `design/gdd/mode-minigame-randomizer.md` rules 3, 7 | Randomizer | Same picks on all devices from the tournament seed | Host draws and broadcasts `round_setup` |
| `design/gdd/piece-spawner-queue.md` rules 1, 13–14 | Spawner | Shared seeded piece streams | Only `round_seed` is sent; sim requirement 5 |
| `design/gdd/items.md` rules 8, 10; F2 | Items | Targeting and standing-weighted rolls | Host-computed `leader_seat` (most points) and `roll_rank` |
| `design/gdd/buffs-debuffs.md` rule 7 | Buffs & Debuffs | Junk Rain gap from the effect's stream | Sim requirements 5–6 |
| `design/gdd/rule-twist-framework.md` rule 13 | Framework | Per-rule seeded streams matching across players | Sim requirement 5 |

## Open Questions

1. **Leader vs `items.md`**: rule 8/10 say the leader is decided by goal progress, then score. The user decided the debuff target is the **most points**. game-designer should update `items.md`. Should "points" mean this round's score or points across the tournament? Default here: **this round's score**.
2. **QR scanning option** A (ML Kit plugin, no permission), B (`CameraFeed` + GDExtension decoder, `CAMERA` permission) or C (system camera + `wt://` intent). Recommendation: C first (no code), then A if needed.
3. ~~Cross-device determinism~~ **Decided by the architecture team (2026-10-09):** yes. Gameplay math is integer-only; scalar knobs are fixed-point milli-units (ADR-0001, ADR-0004). Same-device replay is the tested guarantee now; cross-device re-simulation becomes possible without a rewrite.
4. **Online integrity compromise** (section 9) to be agreed with security-engineer; escalate to technical-director if unresolved.
5. **Shared-object minigames**: is the host-owned shared-object profile enough, or does any minigame need client prediction? Revisit per minigame design.

## Related

- ADR-0001 (logic/visual split + tick), ADR-0004 (rule-twist runtime), ADR-0005 (data format), ADR-0006 (RNG/seeds); overview in `docs/architecture/architecture.md`.
- `design/gdd/local-multiplayer-setup.md`, `tournament-flow.md`, `mode-minigame-randomizer.md`, `items.md`, `buffs-debuffs.md`, `piece-spawner-queue.md`, `rule-twist-framework.md`.
