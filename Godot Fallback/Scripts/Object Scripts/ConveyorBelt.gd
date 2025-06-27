extends StaticBody2D

class_name ConveyorBelt

const TILE_SIZE : float = 32

const BASE_PIXEL_SPEED : float = 20

@export var conveyor_segment : PackedScene

@export var collision_shape : CollisionShape2D

@export_range(-2560, 2560) var conveyor_velocity : float = 20

@export_range(1, 8) var conveyor_length : int = 3

func _ready():
	collision_shape.shape.size.x = (conveyor_length * TILE_SIZE)
	self.constant_linear_velocity.x = conveyor_velocity
	
	var anim_speed : float = abs(conveyor_velocity / BASE_PIXEL_SPEED)
	var direction_anim : String = ("GoingRight%s" if conveyor_velocity >= 0 else "GoingLeft%s")
	var last_index : int = (conveyor_length - 1)
	var start_offset : float = -(((conveyor_length - 1) * TILE_SIZE) / 2)
	for i in conveyor_length:
		var instance : Node = conveyor_segment.instantiate()
		self.add_child(instance)
		var conveyor_instance : AnimatedSprite2D = (instance as AnimatedSprite2D)
		conveyor_instance.position.x = (start_offset + (TILE_SIZE * i))
		
		var anim_suffix : String = ("S" if i == 0 and i == last_index else "L" if i == 0 and i != last_index else "R" if i != 0 and i == last_index else "M")
		conveyor_instance.play(direction_anim % anim_suffix, anim_speed)
