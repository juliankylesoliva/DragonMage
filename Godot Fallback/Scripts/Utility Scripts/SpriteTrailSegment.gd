extends SelfDestructTimer

class_name SpriteTrailSegment

@export var sprite : Sprite2D

@export var shrink_to_zero : bool = false

@export var fade_sprite_to_zero : bool = false

@export var fade_to_black : bool = false

@export var enable_sprite_flip : bool = false

@export var flip_sprite_x_interval : int = 6

var current_timer : float = 0
var current_frame_timer : float = 0
var starting_x_scale : float = 0
var starting_y_scale : float = 0
var starting_color : Color = Color.WHITE
var ending_color : Color = Color.WHITE

func _ready():
	if (shrink_to_zero):
		starting_x_scale = sprite.scale.x
		starting_y_scale = sprite.scale.y
	
	current_lifetime_left = lifetime

func initialize_color_params():
	if (fade_sprite_to_zero or fade_to_black):
		starting_color = sprite.modulate
		ending_color = (Color.BLACK if fade_to_black else starting_color)
		if (fade_sprite_to_zero):
			ending_color.a = 0
	
	if (fade_to_black):
		ending_color = Color.BLACK

func _process(delta):
	if (current_lifetime_left > 0):
		current_lifetime_left = move_toward(current_lifetime_left, 0, delta)
		if (enable_sprite_flip):
			current_frame_timer += 1
			if (current_frame_timer == flip_sprite_x_interval):
				current_frame_timer = 0
				sprite.flip_h = !sprite.flip_h
		
		if (shrink_to_zero):
			Vector2(starting_x_scale, starting_y_scale).lerp(Vector2.ZERO, (lifetime - current_lifetime_left) / lifetime)
		
		if (fade_sprite_to_zero or fade_to_black):
			sprite.modulate = starting_color.lerp(ending_color, (lifetime - current_lifetime_left) / lifetime)
		
		if (current_lifetime_left <= 0):
			queue_free()
