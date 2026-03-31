class_name SpawnWeapon extends PacketInfo

var id: int
var weapon_id: int

static func create(id: int, weapon_id: int) -> SpawnWeapon:
	var info: SpawnWeapon = SpawnWeapon.new()
	info.packet_type = PACKET_TYPE.SPAWN_WEAPON
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id
	info.weapon_id = weapon_id
	return info


static func create_from_data(data: PackedByteArray) -> SpawnWeapon:
	var info: SpawnWeapon = SpawnWeapon.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(14)
	data.encode_u8(1, id)
	data.encode_u8(2, weapon_id)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	weapon_id = data.decode_u8(2)
