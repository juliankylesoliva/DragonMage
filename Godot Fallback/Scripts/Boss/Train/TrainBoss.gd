extends TrainHazard

class_name TrainBoss

@export var drop_off_player : bool = false

@export var drop_off_location : Node2D

@export var drop_off_offset : float = 64

@export var is_one_shot : bool = false

@export var boss : Boss

@export var warp : WarpTrigger

@export var warp_sprite : Sprite2D

@export var magic_sign_sprite : Sprite2D

@export var fire_sign_sprite : Sprite2D

var show_drop_off_display : bool = false

func _process(_delta):
	if (current_state == TrainHazardState.IDLE and current_idle_timer > 0):
		current_idle_timer = move_toward(current_idle_timer, 0, _delta)
		if (current_idle_timer <= 0):
			current_state = TrainHazardState.ACTIVE
			train_horn.set_stream(train_horn_sfx_streams.pick_random())
			train_horn.play()
			train_chugging.play()
			train_track_clicking.play()
			
	elif (current_state == TrainHazardState.ACTIVE and player_ref != null and is_player_detected):
		if (player_ref.damage.do_damage_warp()):
			EffectFactory.get_effect("EnemyContactImpact", player_ref.char_body.global_position)
			SoundFactory.play_sound_by_name("enemy_contact_impact", player_ref.char_body.global_position, 0, 1, "SFX")
		elif (player_ref.damage.is_player_parrying()):
			SoundFactory.play_sound_by_name(break_sound, self.global_position, -4)
			boss.damage_boss("PARRY", 0, Vector2.ZERO)
			if (boss.current_armor <= 0):
				train_horn.set_stream(train_horn_stun_sfx_stream)
				train_horn.play()
				train_chugging.stop()
				train_track_clicking.stop()
				slow_down_train()
		else:
			pass
	else:
		pass

func _physics_process(_delta):
	if (current_state == TrainHazardState.ACTIVE):
		contact_area.monitoring = (!is_slowed_down() and !took_damage())
		warp.monitoring = is_slowed_down()
		warp_sprite.set_visible(warp.monitoring)
		self.collision_layer = (0 if is_slowed_down() or took_damage() else hurtbox_collision_layers)
		is_flickering = (!is_flickering if is_slowed_down() or took_damage() else false)
		self.modulate.a = (damage_flicker_alpha if is_flickering else 1.0)
		sparks.set_visible(is_slowed_down())
		
		self.global_position.x = move_toward(self.global_position.x, target_x_pos, travel_speed * current_speed_modifier * _delta)
		if (self.global_position.x == target_x_pos):
			train_horn.stop()
			train_chugging.stop()
			train_track_clicking.stop()
			show_drop_off_display = false
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
			for sprite in train_sprites:
				sprite.position.x *= -1
				sprite.flip_h = !sprite.flip_h
			self.global_position = (left_start_point.global_position if current_direction > 0 else right_start_point.global_position)
			calculate_target_x()
			current_idle_timer = idle_interval
			set_weakness()
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
		show_drop_off_display = is_dropping_off
		self.global_position = (left_start_point.global_position if current_direction > 0 else right_start_point.global_position)
		if (hurtbox_collision_shape.position.x * current_direction > 0):
			hurtbox_collision_shape.position.x *= -1
		if (contact_collision_shape.position.x * current_direction > 0):
			contact_collision_shape.position.x *= -1
		if (warp.position.x * current_direction > 0):
			warp.position.x *= -1
		for sprite in train_sprites:
			if (sprite.position.x * current_direction > 0):
				sprite.position.x *= -1
				sprite.flip_h = (sprite.position.x > 0)
		calculate_target_x()
		current_idle_timer = (0.0 if is_dropping_off else idle_interval)
		boss.reset_post_damage_invulnerability()
		restore_train_speed()
		set_weakness()
		if (is_dropping_off):
			boss.do_post_damage_invulnerability()
			self.global_position.x = (drop_off_location.global_position.x + ((contact_collision_shape.shape.size.x - drop_off_offset) * current_direction))
			current_state = TrainHazardState.ACTIVE
			train_horn.set_stream(train_horn_sfx_streams.pick_random())
			train_horn.play()
			train_chugging.play()
			train_track_clicking.play()

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
					train_horn.set_stream(train_horn_stun_sfx_stream)
					train_horn.play()
					train_chugging.stop()
					train_track_clicking.stop()
					slow_down_train()
				return true
	return false

func took_damage():
	return (boss.current_invulnerability_duration > 0 or boss.current_armor <= 0)

func get_damage_duration_display():
	if (boss.current_armor > 0):
		return (calculate_remaining_travel_time() if show_drop_off_display else boss.current_invulnerability_duration)
	else:
		return calculate_remaining_travel_time()

func set_weakness():
	breakable_by = ("MAGIC" if current_direction > 0 else "FIRE")
	match breakable_by:
		"MAGIC":
			magic_sign_sprite.set_visible(true)
			fire_sign_sprite.set_visible(false)
		"FIRE":
			magic_sign_sprite.set_visible(false)
			fire_sign_sprite.set_visible(true)
		_:
			magic_sign_sprite.set_visible(false)
			fire_sign_sprite.set_visible(false)
