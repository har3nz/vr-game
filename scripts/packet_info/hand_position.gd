class_name HandPosition extends PacketInfo

var id: int
var position: Vector3
var is_left_hand: int

static func create(id: int, position: Vector3, is_left_hand: int) -> HandPosition:
	var info: HandPosition = HandPosition.new()
	info.packet_type = PACKET_TYPE.HAND_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id
	info.position = position
	info.is_left_hand = is_left_hand
	return info


static func create_from_data(data: PackedByteArray) -> HandPosition:
	var info: HandPosition = HandPosition.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(15)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.z)
	data.encode_u8(14, is_left_hand)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
	is_left_hand = data.decode_u8(14)
