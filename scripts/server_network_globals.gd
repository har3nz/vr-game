extends Node

signal handle_player_position(peer_id: int, player_position: PlayerPosition)
signal handle_hand_position(peer_id: int, hand_position: HandPosition, is_left_hand: int)
signal handle_weapon_position(peer_id: int, weapon_position: WeaponPosition, weapon_id: int)

signal handle_spawn_weapon(peer_id: int, weapon_id: int)

signal handle_take_damage(peer_id: int, damage: int)


var peer_ids: Dictionary[int, int]

func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(on_peer_connected)
	NetworkHandler.on_peer_disconnected.connect(on_peer_disconnected)
	NetworkHandler.on_server_packet.connect(on_server_packet)


func on_peer_connected(peer_id: int, health: int) -> void:
	peer_ids.set(peer_id, health)

	IDAssignment.create(peer_id, peer_ids).broadcast(NetworkHandler.connection)


func on_peer_disconnected(peer_id: int) -> void:
	peer_ids.erase(peer_id)

func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	match data[0]:
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(peer_id, PlayerPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.HAND_POSITION:
			var hand_pos = HandPosition.create_from_data(data)
			handle_hand_position.emit(peer_id, hand_pos, hand_pos.is_left_hand)
		PacketInfo.PACKET_TYPE.WEAPON_POSITION:
			var weapon_pos = WeaponPosition.create_from_data(data)
			handle_weapon_position.emit(peer_id, weapon_pos.position, weapon_pos.weapon_id)
		PacketInfo.PACKET_TYPE.SPAWN_WEAPON:
			var spawn_weapon = SpawnWeapon.create_from_data(data)
			spawn_weapon.emit(peer_id, spawn_weapon.weapon_id)
		PacketInfo.PACKET_TYPE.TAKE_DAMAGE:
			var take_damage := TakeDamage.create_from_data(data)
			handle_take_damage.emit(take_damage.id, take_damage.damage)
		_:
			push_error("Packet type with index ", data[0], " unhandled!")
