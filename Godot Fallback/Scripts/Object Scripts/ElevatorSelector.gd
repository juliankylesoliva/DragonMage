extends Node2D

class_name ElevatorSelector

@export var room_destinations : Array[Room]

@export var door_destination_to_modify : WarpDoor

@export var up_button : SignalButton

@export var down_button : SignalButton

@export var initial_locked_rooms : int = 3

var current_selection_index : int = 0

var current_locked_rooms : int = 0

func _ready():
	if (initial_locked_rooms < room_destinations.size()):
		current_locked_rooms = initial_locked_rooms
	
	if (up_button != null):
		up_button.button_pressed.connect(increment_selection_index)
	
	if (down_button != null):
		down_button.button_pressed.connect(decrement_selection_index)
	
	for i in room_destinations.size():
		room_destinations[i].room_activated.connect(set_selection_index.bind(i))

func modify_door_destination():
	door_destination_to_modify.warp_dummy.room_destination = room_destinations[current_selection_index]
	door_destination_to_modify.room_destination = door_destination_to_modify.warp_dummy.room_destination

func increment_selection_index():
	current_selection_index += 1
	if (current_selection_index >= (room_destinations.size() - current_locked_rooms)):
		current_selection_index = 0
	modify_door_destination()

func decrement_selection_index():
	current_selection_index -= 1
	if (current_selection_index < 0):
		current_selection_index = (room_destinations.size() - current_locked_rooms - 1)
	modify_door_destination()

func set_selection_index(idx : int):
	current_selection_index = idx
	if (current_selection_index >= (room_destinations.size() - current_locked_rooms)):
		current_selection_index = 0
	elif (current_selection_index < 0):
		current_selection_index = (room_destinations.size() - current_locked_rooms - 1)
	else:
		pass
	modify_door_destination()

func unlock_next_room():
	if (current_locked_rooms > 0):
		current_locked_rooms -= 1
