extends Path2D

class_name MovingPlatform

const TILE_SIZE : float = 32

@export var room_ref : Room

@export var line_2d : Line2D

@export var path_follow : PathFollow2D

@export var collision_shape : CollisionShape2D

@export var solo_sprite : Sprite2D

@export var left_sprite : Sprite2D

@export var middle_sprite : Sprite2D

@export var right_sprite : Sprite2D

@export_range(1, 8) var platform_length : int = 1 

@export var cycle_time : float = 5

@export var ping_pong : bool = false

var is_moving_forward : bool = true

var current_progress_ratio : float = 0

func _ready():
	if (room_ref != null):
		room_ref.room_activated.connect(reset_position)
	line_2d.points = self.curve.get_baked_points()
	setup()

func _physics_process(delta):
	if (room_ref != null and room_ref.is_room_active):
		if (ping_pong):
			current_progress_ratio = move_toward(current_progress_ratio, (1.0 if is_moving_forward else 0.0), ((1.0 / cycle_time) * delta))
			if (current_progress_ratio == (1.0 if is_moving_forward else 0.0)):
				is_moving_forward = !is_moving_forward
		else:
			current_progress_ratio += ((1.0 / cycle_time) * delta)
			if (current_progress_ratio > 1.0):
				current_progress_ratio -= 1.0
		path_follow.set_progress_ratio(current_progress_ratio)

func setup():
	collision_shape.shape.size.x = (TILE_SIZE * platform_length)
	
	solo_sprite.set_visible(platform_length == 1)
	
	if (platform_length > 1):
		left_sprite.set_visible(true)
		right_sprite.set_visible(true)
		
		if (platform_length > 2):
			left_sprite.position.x -= ((platform_length - 2) * TILE_SIZE / 2)
			right_sprite.position.x += ((platform_length - 2) * TILE_SIZE / 2)
	else:
		left_sprite.set_visible(false)
		right_sprite.set_visible(false)
	
	if (platform_length > 2):
		middle_sprite.set_visible(true)
		middle_sprite.region_rect.size.x = ((platform_length - 2) * TILE_SIZE)
	else:
		middle_sprite.set_visible(false)

func reset_position():
	current_progress_ratio = 0
	path_follow.set_progress_ratio(current_progress_ratio)
	is_moving_forward = true
