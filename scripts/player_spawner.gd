extends Node

const PLAYER_SCENE = preload("res://scenes/keyboard_player.tscn")

func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(spawn_player)
	ClientNetworkGlobals.handle_remote_id_assignment.connect(spawn_player)


func spawn_player(id: int, health: int) -> void:
	var player = PLAYER_SCENE.instantiate()
	player.owner_id = id
	player.health = health
	player.online = true
	player.name = str(id)

	call_deferred("add_child", player)
