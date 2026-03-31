extends XRController3D

var is_authority: bool:
	get: return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int

func _enter_tree() -> void:
	ServerNetworkGlobals.handle_hand_position.connect(server_handle_hand_position)
	ClientNetworkGlobals.handle_hand_position.connect(client_handle_hand_position)


func _exit_tree() -> void:
	ServerNetworkGlobals.handle_hand_position.disconnect(server_handle_hand_position)
	ClientNetworkGlobals.handle_hand_position.disconnect(client_handle_hand_position)


func _physics_process(_delta: float) -> void:
	if !is_authority: return

	HandPosition.create(owner_id, global_position, 1).send(NetworkHandler.server_peer)


func server_handle_hand_position(peer_id: int, hand_position: HandPosition, is_left_hand: int) -> void:
	if owner_id != peer_id: return

	global_position = hand_position.position

	HandPosition.create(owner_id, global_position, is_left_hand).broadcast(NetworkHandler.connection)


func client_handle_hand_position(hand_position: HandPosition) -> void:
	if is_authority || owner_id != hand_position.id: return

	global_position = hand_position.position
