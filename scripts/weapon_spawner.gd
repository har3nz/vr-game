extends Node

const WEAPON_SCENE = preload("res://scenes/two_handed.tscn")

func _ready() -> void:
	ServerNetworkGlobals.handle_spawn_weapon.connect(spawn_weapon)
	ClientNetworkGlobals.handle_spawn_weapon.connect(spawn_weapon)

func spawn_weapon(id: int, weapon_id: int = 1) -> void:
	var weapon = WEAPON_SCENE.instantiate()
	weapon.owner_id = id
	weapon.name = str(id)
	weapon.weapon_id = weapon_id
	weapon.position = Vector3(0, 0.089, -0.16)
	
	get_parent().get_node("PlayerSpawner").get_node(str(id)).get_node("RightHand").call_deferred("add_child", weapon)
