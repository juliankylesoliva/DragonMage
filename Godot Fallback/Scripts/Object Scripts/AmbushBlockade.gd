extends Node

class_name AmbushBlockade

@export var room_ref : Room

@export var blockade_tilemap : TileMap

var is_blockade_deactivated : bool = false

func _physics_process(_delta):
	if (room_ref.is_room_active and room_ref.get_undefeated_enemies() <= 0 and !is_blockade_deactivated):
		for i in blockade_tilemap.get_layers_count():
			blockade_tilemap.set_layer_enabled(i, false)
		is_blockade_deactivated = true
