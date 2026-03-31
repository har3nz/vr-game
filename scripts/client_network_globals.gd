extends Node

signal handle_local_id_assignment(local_id: int, health: int)
signal handle_remote_id_assignment(remote_id: int, health: int)

signal handle_player_position(player_position: PlayerPosition)
signal handle_hand_position(hand_position: HandPosition)
signal handle_weapon_position(weapon_position: WeaponPosition)

signal handle_spawn_weapon(remote_id: int, weapon_id: int)

signal handle_take_damage(peer_id: int, damage: int)

var id: int = -1
var remote_ids: Dictionary[int, int]

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(on_client_packet)


func on_client_packet(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))

		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(PlayerPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.HAND_POSITION:
			handle_hand_position.emit(HandPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.WEAPON_POSITION:
			handle_weapon_position.emit(WeaponPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.SPAWN_WEAPON:
			handle_spawn_weapon.emit(id, SpawnWeapon.create_from_data(data).weapon_id)
		PacketInfo.PACKET_TYPE.TAKE_DAMAGE:
			var take_damage := TakeDamage.create_from_data(data)
			handle_take_damage.emit(take_damage.id, take_damage.damage)

		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ids(id_assignment: IDAssignment) -> void:
	if id == -1: # When id == -1, the id sent by the server is for us
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id, id_assignment.remote_ids.get(id_assignment.id))

		remote_ids = id_assignment.remote_ids
		for remote_id in remote_ids:
			if remote_id == id: continue
			handle_remote_id_assignment.emit(remote_id)

	else: # When id != -1, we already own an id, and just append the remote ids by the sent id
		remote_ids.set(id_assignment.id, id_assignment.remote_ids.get(id_assignment.id))
		handle_remote_id_assignment.emit(id_assignment.id, id_assignment.remote_ids.get(id_assignment.id))
