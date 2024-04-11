extends Node

var saved_room_index : int = -1

var saved_destination_coords : Vector2 = Vector2.ZERO

var saved_mage_fragments : int = 0

var saved_dragon_fragments : int = 0

var saved_fragment_status_array : Array[bool]

var saved_clear_time : float = -1

var saved_damage_taken : int = -1

var death_counter : int = 0

func save_checkpoint(room_index : int, destination_coords : Vector2, mage_frags : int, dragon_frags : int, frag_array : Array[MedalFragment]):
	saved_room_index = room_index
	saved_destination_coords = destination_coords
	saved_mage_fragments = mage_frags
	saved_dragon_fragments = dragon_frags
	saved_fragment_status_array.clear()
	for medal in frag_array:
		saved_fragment_status_array.append(medal.is_collected)

func save_clear_time(clear_time : float):
	if (clear_time >= saved_clear_time):
		saved_clear_time = clear_time

func save_damage_taken(damage_taken : int):
	if (damage_taken >= saved_damage_taken):
		saved_damage_taken = damage_taken

func increment_death_counter():
	death_counter += 1

func clear_checkpoint():
	saved_room_index = -1
	saved_destination_coords = Vector2.ZERO
	saved_mage_fragments = 0
	saved_dragon_fragments = 0
	saved_fragment_status_array.clear()
	saved_clear_time = 0
	saved_damage_taken = 0
	death_counter = 0
