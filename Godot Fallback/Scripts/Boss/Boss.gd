extends Node2D

class_name Boss

@export var player_hub : PlayerHub

@export var boss_room : Room

@export var boss_trigger : Trigger

@export var boss_room_boundary_tilemap : TileMap

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

var is_activated : bool = false

var current_health : int = 0

var current_armor : int = 0

var current_invulnerability_duration : float = 0

var is_knockback_enabled : bool = false

var current_gravity_scale : float = 1

func _ready():
	boss_trigger.trigger_entered.connect(on_activation_trigger_entered)

func damage_boss(_damage_type : StringName):
	pass

func lock_camera_to_boss_room():
	var camera : Camera2D = get_viewport().get_camera_2d()
	camera.limit_left = ((boss_room.global_position.x as int) + battle_left_camera_limit)
	camera.limit_top = ((boss_room.global_position.y as int) + battle_top_camera_limit)
	camera.limit_right = ((boss_room.global_position.x as int) + battle_right_camera_limit)
	camera.limit_bottom = ((boss_room.global_position.y as int) + battle_bottom_camera_limit)

func release_camera_past_boss_room():
	var camera : Camera2D = get_viewport().get_camera_2d()
	camera.limit_left = ((boss_room.global_position.x as int) + defeated_left_camera_limit)
	camera.limit_top = ((boss_room.global_position.y as int) + defeated_top_camera_limit)
	camera.limit_right = ((boss_room.global_position.x as int) + defeated_right_camera_limit)
	camera.limit_bottom = ((boss_room.global_position.y as int) + defeated_bottom_camera_limit)

func on_activation():
	pass

func do_post_hit_invulnerability():
	current_invulnerability_duration = post_hit_invulnerability_duration

func update_invulnerability_duration(delta : float):
	if (current_invulnerability_duration > 0):
		current_invulnerability_duration = move_toward(current_invulnerability_duration, 0, delta)

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

func on_activation_trigger_entered():
	if (!is_activated):
		is_activated = true
		on_activation()
		boss_trigger.shape.call_deferred("set_disabled", true)
		if (boss_room_boundary_tilemap != null):
			for i in boss_room_boundary_tilemap.get_layers_count():
				boss_room_boundary_tilemap.set_layer_enabled(i, true)
		lock_camera_to_boss_room()
