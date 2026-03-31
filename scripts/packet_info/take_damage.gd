class_name TakeDamage extends PacketInfo

var id: int
var damage: int

static func create(id: int, damage: int) -> TakeDamage:
	var info: TakeDamage = TakeDamage.new()
	info.packet_type = PACKET_TYPE.TAKE_DAMAGE
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.damage = damage
	return info


static func create_from_data(data: PackedByteArray) -> TakeDamage:
	var info: TakeDamage = TakeDamage.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(3)
	data.encode_u8(1, id)
	data.encode_u8(2, damage)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	damage = data.decode_u8(2)