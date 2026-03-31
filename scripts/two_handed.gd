extends XRToolsPickable

var is_authority: bool:
	get: return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int

var weapon_id: int

var held_down: bool = false

var can_shoot := true
var timer

var raycast

func _enter_tree() -> void:
	ServerNetworkGlobals.handle_weapon_position.connect(server_handle_weapon_position)
	ClientNetworkGlobals.handle_weapon_position.connect(client_handle_weapon_position)


func _exit_tree() -> void:
	ServerNetworkGlobals.handle_weapon_position.disconnect(server_handle_weapon_position)
	ClientNetworkGlobals.handle_weapon_position.disconnect(client_handle_weapon_position)

func _on_dropped(_p_interactable):
	pass

func _ready() -> void:
	raycast = $RayCast3D
	timer = $Timer

	var right_hand = get_parent().get_parent()
	
	if right_hand:
		pick_up(right_hand)

func _physics_process(_delta: float) -> void:
	if !is_authority: return

	if held_down and can_shoot:
		
		
		can_shoot = false
		timer.start()

	
	if raycast.is_colliding():
		var result = raycast.get_collider()
		if result.get_parent().type == XROrigin3D:
			print()

	WeaponPosition.create(owner_id, global_position, weapon_id).send(NetworkHandler.server_peer)


func server_handle_weapon_position(peer_id: int, weapon_position: WeaponPosition, weapon_id: int) -> void:
	if owner_id != peer_id: return


	global_position = weapon_position.position

	WeaponPosition.create(owner_id, global_position, weapon_id).broadcast(NetworkHandler.connection)


func client_handle_weapon_position(weapon_position: WeaponPosition) -> void:
	if is_authority || owner_id != weapon_position.id: return

	global_position = weapon_position.position



func _on_right_button_released(name: String) -> void:
	held_down = false

func _on_right_button_pressed(name: String) -> void:
	held_down = true


func _on_timer_timeout() -> void:
	can_shoot = true
