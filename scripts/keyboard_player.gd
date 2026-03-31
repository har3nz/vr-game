extends CharacterBody3D

var is_authority: bool:
	get: return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int = 1
var health: int
var online: bool = false

func _enter_tree() -> void:
	ServerNetworkGlobals.handle_player_position.connect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.connect(client_handle_player_position)


func _exit_tree() -> void:
	ServerNetworkGlobals.handle_player_position.disconnect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.disconnect(client_handle_player_position)


@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

@onready var head = $Head
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	
	ClientUI.button_clicked.connect(button_clicked)

func _physics_process(delta):
	setup_camera()
	if online and !is_authority: return
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("j") and is_on_floor():
		SpawnWeapon.create(owner_id, 0).send(NetworkHandler.server_peer)
	

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	direction.y = 0
	direction = direction.normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if online:
		PlayerPosition.create(owner_id, global_position).send(NetworkHandler.server_peer)

func setup_camera():
	if NetworkHandler.is_server:
		var world_cam = get_node_or_null("../../Camera3D")
		if world_cam:
			world_cam.current = true
	elif is_authority:
		var local_cam = get_node_or_null("Head/Camera3D")
		if local_cam:
			local_cam.current = true

func button_clicked() -> void:
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
