extends Node

var saved_room_index : int = -1

var saved_destination_coords : Vector2 = Vector2.ZERO

var saved_mage_fragments : int = 0

var saved_dragon_fragments : int = 0

var saved_fragment_status_array : Array[bool]

func save_checkpoint(room_index : int, destination_coords : Vector2, mage_frags : int, dragon_frags : int, frag_array : Array[MedalFragment]):
	saved_room_index = room_index
	saved_destination_coords = destination_coords
	saved_mage_fragments = mage_frags
	saved_dragon_fragments = dragon_frags
	saved_fragment_status_array.clear()
	for medal in frag_array:
		saved_fragment_status_array.append(medal.is_collected)

func clear_checkpoint():
	saved_room_index = -1
	saved_destination_coords = Vector2.ZERO
	saved_mage_fragments = 0
	saved_dragon_fragments = 0
	saved_fragment_status_array.clear()
