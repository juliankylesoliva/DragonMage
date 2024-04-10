extends Node2D

class_name Room

signal room_activated

@export var parallax_bg : ParallaxBackground

@export var tilemap_list : Array[TileMap]

@export var left_camera_limit : int = 0

@export var top_camera_limit : int = 0

@export var right_camera_limit : int = 512

@export var bottom_camera_limit : int = 320

@export var room_entrances : Array[Node2D]

@export var enemy_nodes : Array[Node]

@export var medal_fragments : Array[Node]

var enemy_list : Array[Enemy]

var is_room_active : bool = true

func get_room_entrance_coordinates(i : int):
	if (i >= 0 and i < room_entrances.size()):
		return room_entrances[i].global_position
	return room_entrances[0].global_position

func activate_room():
	visible = true
	if (parallax_bg != null):
		parallax_bg.visible = true
		parallax_bg.scroll_base_offset = global_position
	is_room_active = true
	var camera : Camera2D = get_viewport().get_camera_2d()
	camera.limit_left = ((global_position.x as int) + left_camera_limit)
	camera.limit_top = ((global_position.y as int) + top_camera_limit)
	camera.limit_right = ((global_position.x as int) + right_camera_limit)
	camera.limit_bottom = ((global_position.y as int) + bottom_camera_limit)
	activate_enemies()

func deactivate_room():
	visible = false
	if (parallax_bg != null):
		parallax_bg.visible = false
	is_room_active = false
	deactivate_enemies()

func activate_enemies():
	initialize_enemy_list()
	for enemy in enemy_list:
		if (!enemy.is_defeated):
			enemy.activate_enemy()

func deactivate_enemies():
	initialize_enemy_list()
	for enemy in enemy_list:
		if (!enemy.is_defeated):
			enemy.deactivate_enemy()

func respawn_enemies():
	initialize_enemy_list()
	for enemy in enemy_list:
		enemy.respawn_enemy()

func set_enemy_player_refs(player : PlayerHub):
	initialize_enemy_list()
	for enemy in enemy_list:
		if (enemy.player_detection.player_ref == null):
			enemy.player_detection.player_ref = player

func initialize_enemy_list():
	if (enemy_list.size() == 0 and enemy_nodes.size() > 0):
		for node in enemy_nodes:
			for child in node.get_children():
				if (child is Enemy):
					enemy_list.append(child as Enemy)
					break
