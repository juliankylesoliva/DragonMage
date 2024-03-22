extends Node

class_name Level

@export var player_reference : CharacterBody2D

@export var starting_room : Room

@export var starting_room_entrance_index : int = 0

@export var room_list : Array[Room]

@export_range(0, 1) var min_fragment_collection_rate : float = 0.5

@export_range(1, 9) var min_fragment_majority_ratio : float = 2

@export var max_fragments_dropped : int = 10

@export var fragment_drop_split : int = 5

@export var ui_container : Control

var player_ref : PlayerHub

var fragment_array : Array[MedalFragment]

var num_fragments_in_level : int = 0

var min_fragment_req_for_medal : int = 0

var mage_fragments : int = 0

var dragon_fragments : int = 0

func _ready():
	PauseHandler.enable_pausing(true)
	level_startup()

func level_startup():
	var destination_coords : Vector2 = starting_room.get_room_entrance_coordinates(starting_room_entrance_index)
	player_reference.global_position = destination_coords
	
	for child in player_reference.get_children():
		if child is PlayerHub:
			player_ref = (child as PlayerHub)
			break
	
	if (player_ref == null):
		push_warning("PlayerHub not found in player reference!")
	
	player_ref.set_respawn_position(destination_coords)
	
	player_ref.damage.took_damage.connect(drop_fragments)
	
	for room in room_list:
		room.set_enemy_player_refs(player_ref)
		
		if (room != starting_room):
			room.deactivate_room()
		
		for fragment in room.medal_fragments:
			fragment.set_level_ref(self)
			fragment_array.append(fragment)
	
	num_fragments_in_level = fragment_array.size()
	
	min_fragment_req_for_medal = ((num_fragments_in_level * min_fragment_collection_rate) as int)
	
	starting_room.activate_room()
	
	player_ref.camera.snap_camera_to_player()

func level_finish():
	player_ref.set_level_complete()
	if (ui_container != null):
		ui_container.set_visible(false)

func increment_fragments(is_mage : bool):
	if (is_mage):
		mage_fragments += 1
	else:
		dragon_fragments += 1

func get_total_fragments():
	return (mage_fragments + dragon_fragments)

func can_get_medal():
	return (get_total_fragments() >= min_fragment_req_for_medal)

func get_medal_type():
	if (can_get_medal()):
		var maximum : float = max(mage_fragments, dragon_fragments)
		var minimum : float = min(mage_fragments, dragon_fragments)
		if (minimum == 0 or (maximum / minimum) >= min_fragment_majority_ratio):
			if (mage_fragments > dragon_fragments):
				return "MAGIC"
			else:
				return "DRAGON"
		else:
			return "BALANCE"
	else:
		return "NOTHING"

func drop_fragments():
	var dropped_mage_fragments : int = 0
	var dropped_dragon_fragments : int = 0
	
	var total_fragments : int = get_total_fragments()
	
	if (total_fragments > 0):
		if (total_fragments <= max_fragments_dropped):
			dropped_mage_fragments = mage_fragments
			dropped_dragon_fragments = dragon_fragments
		else:
			if (mage_fragments == 0):
				dropped_dragon_fragments = max_fragments_dropped
			elif (dragon_fragments == 0):
				dropped_mage_fragments = max_fragments_dropped
			else:
				var mage_fragments_to_drop : int = fragment_drop_split
				var dragon_fragments_to_drop : int = fragment_drop_split
				var fragment_diff = (mage_fragments - dragon_fragments)
				
				if (fragment_diff != 0):
					fragment_diff = min(max(fragment_diff, -fragment_drop_split), fragment_drop_split)
					mage_fragments_to_drop += fragment_diff
					dragon_fragments_to_drop -= fragment_diff
					
					if (mage_fragments_to_drop > mage_fragments):
						mage_fragments_to_drop = mage_fragments
						dragon_fragments_to_drop = (max_fragments_dropped - mage_fragments_to_drop)
					elif (dragon_fragments_to_drop > dragon_fragments):
						dragon_fragments_to_drop = dragon_fragments
						mage_fragments_to_drop = (max_fragments_dropped - dragon_fragments_to_drop)
					else:
						pass
				dropped_mage_fragments = mage_fragments_to_drop
				dropped_dragon_fragments = dragon_fragments_to_drop
	mage_fragments -= dropped_mage_fragments
	dragon_fragments -= dropped_dragon_fragments
