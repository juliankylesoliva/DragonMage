extends Node

class_name PlayerSpriteTrail

@export var hub : PlayerHub

@export var sprite_trail_segment_scene : PackedScene

@export var trail_spawn_interval : float = 0.1

@export_color_no_alpha var mage_trail_color = Color.WHITE

@export_color_no_alpha var dragon_trail_color = Color.WHITE

var is_active : bool = false
var current_spawn_timer : float = 0

func _ready():
	current_spawn_timer = trail_spawn_interval

func _process(delta):
	if (is_active):
		if (current_spawn_timer > 0):
			current_spawn_timer = move_toward(current_spawn_timer, 0, delta)
			if (current_spawn_timer <= 0):
				current_spawn_timer = trail_spawn_interval
				spawn_sprite_segment()

func spawn_sprite_segment():
	var instance = sprite_trail_segment_scene.instantiate()
	add_child(instance)
	(instance as Node2D).global_position = hub.char_body.global_position
	
	var animation_name : String = hub.char_sprite.animation
	var animation_frame : int = hub.char_sprite.frame
	var current_texture = hub.char_sprite.sprite_frames.get_frame_texture(animation_name, animation_frame)
	var trail_sprite = (instance as Sprite2D)
	
	trail_sprite.texture = current_texture
	trail_sprite.modulate = (mage_trail_color if hub.form.current_mode == PlayerForm.CharacterMode.MAGE else dragon_trail_color)
	trail_sprite.flip_h = hub.char_sprite.flip_h
	trail_sprite.flip_v = hub.char_sprite.flip_v
	trail_sprite.z_index = hub.char_body.z_index
	trail_sprite.initialize_color_params()

func activate_trail():
	if (!is_active):
		is_active = true
		current_spawn_timer = trail_spawn_interval
		spawn_sprite_segment()

func deactivate_trail():
	is_active = false
