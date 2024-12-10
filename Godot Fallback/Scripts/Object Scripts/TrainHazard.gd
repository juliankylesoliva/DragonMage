extends Breakable

class_name TrainHazard

enum TrainHazardState {IDLE, ACTIVE}

@export_flags_2d_physics var hurtbox_collision_layers

@export var hurtbox_collision_shape : CollisionShape2D

@export var contact_collision_shape : CollisionShape2D

@export var contact_area : Area2D

@export_enum("Right:1", "Left:-1") var starting_direction : int = 1

@export var idle_interval : float = 3

@export var travel_duration : float = 5

@export var speed_override : float = 302.4

@export var left_start_point : Node2D

@export var right_start_point : Node2D

@export var damage_speed_modifier : float = 0.25

@export var speed_recovery_time : float = 5

@export_range(0, 1) var damage_flicker_alpha : float = 0.25

@export var train_sprites : Array[Sprite2D]

var is_train_disabled : bool = true

var is_player_detected : bool = false

var player_ref : PlayerHub = null

var current_state : TrainHazardState = TrainHazardState.IDLE

var current_direction : int = 1

var target_x_pos : float = 0

var travel_speed : float = 0

var current_speed_modifier : float = 1

var current_idle_timer : float = 0

var is_flickering : bool = false

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
		contact_area.monitoring = !is_slowed_down()
		self.collision_layer = (0 if is_slowed_down() else hurtbox_collision_layers)
		is_flickering = (!is_flickering if is_slowed_down() else false)
		self.modulate.a = (damage_flicker_alpha if is_flickering else 1.0)
		
		self.global_position.x = move_toward(self.global_position.x, target_x_pos, travel_speed * current_speed_modifier * _delta)
		current_speed_modifier = move_toward(current_speed_modifier, 1.0, ((1.0 - damage_speed_modifier) / speed_recovery_time) * _delta)
		if (self.global_position.x == target_x_pos):
			current_state = TrainHazardState.IDLE
			current_direction *= -1
			hurtbox_collision_shape.position.x *= -1
			contact_collision_shape.position.x *= -1
			for sprite in train_sprites:
				sprite.position.x *= -1
				sprite.flip_h = !sprite.flip_h
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
		self.collision_layer = hurtbox_collision_layers
		current_state = TrainHazardState.IDLE
		current_direction = starting_direction
		self.global_position = (left_start_point.global_position if current_direction > 0 else right_start_point.global_position)
		if (hurtbox_collision_shape.position.x * current_direction > 0):
			hurtbox_collision_shape.position.x *= -1
		if (contact_collision_shape.position.x * current_direction > 0):
			contact_collision_shape.position.x *= -1
		for sprite in train_sprites:
			if (sprite.position.x * current_direction > 0):
				sprite.position.x *= -1
				sprite.flip_h = (sprite.position.x > 0)
		calculate_target_x()
		current_idle_timer = idle_interval

func disable_train():
	if (!is_train_disabled):
		is_train_disabled = true
		self.collision_layer = 0
		set_visible(false)
		set_process(false)
		set_physics_process(false)
		call_deferred("set_process_mode", PROCESS_MODE_DISABLED)

func calculate_target_x():
	var target_point = (right_start_point.global_position.x if current_direction > 0 else left_start_point.global_position.x)
	var target_offset = (contact_collision_shape.shape.size.x if current_direction > 0 else -contact_collision_shape.shape.size.x)
	target_x_pos = (target_point + target_offset)
	
	var current_x_pos = (left_start_point.global_position.x if current_direction > 0 else right_start_point.global_position.x)
	var distance : float = abs(target_x_pos - current_x_pos)
	travel_speed = ((distance / travel_duration) if speed_override <= 0 else speed_override)
	restore_train_speed()

func is_slowed_down():
	return (current_speed_modifier < 1.0)

func restore_train_speed():
	current_speed_modifier = 1.0

func slow_down_train():
	current_speed_modifier = damage_speed_modifier

func break_object(other : Object):
	if ((other is KnockbackHitbox)):
		var hitbox_temp : KnockbackHitbox = (other as KnockbackHitbox)
		if (hitbox_temp.damage_strength >= break_durablility):
			if (breakable_by == "ANY" or hitbox_temp.damage_type == breakable_by):
				SoundFactory.play_sound_by_name(break_sound, hitbox_temp.global_position, -4)
				slow_down_train()
				on_break.emit()
				return true
	return false

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
