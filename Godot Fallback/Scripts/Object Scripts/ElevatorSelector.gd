extends Node2D

class_name ElevatorSelector

@export var room_destinations : Array[Room]

@export var door_destination_to_modify : WarpDoor

@export var up_button : SignalButton

@export var down_button : SignalButton

@export var locked_rooms : Array[int] = [3, 4, 0]

@export var selector_sprite : Sprite2D

@export var selector_sprite_positions : Array[Node2D]

@export var lock_sprite_2f : Sprite2D

@export var lock_sprite_3f : Sprite2D

@export var lock_sprite_b : Sprite2D

var current_selection_index : int = 0

func _ready():
	for i in room_destinations.size():
		if (!locked_rooms.has(i)):
			current_selection_index = i
			break
	
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
	var next_index : int = (current_selection_index + 1)
	if (next_index < room_destinations.size() and !locked_rooms.has(next_index)):
		current_selection_index = next_index
		modify_door_destination()
		update_selection_sprite_position()

func decrement_selection_index():
	var next_index : int = (current_selection_index - 1)
	if (next_index >= 0 and !locked_rooms.has(next_index)):
		current_selection_index = next_index
		modify_door_destination()
		update_selection_sprite_position()

func set_selection_index(idx : int):
	if (idx >= 0 and idx < room_destinations.size() and !locked_rooms.has(idx)):
		current_selection_index = idx
		modify_door_destination()
		update_selection_sprite_position()
	else:
		for i in room_destinations.size():
			if (!locked_rooms.has(i)):
				current_selection_index = i
				modify_door_destination()
				update_selection_sprite_position()
				break

func unlock_next_room():
	if (locked_rooms.size() > 0):
		locked_rooms.remove_at(0)
	update_lock_sprites()

func update_lock_sprites():
	lock_sprite_2f.set_visible(locked_rooms.has(3))
	lock_sprite_3f.set_visible(locked_rooms.has(4))
	lock_sprite_b.set_visible(locked_rooms.has(0))

func update_selection_sprite_position():
	if (current_selection_index >= 0 and current_selection_index < room_destinations.size() and !locked_rooms.has(current_selection_index)):
		selector_sprite.global_position = selector_sprite_positions[current_selection_index].global_position
