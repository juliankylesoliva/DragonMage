extends TileMapLayer

class_name AmbushBlockade

@export var room_ref : Room

func _physics_process(_delta):
	if (room_ref.is_room_active and room_ref.get_undefeated_enemies() <= 0 and self.enabled):
		self.enabled = false
