extends TrainHazard

class_name TrainBoss

@export var drop_off_player : bool = false

@export var drop_off_location : Node2D

@export var drop_off_offset : float = 64

@export var is_one_shot : bool = false

@export var boss : Boss

@export var warp : WarpTrigger

func _physics_process(_delta):
	if (current_state == TrainHazardState.ACTIVE):
		contact_area.monitoring = (!is_slowed_down() and !took_damage())
		warp.monitoring = is_slowed_down()
		self.collision_layer = (0 if is_slowed_down() or took_damage() else hurtbox_collision_layers)
		is_flickering = (!is_flickering if is_slowed_down() or took_damage() else false)
		self.modulate.a = (damage_flicker_alpha if is_flickering else 1.0)
		
		self.global_position.x = move_toward(self.global_position.x, target_x_pos, travel_speed * current_speed_modifier * _delta)
		if (self.global_position.x == target_x_pos):
			if (is_one_shot):
				if (boss.current_health <= 0):
					boss.on_defeat()
				disable_train()
				return
			current_state = TrainHazardState.IDLE
			current_direction *= -1
			hurtbox_collision_shape.position.x *= -1
			contact_collision_shape.position.x *= -1
			warp.position.x *= -1
			self.global_position = (left_start_point.global_position if current_direction > 0 else right_start_point.global_position)
			calculate_target_x()
			current_idle_timer = idle_interval
			if (boss.current_armor > 0):
				boss.reset_post_damage_invulnerability()
			else:
				boss.current_armor += 1
				restore_train_speed()

func initialize_train():
	if (is_train_disabled):
		var is_dropping_off : bool = (drop_off_player and drop_off_location != null)
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
		if (warp.position.x * current_direction > 0):
			warp.position.x *= -1
		calculate_target_x()
		current_idle_timer = (0.0 if is_dropping_off else idle_interval)
		boss.reset_post_damage_invulnerability()
		restore_train_speed()
		if (is_dropping_off):
			boss.do_post_damage_invulnerability()
			self.global_position.x = (drop_off_location.global_position.x + ((contact_collision_shape.shape.size.x - drop_off_offset) * current_direction))
			current_state = TrainHazardState.ACTIVE

func calculate_target_x():
	var target_point = (right_start_point.global_position.x if current_direction > 0 else left_start_point.global_position.x)
	var target_offset = (contact_collision_shape.shape.size.x if current_direction > 0 else -contact_collision_shape.shape.size.x)
	target_x_pos = (target_point + target_offset)
	
	var current_x_pos = (left_start_point.global_position.x if current_direction > 0 else right_start_point.global_position.x)
	var distance : float = abs(target_x_pos - current_x_pos)
	travel_speed = ((distance / travel_duration) if speed_override <= 0 else speed_override)

func break_object(other : Object):
	if (!took_damage() and (other is KnockbackHitbox)):
		var hitbox_temp : KnockbackHitbox = (other as KnockbackHitbox)
		if (hitbox_temp.damage_strength >= break_durablility):
			if (breakable_by == "ANY" or hitbox_temp.damage_type == breakable_by):
				SoundFactory.play_sound_by_name(break_sound, hitbox_temp.global_position, -4)
				boss.damage_boss(hitbox_temp.damage_type, hitbox_temp.damage_strength, Vector2.ZERO)
				if (boss.current_armor <= 0):
					slow_down_train()
				return true
	return false

func took_damage():
	return (boss.current_invulnerability_duration > 0 or boss.current_armor <= 0)
