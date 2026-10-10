# Player UI

`GameUi` is a snapshot-only `CanvasLayer`. Instantiate `res://src/ui/game_ui.gd`, add it to the tree, and connect `intent(id: StringName, args: Dictionary)` to the application controller. It neither changes the board nor writes saves.

The implementation follows `design/gdd/ux/`, ADR-0016 and the vendor `godot-ui-containers` skill. MB-027's screen contracts/stack, MB-028's formatting/scaling helpers and MB-034's badge/orientation/profile snapshot helpers are promoted under `common/`. Staged scenes and the prototype remain available.

## Controller contract

| Method | Snapshot fields |
|---|---|
| `show_title(data)` | `has_profile`, `profile_name`, `continue_level_name`, `stars`, `wallet`, `biome_count`, `level_count` |
| `show_profiles(data)` | `profiles`: dictionaries with `slot`, `name`, `badge`, `color`, `stars`, `levels`, or null vacant slots; omitted slot uses the array index; `active_slot` |
| `show_map(data)` | `profile_name`, `stars`, `wallet`, `biome_name`, `biomes`: `id/name/stars/unlocked`, `selected_biome`, `next_level_id`, `levels`: `id/name/number/stars/unlocked/bonus/goal/lock_reason/preview` |
| `show_intro(data)` | `level_id`, `name`, `goal`, `goal_detail`, `twists`, `star_targets`, `preview` (no-star design preview badge) |
| `show_hud(data)` / `update_hud(data)` | `level_name`, `goal`, `progress`, `target`, `score`, `time` (seconds or formatted clock), `next_piece`, `twists`, `can_tilt`, `can_roll`, `danger`, optional `round`, `held_shape`, `skill_ready`, `skill_charge` (0–1000), `skill_name`, `selected_potion`, `potion_count`, `warning`, `hint`, `wobble`: `value/target` |
| `show_pause(data)` | `level_name` |
| `show_results(data)` | `won`, `stars`, `score`, `time` (seconds or formatted clock), `level_name`, `message`, `next_available`, optional `standings`: `name/wins` |
| `show_settings(data)` | `prefs`, optional `in_play`, `version`, `credits` |
| `show_shop(data)` | `wallet`, `items`: `id/name/description/kind/price/owned/count/locked/equipped/selected`, `characters`: `id/name/selected/unlocked`, `can_undo` |
| `show_arcade(data)` | `best`, `skins`: unlocked biome ids |
| `show_tournament(data)` | `profile_name`, `modes`, `network_status` (`offline` for setup), `character`, `network_players`: `name/character/perks`, `host`, `address`, `items_supported` (party item option stays hidden when false) |
| `show_physics(data)` | optional `variants`: `id/name/description`, `selected_variant`; default includes all 13 implemented challenges |
| `show_tools(data)` | `capabilities`: `kit/undo/reset/choose_down/ice_flick/flicks_left`, `kit_choices`: `shape_id/remaining`, `selection_remaining`, `allowed_down` / `allowed_flick`: arrays of `Vector3i` |
| `show_story(data)` | `story_key`, `phase` (`pre/post`), `beats`: `left/right/emote_left/emote_right/pose_left/pose_right/symbol/duration`, optional `props/guests` per beat; optional `skippable` (pre defaults false) |

`show_countdown(String)` / `hide_countdown()` cover the controls while counting down. `show_toast(String)` displays short feedback. `clear_overlay()` restores the HUD. `confirm_quit()` shows the title quit confirmation. Overlay menus hide controls and retain the dimmed 3D stage. Call `handle_back()` before routing Back through the application stack: it cancels local profile forms and progress-loss confirmations. `current_screen` names the visible page.

`apply_prefs(Dictionary)` applies text/control sizing and left-hand mirroring. Scales accept canonical fractions (`1.25`) or UI percentages (`125`). `board_area()` returns the normalized rectangle the 3D stage must reserve for the board; call it after HUD creation and after changing button size or orientation.

## Intents

Menu routing: `play`, `continue`, `open_map`, `open_profiles`, `open_settings`, `open_shop`, `open_arcade`, `open_tournament`, `open_physics`, `back`, `resume`, `retry`, `next`, `to_map`, `quit`. Level routing: `open_level({level_id})`, `start_level({level_id})`, `select_biome({biome_id})`.

Profiles: `create_profile({slot,name,badge,color})`, `select_profile({slot})`, `rename_profile({slot,name,badge,color})`, `delete_profile({slot})`. The store validates names and chooses the slot policy. Delete and progress-losing actions show one local confirmation, with cancellation focused first.

Gameplay: `move({delta: Vector3i})`, `rotate({axis: StringName,direction: int})`, `drop`, `soft({active: bool})`, `view({direction: int})`, `pause`, `hold`, `use_skill`, `use_item`. Move values are screen-relative: convert `Vector2i(delta.x,delta.z)` through the stage's movement mapping. Rotation ids are `spin`, `tilt`, `roll`, and direction is `-1/+1`. Play controls fire on press; move/rotation/view repeat while held. `orientation_changed({portrait})` lets the controller pause a run before reflowing the stage.

Puzzle capabilities: the contextual HUD button emits `open_tools`; the controller pauses and calls `show_tools`. Actual tool actions emit `pick_shape({shape_id})`, `choose_down({direction:Vector3i})`, `flick({direction:Vector3i})`, `undo`, `reset`. Only declared capabilities and allowed direction arrays produce controls. The controller applies the command and restores the appropriate session state.

Narrative: `story_done({story_key,phase})` fires once after timed completion or an available Skip/Back action. Pre-level scenes default to non-skippable and consume Back until completion; post-result scenes allow Skip/Back. The controller owns the pre-level/post-result hand-off and any rewards. `wordless_story.tscn` was created, attached and saved through the live GodotAI editor addon. The theatre draws distinct character silhouettes, pose changes, author-specified emote bubbles, concrete prop pictograms and optional finale guest portraits; it draws no premise text. Reduced motion keeps every pose and removes the idle/celebration motion.

Meta: `set_pref({key,value})`, `buy_item({item_id})`, `undo_purchase`, `select_character({character_id})`, `toggle_perk({item_id})`, `select_potion({item_id})`, `start_arcade({skin})`. UI volume and scale rows display percentages; the controller converts them to canonical save values. Reduced motion uses `system/off/on`. Key remapping emits `key_<action>` with an OS key-name string, captured before normal unhandled input.

LAN: `host_lan({name,port,rounds,character})`, `join_lan({name,address,port,character})`, `start_lan`, `leave_lan`. The controller owns the connection and supplies lobby snapshots. Bot practice is explicitly labelled and emits `start_tournament({rounds,players,items,modes})`; player dictionaries have `name/is_bot/character_id`. All four characters are selectable before connecting; admitted lobby rows show the fixed character and equipped perk count.

Physics: `open_physics` opens the challenge selector; `start_physics({variant})` requests one of the 13 real physics challenges. The physics scene owns its gameplay HUD and input. Hide `GameUi` during the challenge and restore the picker on its return signal.

## Layout and validation

Warm cream plates, dark navy text, orange primary actions and mint selected states form the toy-box theme. Title art and badges use vector drawing. Container children use size flags and minimum sizes, while the HUD reserves clear board space using anchored controls. Menus scroll when content exceeds the safe frame, and map cards use aspect-ratio containers in a wrapping flow.

Verified with Godot 4.7.2: every page instantiated and rendered in landscape and portrait; scripted profile/create/back, drop/rotate/hold/skill/potion, restart cancellation, LAN-host setup, bot-practice setup and purchase-confirmation intents passed. The focused primary action uses dark text for readable contrast.

Run the focused regression with `godot --headless --path . --script res://src/ui/tests/ui_flow_smoke.gd`. `ui_layout_smoke.gd` checks every HUD button against the viewport and reserved board rectangle at 1280×720 and 720×1280, with normal and large text/button preferences. Button enlargement is limited to available height so all actions remain reachable; the minimum target is 56 viewport pixels. Physical Android dp targets still require device verification. Network transport, persistence, gameplay effects and saved preference application belong to the controller and their own integration checks.

## GUIDE runtime input

`WtPlayerInput` uses the installed GUIDE addon for keyboard and gamepad mappings. Call `setup(get_tree(), prefs)` after installing actions and applying preferences, `refresh_bindings(prefs)` after a remap, `set_active(false)` while menus or pause block gameplay, `set_active(true)` on resume, and `dispose()` before removing the application. `poll(now_ms)` preserves the existing semantic move/soft-drop contract; discrete GUIDE actions emit the existing `wt_*` Godot actions for the controller's normal unhandled-input route. Touch buttons continue to emit UI intents.

Two GUIDE contexts separate always-available Pause/Back from gameplay. Press triggers prevent duplicate held or echoed drop commands. Held movement retains its 170 ms initial delay and 50 ms repeat. The left stick uses a radial 0.45 deadzone and dominant-axis movement. Raw InputMap bindings are captured and removed during GUIDE ownership to avoid duplicate routing, then restored on disposal. Saved remaps use actual GUIDE key inputs; keyboard, D-pad, sticks, shoulder buttons and triggers are mapped.

`src/ui/tests/guide_input_smoke.gd`, created and validated through the live GodotAI editor addon, dispatches real engine keyboard and virtual-gamepad hardware events. It verifies movement/repeat/release, soft-drop release, one-shot drop, saved remapping, menu blocking, global Pause/Back, radial diagonal handling, gamepad buttons and restored bindings.

## LAN loadouts

`WtLanSession.host(name, port, rounds, loadout)` and `join(address, name, port, loadout)` accept an optional `{character, perks, owned_perks}` dictionary. Old argument calls default to Cloud without perks. The host validates character IDs c1–c4, catalog perk kind and character, owned membership, unique IDs, two equipped slots and the 150-milli total edge cap. Character unlock gates do not apply to tournament play. Client-supplied effect/edge fields never determine gameplay: canonical effects come from the host's shipped catalog. Offline inventory ownership is a local-save claim; LAN has no account service to authenticate a remote save.

`player_loadout(peer_id=0)` returns a detached canonical `{character, ability_character, perks, owned_perks, edge_milli, effects}`; zero selects the local identity. Lobby `players` rows include that loadout and display fields. The host overwrites round `players/loadouts` with admitted values; `loadouts` uses integer peer IDs. Build a fresh level instance per player before applying its effects, then configure both the player's ability controller and charge perks from that same dictionary. Public snapshots and accessors do not expose mutable internal references. Protocol version 2 requires matching builds.

`tools/qa/verify_lan.py` checks four real ENet processes and host-derived perk effects. `verify_main_lan.py` runs four actual Main scenes, each with a real purchased/equipped perk and different character, then compares each identity's BoardSim hash across all four devices at 18 checkpoints. Different players are allowed—and required by this fixture—to have different final hashes.
