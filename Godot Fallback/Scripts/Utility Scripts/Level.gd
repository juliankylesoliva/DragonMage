extends Node

class_name Level

@export var player_reference : CharacterBody2D

@export var starting_room : Room

@export var starting_room_entrance_index : int = 0

@export var room_list : Array[Room]

@export_range(0, 1) var min_fragment_collection_rate : float = 0.5

@export var max_fragments_dropped : int = 10

var fragment_array : Array[MedalFragment]

var num_fragments_in_level : int = 0

var min_fragment_req_for_medal : int = 0

var mage_fragments : int = 0

var dragon_fragments : int = 0

func _ready():
	level_startup()

func level_startup():
	var destination_coords : Vector2 = starting_room.get_room_entrance_coordinates(starting_room_entrance_index)
	player_reference.global_position = destination_coords
	
	var player_temp : PlayerHub = null
	for child in player_reference.get_children():
		if child is PlayerHub:
			player_temp = (child as PlayerHub)
			break
	
	if (player_temp == null):
		push_warning("PlayerHub not found in player reference!")
	
	# connect player damage signal here
	
	for room in room_list:
		room.set_enemy_player_refs(player_temp)
		
		if (room != starting_room):
			room.deactivate_room()
		
		for fragment in room.medal_fragments:
			fragment.set_level_ref(self)
			fragment_array.append(fragment)
	
	num_fragments_in_level = fragment_array.size()
	
	min_fragment_req_for_medal = ((num_fragments_in_level * min_fragment_collection_rate) as int)
	
	starting_room.activate_room()
	
	player_temp.camera.snap_camera_to_player()

func increment_fragments(is_mage : bool):
	if (is_mage):
		mage_fragments += 1
	else:
		dragon_fragments += 1

func get_total_fragments():
	return (mage_fragments + dragon_fragments)

func drop_fragments():
	pass
