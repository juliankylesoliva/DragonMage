extends TileMapLayer

class_name AmbushBlockade

@export var room_ref : Room

@export var blocks_to_break : Array[Node]

func _physics_process(_delta):
	if (room_ref.get_undefeated_enemies() <= 0 and self.enabled):
		self.enabled = false
		for n in blocks_to_break:
			if (n != null):
				n.queue_free()
