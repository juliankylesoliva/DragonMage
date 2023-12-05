extends Node

class_name MagicBlastProjectile

@export var hitbox_scene : PackedScene

@export var sprite : AnimatedSprite2D

@export_color_no_alpha var normal_color : Color = Color.WHITE

@export_color_no_alpha var pulse_color : Color = Color.WHITE

@export var fuse_time : float = 5

@export var max_lerp_delta : float = 0.5

var current_fuse_time_left : float = 0

var current_lerp_weight : float = 0

func _ready():
	current_fuse_time_left = fuse_time

func _process(delta):
	sprite.modulate = normal_color.lerp(pulse_color, pingpong(current_lerp_weight, 1))
	current_fuse_time_left = move_toward(current_fuse_time_left, 0, delta)
	current_lerp_weight += (min(max_lerp_delta, (fuse_time / current_fuse_time_left) * delta))
	
	if (current_fuse_time_left <= 0):
		detonate()

func detonate():
	var hitbox_instance = hitbox_scene.instantiate()
	add_sibling(hitbox_instance)
	(hitbox_instance as Node2D).global_position = sprite.global_position
	despawn()

func despawn():
	queue_free()
