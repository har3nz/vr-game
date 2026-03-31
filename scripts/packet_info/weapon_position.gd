class_name WeaponPosition extends PacketInfo

var id: int
var position: Vector3
var weapon_id: int

static func create(id: int, position: Vector3, weapon_id: int) -> WeaponPosition:
	var info: WeaponPosition = WeaponPosition.new()
	info.packet_type = PACKET_TYPE.WEAPON_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id
	info.position = position
	info.weapon_id = weapon_id
	return info


static func create_from_data(data: PackedByteArray) -> WeaponPosition:
	var info: WeaponPosition = WeaponPosition.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(15)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.z)
	data.encode_u8(14, weapon_id)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
	weapon_id = data.decode_u8(14)
