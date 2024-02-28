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
	
	var player_temp : PlayerHub = null
	for child in player_reference.get_children():
		if child is PlayerHub:
			player_temp = (child as PlayerHub)
			break
	
	if (player_temp == null):
		push_warning("PlayerHub not found in player reference!")
	
	for room in room_list:
		room.set_enemy_player_refs(player_temp)
		if (room != starting_room):
			room.deactivate_room()
	
	starting_room.activate_room()
	
	player_temp.camera.snap_camera_to_player()
