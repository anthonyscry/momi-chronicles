extends Node
## EntityRegistry - caches common group lookups to reduce per-frame scans.

var players: Array[Node] = []
var enemies: Array[Node] = []
var companions: Array[Node] = []
var player_allies: Array[Node] = []

var _refresh_queued: bool = false

func _ready() -> void:
	_queue_refresh()
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

func _on_node_added(_node: Node) -> void:
	_queue_refresh()

func _on_node_removed(_node: Node) -> void:
	_queue_refresh()

func _queue_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh")

func _refresh() -> void:
	_refresh_queued = false
	players = get_tree().get_nodes_in_group("player")
	enemies = get_tree().get_nodes_in_group("enemies")
	companions = get_tree().get_nodes_in_group("companions")
	player_allies = get_tree().get_nodes_in_group("player_allies")

func get_player() -> Node:
	return players[0] if players.size() > 0 else null

func get_players() -> Array[Node]:
	return players

func get_enemies() -> Array[Node]:
	return enemies

func get_companions() -> Array[Node]:
	return companions

func get_player_allies() -> Array[Node]:
	return player_allies
