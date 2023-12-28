extends Node

class_name Level

@export var player_reference : CharacterBody2D

@export var starting_room : Room

@export var starting_room_entrance_index : int = 0

@export var room_list : Array[Room]

func _ready():
	level_startup()

func level_startup():
	var destination_coords : Vector2 = starting_room.get_room_entrance_coordinates(starting_room_entrance_index)
	player_reference.global_position = destination_coords
	
	for room in room_list:
		room.room_activated.connect(preenable_adjacent_room_collisions)
		if (room != starting_room):
			room.deactivate_room()
			room.disable_collisions()
	
	starting_room.activate_room()
	starting_room.enable_collisions()
	
	for child in player_reference.get_children():
		if child is PlayerHub:
			(child as PlayerHub).camera.snap_camera_to_player()

func preenable_adjacent_room_collisions():
	for i in room_list.size():
		if (room_list[i].is_room_active):
			var prev_i : int = (i - 1)
			var next_i : int = (i + 1)
			for j in room_list.size():
				if (j == prev_i or j == next_i):
					room_list[j].enable_collisions()
				elif (j != i):
					room_list[j].disable_collisions()
				else:
					pass
