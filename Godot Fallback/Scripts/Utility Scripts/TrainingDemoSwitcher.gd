extends Node

class_name TrainingDemoSwitcher

@export var level_ref : Level
@export var demo_player : PlayerHub
@export var demo_list : Array[AutoPlayerInputSequence]
@export var starting_locations : Array[Node2D]

var current_room_index : int = -1

func _process(_delta):
	if (current_room_index != level_ref.get_current_room_index()):
		on_room_switch()

func on_room_switch():
	var room_index : int = level_ref.get_current_room_index()
	var demo_sequence : AutoPlayerInputSequence = (demo_list[room_index] if room_index < demo_list.size() and room_index < starting_locations.size() else demo_list[0])
	
	if (room_index < demo_list.size() and room_index < starting_locations.size()):
		demo_player.set_respawn_position(starting_locations[room_index].global_position)
		demo_player.do_respawn()
		demo_player.reset_player()
		demo_player.play_auto_sequence(demo_sequence)
	else:
		demo_player.stop_auto_sequence()
	
	current_room_index = room_index
