extends Node2D

class_name Boss

@export var state_machine : BossStateMachine

@export var player_hub : PlayerHub

@export var boss_room : Room

@export var boss_trigger : Trigger

@export var clear_timer : ClearTimer

@export var boss_room_boundary_tilemap : Node2D

@export var boss_music_player : LevelMusicPlayer

@export var normal_level_music_player : LevelMusicPlayer

@export var total_health : int = 3

@export var armor : int = 3

@export var body : CharacterBody2D

@export var sprite : AnimatedSprite2D

@export var visibility : VisibleOnScreenNotifier2D

@export var player_contact_hitbox : Area2D

@export_multiline var introduction_text : Array[String]

@export_multiline var defeat_text : Array[String]

@export var textbox : Textbox

@export var can_be_stomped : bool = true

@export var can_reflect_projectiles : bool = false

@export var post_hit_invulnerability_duration : float = 1

@export var post_damage_invulnerability_duration : float = 3

@export_range(0, 1) var invulnerability_alpha : float = 0.35

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

var is_player_in_collider : bool = false

var is_applying_invulnerability_alpha : bool = false

func _ready():
	boss_trigger.trigger_entered.connect(on_activation_trigger_entered)
	if (player_contact_hitbox != null):
		player_contact_hitbox.body_entered.connect(on_player_contact_enter)
		player_contact_hitbox.body_exited.connect(on_player_contact_exit)
	current_health = total_health
	current_armor = armor

func damage_boss(_damage_type : StringName, _damage_strength : int, _knockback_vector : Vector2, _is_projectile : bool = false):
	return false

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

func on_defeat():
	pass

func on_player_contact_enter(player_body):
	if (player_body == player_hub.char_body):
		is_player_in_collider = true

func on_player_contact_exit(player_body):
	if (player_body == player_hub.char_body):
		is_player_in_collider = false

func do_post_hit_invulnerability():
	current_invulnerability_duration = post_hit_invulnerability_duration

func do_post_damage_invulnerability():
	current_invulnerability_duration = post_damage_invulnerability_duration

func reset_post_damage_invulnerability():
	current_invulnerability_duration = 0

func update_invulnerability_duration(delta : float):
	if (current_invulnerability_duration > 0):
		current_invulnerability_duration = move_toward(current_invulnerability_duration, 0, delta)
		if (sprite != null):
			if (current_invulnerability_duration > 0 and is_applying_invulnerability_alpha):
				sprite.modulate.a = invulnerability_alpha
			else:
				sprite.modulate.a = 1.0
		is_applying_invulnerability_alpha = !is_applying_invulnerability_alpha

func set_knockback_velocity(vec : Vector2):
	if (is_knockback_enabled):
		body.velocity = vec

func set_gravity_scale(g : float):
	current_gravity_scale = g

func get_gravity_delta(delta : float):
	return (base_gravity * current_gravity_scale * delta)

func get_facing_value():
	return (1.0 if !sprite.flip_h else -1.0)

func activate_post_hit_invulnerability():
	if (current_invulnerability_duration <= 0):
		is_applying_invulnerability_alpha = true
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
			for child in boss_room_boundary_tilemap.get_children():
				if (child is TileMapLayer):
					(child as TileMapLayer).enabled = true
		lock_camera_to_boss_room()
