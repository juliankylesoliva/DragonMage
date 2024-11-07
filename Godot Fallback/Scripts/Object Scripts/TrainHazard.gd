extends Node2D

class_name TrainHazard

enum TrainHazardState {IDLE, ACTIVE}

@export var collision_shape : CollisionShape2D

@export_enum("Right:1", "Left:-1") var starting_direction : int = 1

@export var idle_interval : float = 3

@export var travel_duration : float = 5

@export var speed_override : float = 302.4

@export var left_start_point : Node2D

@export var right_start_point : Node2D

var is_train_disabled : bool = true

var is_player_detected : bool = false

var player_ref : PlayerHub = null

var current_state : TrainHazardState = TrainHazardState.IDLE

var current_direction : int = 1

var target_x_pos : float = 0

var travel_speed : float = 0

var current_idle_timer : float = 0

func _process(_delta):
	if (current_state == TrainHazardState.IDLE and current_idle_timer > 0):
		current_idle_timer = move_toward(current_idle_timer, 0, _delta)
		if (current_idle_timer <= 0):
			current_state = TrainHazardState.ACTIVE
	elif (current_state == TrainHazardState.ACTIVE and player_ref != null and is_player_detected):
		if (player_ref.damage.do_damage_warp()):
			EffectFactory.get_effect("EnemyContactImpact", player_ref.char_body.global_position)
			SoundFactory.play_sound_by_name("enemy_contact_impact", player_ref.char_body.global_position, 0, 1, "SFX")
	else:
		pass

func _physics_process(_delta):
	if (current_state == TrainHazardState.ACTIVE):
		self.global_position.x = move_toward(self.global_position.x, target_x_pos, travel_speed * _delta)
		if (self.global_position.x == target_x_pos):
			current_state = TrainHazardState.IDLE
			current_direction *= -1
			collision_shape.position.x *= -1
			self.global_position = (left_start_point.global_position if current_direction > 0 else right_start_point.global_position)
			calculate_target_x()
			current_idle_timer = idle_interval

func initialize_train():
	if (is_train_disabled):
		is_train_disabled = false
		set_process_mode(PROCESS_MODE_INHERIT)
		set_process(true)
		set_physics_process(true)
		set_visible(true)
		current_state = TrainHazardState.IDLE
		current_direction = starting_direction
		self.global_position = (left_start_point.global_position if current_direction > 0 else right_start_point.global_position)
		if (collision_shape.position.x * current_direction > 0):
			collision_shape.position.x *= -1
		calculate_target_x()
		current_idle_timer = idle_interval

func disable_train():
	if (!is_train_disabled):
		is_train_disabled = true
		set_visible(false)
		set_process(false)
		set_physics_process(false)
		set_process_mode(PROCESS_MODE_DISABLED)

func calculate_target_x():
	var target_point = (right_start_point.global_position.x if current_direction > 0 else left_start_point.global_position.x)
	var target_offset = (collision_shape.shape.size.x if current_direction > 0 else -collision_shape.shape.size.x)
	target_x_pos = (target_point + target_offset)
	
	var current_x_pos = (left_start_point.global_position.x if current_direction > 0 else right_start_point.global_position.x)
	var distance : float = abs(target_x_pos - current_x_pos)
	travel_speed = ((distance / travel_duration) if speed_override <= 0 else speed_override)

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_detected = true
		for child in body.get_children():
			if (child is PlayerHub):
				player_ref = (child as PlayerHub)
				break

func _on_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_detected = false
		player_ref = null
