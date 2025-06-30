extends Node

class_name ElevatorSelector

@export var room_destinations : Array[Room]

@export var entrance_index_to_use : int = 0

@export var door_destination_to_modify : WarpDoor

@export var up_button : SignalButton

@export var down_button : SignalButton

var current_selection_index : int = 0

func modify_door_destination():
	door_destination_to_modify.warp_dummy.room_destination = room_destinations[current_selection_index]
	door_destination_to_modify.room_destination = door_destination_to_modify.warp_dummy.room_destination

func increment_selection_index():
	current_selection_index += 1
	if (current_selection_index >= room_destinations.size()):
		current_selection_index = 0
	elif (current_selection_index < 0):
		current_selection_index = (room_destinations.size() - 1)
	else:
		pass
