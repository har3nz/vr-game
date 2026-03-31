class_name IDAssignment extends PacketInfo

var id: int
var remote_ids: Dictionary[int, int]

static func create(id: int, remote_ids: Dictionary[int, int]) -> IDAssignment:
	var info: IDAssignment = IDAssignment.new()
	info.packet_type = PACKET_TYPE.ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.remote_ids = remote_ids
	return info


static func create_from_data(data: PackedByteArray) -> IDAssignment:
	var info: IDAssignment = IDAssignment.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	
	var header_offset: int = data.size()
	data.resize(header_offset + 2 + (remote_ids.size() * 2)) 
	
	data.encode_u8(header_offset, id)
	data.encode_u8(header_offset + 1, remote_ids.size())
	
	var current_pos: int = header_offset + 2
	for key in remote_ids.keys():
		data.encode_u8(current_pos, key)
		data.encode_u8(current_pos + 1, remote_ids[key])
		current_pos += 2
		
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	
	var offset: int = 1 
	
	id = data.decode_u8(offset)
	var dict_size: int = data.decode_u8(offset + 1)
	
	remote_ids.clear()
	var current_pos: int = offset + 2
	
	for i in range(dict_size):
		var key = data.decode_u8(current_pos)
		var val = data.decode_u8(current_pos + 1)
		remote_ids[key] = val
		current_pos += 2