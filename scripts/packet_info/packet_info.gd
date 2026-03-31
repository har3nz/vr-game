## BASECLASS ##

class_name PacketInfo

enum PACKET_TYPE {
	ID_ASSIGNMENT = 0,
	PLAYER_POSITION = 1,
	HAND_POSITION = 2,
	WEAPON_POSITION = 3,
	SPAWN_WEAPON = 4,
	SHOOT_BULLET = 5,
	TAKE_DAMAGE = 6,
}

var packet_type: PACKET_TYPE
var flag: int

# Override function in derived classes
func encode() -> PackedByteArray:
	var data: PackedByteArray
	data.resize(1)
	data.encode_u8(0, packet_type)
	return data


# Override function in derived classes
func decode(data: PackedByteArray) -> void:
	packet_type = data.decode_u8(0)


func send(target: ENetPacketPeer) -> void:
	target.send(0, encode(), flag)


func broadcast(server: ENetConnection) -> void:
	server.broadcast(0, encode(), flag)
