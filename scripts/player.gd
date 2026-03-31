extends XROrigin3D

var is_authority: bool:
	get: return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int
var health: int
var online: bool = false

func _enter_tree() -> void:
	ServerNetworkGlobals.handle_player_position.connect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.connect(client_handle_player_position)
	ClientNetworkGlobals.handle_take_damage.connect(take_damage)


func _exit_tree() -> void:
	ServerNetworkGlobals.handle_player_position.disconnect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.disconnect(client_handle_player_position)


func _ready() -> void:
	ClientUI.button_clicked.connect(button_clicked)
	$LeftHand.owner_id = owner_id
	$RightHand.owner_id = owner_id

func _physics_process(_delta: float) -> void:
	setup_camera()
	if online and !is_authority:
		self.current = false
		return

	self.current = true

	if online:
		PlayerPosition.create(owner_id, global_position).send(NetworkHandler.server_peer)

func setup_camera():
	if NetworkHandler.is_server:
		var world_cam = get_node_or_null("../../Camera3D")
		if world_cam:
			world_cam.current = true
	elif is_authority:
		var local_cam = get_node_or_null("XRCamera3D")
		if local_cam:
			local_cam.current = true




func button_clicked() -> void:
	var pointer = get_node_or_null("LeftHand/FunctionPointer")
	if pointer:
		pointer.enabled = false

func disable_pointer() -> void:
	var pointer = get_node_or_null("LeftHand/FunctionPointer")
	if pointer:
		pointer.enabled = false

func server_handle_player_position(peer_id: int, player_position: PlayerPosition) -> void:
	if owner_id != peer_id: return

	global_position = player_position.position

	PlayerPosition.create(owner_id, global_position).broadcast(NetworkHandler.connection)


func client_handle_player_position(player_position: PlayerPosition) -> void:
	if is_authority || owner_id != player_position.id: return

	global_position = player_position.position

func take_damage(id: int, damage: int) -> void:
	if is_authority || owner_id != id: return

	health -= damage
	