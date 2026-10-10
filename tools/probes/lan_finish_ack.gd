extends Node
## QA process teardown barrier; production round transport remains untouched.
signal completed(identity: int)
@rpc("any_peer", "call_remote", "reliable")
func complete() -> void:
	if not multiplayer.is_server(): return
	var identity: int = multiplayer.get_remote_sender_id()
	var lan: WtLanSession = get_parent().get_node("Lan") as WtLanSession
	for player: Dictionary in lan.snapshot().players:
		if int(player.id) == identity:
			completed.emit(identity)
			return
