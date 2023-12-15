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
	
	starting_room.activate_room()
	for room in room_list:
		if (room != starting_room):
			room.deactivate_room()
