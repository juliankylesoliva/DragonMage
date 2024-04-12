extends Node2D

class_name Boss

@export var player_hub : PlayerHub

@export var boss_trigger : Area2D

@export var total_health : int = 3

@export var armor : int = 3

@export var body : CharacterBody2D

@export var sprite : AnimatedSprite2D

@export_multiline var introduction_text : Array[String]

@export_multiline var defeat_text : Array[String]

@export var post_hit_invulnerability_duration : float = 1

@export var knockback_gravity_scale : float = 3

@export var battle_left_camera_limit : int = 0

@export var battle_top_camera_limit : int = 0

@export var battle_right_camera_limit : int = 0

@export var battle_bottom_camera_limit : int = 0

@export var defeated_left_camera_limit : int = 0

@export var defeated_top_camera_limit : int = 0

@export var defeated_right_camera_limit : int = 0

@export var defeated_bottom_camera_limit : int = 0

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_health : int = 0

var current_armor : int = 0

var current_invulnerability_duration : float = 0

var is_knockback_enabled : bool = false

var current_gravity_scale : float = 1

func damage_boss(_damage_type : StringName):
	pass

func lock_camera_to_boss_room():
	var camera : Camera2D = get_viewport().get_camera_2d()
	camera.limit_left = battle_left_camera_limit
	camera.limit_top = battle_top_camera_limit
	camera.limit_right = battle_right_camera_limit
	camera.limit_bottom = battle_bottom_camera_limit

func release_camera_past_boss_room():
	var camera : Camera2D = get_viewport().get_camera_2d()
	camera.limit_left = defeated_left_camera_limit
	camera.limit_top = defeated_top_camera_limit
	camera.limit_right = defeated_right_camera_limit
	camera.limit_bottom = defeated_bottom_camera_limit

func set_knockback_velocity(vec : Vector2):
	if (is_knockback_enabled):
		body.velocity = vec

func get_gravity_delta(delta : float):
	return (base_gravity * current_gravity_scale * delta)

func activate_post_hit_invulnerability():
	if (current_invulnerability_duration <= 0):
		current_invulnerability_duration = post_hit_invulnerability_duration
		while (current_invulnerability_duration > 0):
			await get_tree().process_frame
			current_invulnerability_duration = move_toward(current_invulnerability_duration, 0, get_process_delta_time())
