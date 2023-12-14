extends Node2D

class_name Room

@export var left_camera_limit : int = 0

@export var top_camera_limit : int = 0

@export var right_camera_limit : int = 512

@export var bottom_camera_limit : int = 320

@export var room_entrances : Array[Node2D]

# Enemy list goes here

func get_room_entrance_coordinates(i : int):
	if (i >= 0 and i < room_entrances.size()):
		return room_entrances[i].global_position
	return room_entrances[0].global_position

func activate_room():
	visible = true
	var camera : Camera2D = get_viewport().get_camera_2d()
	camera.limit_left = ((global_position.x as int) + left_camera_limit)
	camera.limit_top = ((global_position.y as int) + top_camera_limit)
	camera.limit_right = ((global_position.x as int) + right_camera_limit)
	camera.limit_bottom = ((global_position.y as int) + bottom_camera_limit)
	activate_enemies()

func deactivate_room():
	visible = false
	deactivate_enemies()

func activate_enemies():
	pass

func deactivate_enemies():
	pass
