extends Attack

class_name FireTackleAttack

@export var fire_tackle_particles : CPUParticles2D

@export var fire_tackle_hitbox_scene : PackedScene

@export var fireball_scene : PackedScene

@export var fire_trail_scene : PackedScene

@export var fire_tackle_hit_temper_increase : int = 1

@export var fireball_hit_temper_increase : int = 2

@export var fire_tackle_hit_magic_gain : float = 2

@export var fireball_hit_magic_gain : float = 3

@export var fire_tackle_launch_temper_decrease : int = -1

@export var fire_tackle_hold_temper_decrease : int = -1

@export var fireball_launch_temper_decrease : int = -1

@export var fire_tackle_min_horizontal_speed : float = 6

@export var fire_tackle_max_horizontal_speed : float = 30

@export var fire_tackle_vertical_acceleration : float = 2

@export var fire_tackle_bonk_knockback : float = 3

@export var fire_tackle_startup_duration : float = 0.25

@export var fire_tackle_bump_immunity_duration : float = 0.2

@export var fire_tackle_duration : float = 0.5

@export var fire_tackle_slide_cancelable_time : float = 0.35

@export var fire_tackle_fireball_recoil_strength : float = 4

@export var fire_tackle_fireball_base_launch_speed : float = 4

@export var fire_tackle_fireball_inertia_multiplier : float = 0.5

@export var fire_tackle_endlag_duration : float = 0.25

@export var fire_tackle_endlag_deceleration : float = 20

@export var fire_tackle_endlag_cancelable_time : float = 0.125

@export_range(0, 1) var fire_tackle_slide_cancel_penalty : float = 0.4

@export var fire_tackle_floor_snap_distance : float = 32

@export var fire_tackle_max_ledge_nudge_ease : float = 1.5

@export var fire_tackle_max_velocity_magnitude_offset : float = 24

@export_color_no_alpha var fire_tackle_startup_color : Color = Color.WHITE

@export_color_no_alpha var fire_tackle_active_color : Color = Color.WHITE

@export_color_no_alpha var fire_tackle_jump_cancel_buffer_color : Color = Color.WHITE

@export_color_no_alpha var fire_tackle_endlag_color : Color = Color.WHITE

@export var fire_tackle_trail_spawn_interval : float = 0.05

@export var fire_tackle_startup_hold_temper_drain_interval : float = 0.8

@export var arrow_fwd_effect_name : String = "FireTackleArrowsForward"

@export var arrow_up_effect_name : String = "FireTackleArrowsUp"

@export var arrow_down_effect_name : String = "FireTackleArrowsDown"

var fire_tackle_hitbox_instance : Node = null

var fire_tackle_arrow_effect_instance : AnimatedSprite2D = null

var saved_floor_snap_distance : float = 0

var is_attack_button_held : bool = false
var current_windup_timer : float = 0
var current_startup_hold_timer : float = 0
var previous_horizontal_velocity : float = 0
var current_vertical_axis : float = 0

var was_interacting_with_wall : bool = false
var horizontal_result : float = 0
var snap_lerp : float = 0
var current_rising_speed : float = 0
var current_attack_timer : float = 0
var current_trail_spawn_timer : float = 0
var current_bump_immunity_timer : float = 0

var did_player_bump : bool = false
var is_player_firing_projectile : bool = false
var current_endlag_timer : float = 0
var is_fire_tackle_endlag_canceled : bool = false
var saved_endlag_velocity : float = 0

func can_use_attack():
	var state_name : String = hub.state_machine.current_state.name
	return (hub.form.current_mode == PlayerForm.CharacterMode.DRAGON and (!hub.movement.is_crouching or !hub.collisions.is_in_ceiling_when_uncrouched()) and !hub.jumping.is_fast_falling and state_name != "Attacking" and (hub.attacks.current_attack == null or hub.attacks.current_attack.name != self.name) and !hub.attacks.is_attack_cooldown_active())

func on_attack_state_enter():
	hub.movement.reset_crouch_state()
	saved_floor_snap_distance = hub.char_body.floor_snap_length
	is_attack_button_held = true
	startup_init()

func attack_state_process(_delta : float):
	if (hub.force_stand or hub.is_deactivated):
		end_fire_tackle()
	elif (current_attack_state == AttackState.STARTUP):
		startup_update(_delta)
		hub.camera.fire_tackle_camera_update(_delta, abs(horizontal_result), current_vertical_axis)
	elif (current_attack_state == AttackState.ACTIVE):
		active_update(_delta)
		hub.camera.update_x_lookahead(_delta)
		hub.camera.update_y_lookahead(_delta)
	elif (current_attack_state == AttackState.ENDLAG):
		endlag_update(_delta)
		hub.camera.update_x_lookahead(_delta)
		hub.camera.update_y_lookahead(_delta)
	else:
		pass

func on_attack_state_exit():
	hub.char_body.floor_snap_length = saved_floor_snap_distance
	saved_floor_snap_distance = 0
	
	current_windup_timer = 0
	current_startup_hold_timer = 0
	previous_horizontal_velocity = 0
	current_vertical_axis = 0
	
	was_interacting_with_wall = false
	horizontal_result = 0
	snap_lerp = 0
	current_rising_speed = 0
	current_attack_timer = 0
	current_trail_spawn_timer = 0
	current_bump_immunity_timer = 0
	
	did_player_bump = false
	is_player_firing_projectile = false
	current_endlag_timer = 0
	is_fire_tackle_endlag_canceled = false
	saved_endlag_velocity = 0

func startup_init():
	current_attack_state = AttackState.STARTUP
	hub.audio.play_sound("attack_draelyn_startup")
	hub.char_sprite.modulate = fire_tackle_startup_color
	hub.animation.set_animation("DraelynFireTackleWindup")
	hub.animation.set_animation_speed(1)
	current_windup_timer = fire_tackle_startup_duration
	current_startup_hold_timer = fire_tackle_startup_hold_temper_drain_interval
	previous_horizontal_velocity = abs(hub.char_body.velocity.x)
	current_vertical_axis = hub.get_input_vector().y
	was_interacting_with_wall = (hub.state_machine.previous_state.name == "WallVaulting" or hub.state_machine.previous_state.name == "WallClimbing")
	horizontal_result = min(((hub.jumping.stored_wall_climb_speed if was_interacting_with_wall else previous_horizontal_velocity) + fire_tackle_min_horizontal_speed), fire_tackle_max_horizontal_speed)
	
	var arrow_effect_name : String = (arrow_up_effect_name if current_vertical_axis > 0 else arrow_down_effect_name if current_vertical_axis < 0 else arrow_fwd_effect_name)
	fire_tackle_arrow_effect_instance = EffectFactory.get_effect(arrow_effect_name, hub.char_body.global_position, 1, hub.movement.get_facing_value() < 0)

func startup_update(delta : float):
	hub.buffers.refresh_speed_preservation_buffer()
	if ((current_windup_timer > 0 or is_attack_button_held) and !hub.damage.is_player_defeated and !hub.damage.is_player_damaged()):
		if (!Input.is_action_pressed("Attack")):
			is_attack_button_held = false
		hub.char_body.velocity = Vector2.ZERO
		hub.movement.set_facing_direction(hub.get_input_vector().x)
		if (hub.get_input_vector().y != 0 or hub.get_input_vector().x != 0):
			current_vertical_axis = hub.get_input_vector().y
		if (hub.char_body.is_on_floor() and current_vertical_axis < 0):
			current_vertical_axis = 0
		current_windup_timer = move_toward(current_windup_timer, 0, delta)
		if (!hub.temper.is_form_locked() and current_windup_timer <= 0 and current_startup_hold_timer > 0):
			current_startup_hold_timer -= delta
			if (current_startup_hold_timer <= 0):
				current_startup_hold_timer += fire_tackle_startup_hold_temper_drain_interval
				if (hub.temper.current_temper_level < hub.temper.hot_threshold):
					hub.temper.neutralize_temper_by(fire_tackle_hold_temper_decrease)
		
		if (fire_tackle_arrow_effect_instance != null):
			fire_tackle_arrow_effect_instance.set_animation(arrow_up_effect_name if current_vertical_axis > 0 else arrow_down_effect_name if current_vertical_axis < 0 else arrow_fwd_effect_name)
			fire_tackle_arrow_effect_instance.set_flip_h(hub.movement.get_facing_value() < 0)
			if ((fire_tackle_arrow_effect_instance.offset.x * hub.movement.get_facing_value()) < 0):
				fire_tackle_arrow_effect_instance.offset.x *= -1
	elif (hub.damage.is_player_defeated or hub.damage.is_player_damaged()):
		end_fire_tackle()
	else:
		active_init()

func active_init():
	current_attack_state = AttackState.ACTIVE
	if (fire_tackle_arrow_effect_instance != null):
		fire_tackle_arrow_effect_instance.queue_free()
	hub.audio.play_sound("attack_draelyn_tackle")
	fire_tackle_particles.emitting = true
	hub.char_sprite.modulate = fire_tackle_active_color
	hub.sprite_trail.activate_trail()
	hub.animation.set_animation("DraelynFireTackleActive")
	hub.animation.set_animation_speed(1)
	current_rising_speed = 0
	hub.char_body.velocity = Vector2(horizontal_result * hub.movement.get_facing_value(), (-abs(hub.char_body.velocity.x) if current_vertical_axis > 0 else 0))
	hub.movement.set_facing_direction(hub.char_body.velocity.x)
	current_attack_timer = fire_tackle_duration
	current_bump_immunity_timer = fire_tackle_bump_immunity_duration
	if (!hub.temper.is_form_locked()):
		hub.temper.neutralize_temper_by(fire_tackle_launch_temper_decrease)
	
	fire_tackle_hitbox_instance = fire_tackle_hitbox_scene.instantiate()
	add_child(fire_tackle_hitbox_instance)
	(fire_tackle_hitbox_instance as Node2D).global_position = hub.collision_shape.global_position
	(fire_tackle_hitbox_instance as KnockbackHitbox).hit.connect(_on_fire_tackle_hit)
	(fire_tackle_hitbox_instance as FireTackleKnockbackHitbox).player_body = hub.char_body
	
	snap_lerp = (horizontal_result / fire_tackle_max_horizontal_speed)
	hub.char_body.floor_snap_length = lerp(saved_floor_snap_distance, fire_tackle_floor_snap_distance, pow(snap_lerp, 2))

func active_update(delta : float):
	hub.buffers.refresh_speed_preservation_buffer()
	if (current_attack_timer > 0 and ((current_bump_immunity_timer > 0 and (!can_cancel_fire_tackle_endlag() or hub.temper.is_form_locked())) or (!hub.collisions.is_facing_a_wall() and !(hub.char_body.is_on_ceiling() and !hub.char_body.is_on_floor())))):
		if (!hub.temper.is_forcing_form_change() and current_attack_timer <= fire_tackle_slide_cancelable_time and hub.char_body.is_on_floor() and Input.is_action_pressed("Crouch")):
			var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name)
			if (selected_attack != null):
				hub.buffers.reset_attack_buffer()
				hub.attacks.set_queued_attack(selected_attack)
				hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Attacking"))
				hub.char_body.velocity.x *= fire_tackle_slide_cancel_penalty
				hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
				end_fire_tackle()
				return
		
		if (current_attack_timer <= hub.buffers.jump_buffer_time):
			hub.char_sprite.modulate = fire_tackle_jump_cancel_buffer_color
		
		hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value() if !hub.collisions.is_facing_a_wall() else 0.0)
		if (current_vertical_axis > 0):
			current_rising_speed -= (fire_tackle_vertical_acceleration * delta)
			hub.char_body.velocity.y = current_rising_speed
		elif (current_vertical_axis < 0):
			if (hub.char_body.is_on_floor()):
				current_vertical_axis = 0
				hub.jumping.landing_reset()
			else:
				hub.char_body.velocity.y = abs(hub.char_body.velocity.x)
		else:
			hub.char_body.velocity = (Vector2.RIGHT * (horizontal_result * hub.movement.get_facing_value() if !hub.collisions.is_facing_a_wall() else 0.0))
		
		if (current_vertical_axis <= 0 and (hub.char_body.is_on_floor() or hub.collisions.get_distance_to_ground() <= fire_tackle_floor_snap_distance)):
			hub.char_body.apply_floor_snap()
			hub.jumping.landing_reset()
		
		if (hub.char_body.is_on_floor() and current_vertical_axis <= 0 and current_trail_spawn_timer >= 0):
			current_trail_spawn_timer -= (hub.char_body.velocity.length() * delta)
			if (current_trail_spawn_timer <= 0):
				current_trail_spawn_timer += fire_tackle_trail_spawn_interval
				var trail_instance : Node = fire_trail_scene.instantiate()
				add_sibling(trail_instance)
				(trail_instance as Node2D).global_position = hub.collisions.get_ground_point()
		else:
			current_trail_spawn_timer = 0
		
		var normalized_velocity : Vector2 = hub.char_body.velocity.normalized()
		var velocity_offset : float = min(hub.char_body.velocity.length(), fire_tackle_max_velocity_magnitude_offset)
		
		(fire_tackle_hitbox_instance as Node2D).global_position = (hub.collision_shape.global_position + (normalized_velocity * velocity_offset))
		
		var temp_velocity = -hub.char_body.velocity.normalized()
		fire_tackle_particles.direction = Vector2(temp_velocity.x, temp_velocity.y)
		
		var intended_velocity : Vector2 = hub.char_body.velocity
		hub.char_body.move_and_slide()
		hub.collisions.upward_slope_correction(intended_velocity)
		
		current_attack_timer = move_toward(current_attack_timer, 0, delta)
		current_bump_immunity_timer = move_toward(current_bump_immunity_timer, 0, delta)
	else:
		endlag_init()

func endlag_init():
	if (fire_tackle_hitbox_instance != null):
		fire_tackle_hitbox_instance.queue_free()
	
	current_attack_state = AttackState.ENDLAG
	fire_tackle_particles.emitting = false
	hub.char_sprite.modulate = fire_tackle_endlag_color
	hub.sprite_trail.deactivate_trail()
	did_player_bump = false
	is_player_firing_projectile = false
	if (hub.collisions.is_facing_a_wall() and hub.jumping.can_wall_climb_from_fire_tackle() and !hub.temper.is_forcing_form_change()):
		hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value())
		end_fire_tackle()
	elif (hub.collisions.is_facing_a_wall() or (hub.char_body.is_on_ceiling() and !hub.char_body.is_on_floor())):
		hub.audio.play_sound("attack_draelyn_bump")
		did_player_bump = true
		hub.char_body.floor_snap_length = saved_floor_snap_distance
		hub.buffers.reset_speed_preservation_buffer()
		hub.movement.reset_current_horizontal_velocity()
		hub.animation.set_animation("DraelynFireTackleBumped")
		hub.animation.set_animation_speed(1)
		hub.char_body.velocity = ((Vector2.UP + (Vector2.RIGHT * -hub.movement.get_facing_value())).normalized() * fire_tackle_bonk_knockback)
	else:
		if (!hub.jumping.can_wall_climb_from_fire_tackle() and (hub.buffers.is_attack_buffer_active() or Input.is_action_pressed("Attack"))):
			hub.buffers.reset_attack_buffer()
			hub.buffers.reset_speed_preservation_buffer()
			
			hub.audio.play_sound("attack_draelyn_fireball")
			hub.animation.set_animation("DraelynFireTackleFireball")
			hub.animation.set_animation_speed(1)
			is_player_firing_projectile = true
			
			var fireball_instance = fireball_scene.instantiate()
			add_sibling(fireball_instance)
			var fireball_speed : float = ((fire_tackle_fireball_base_launch_speed + (horizontal_result * fire_tackle_fireball_inertia_multiplier)) * hub.movement.get_facing_value())
			(fireball_instance as Node2D).global_position = hub.char_body.global_position
			(fireball_instance as RigidBody2D).linear_velocity.x = fireball_speed
			for child in fireball_instance.get_children():
				if (child is AnimatedSprite2D):
					(child as AnimatedSprite2D).flip_h = (hub.movement.get_facing_value() < 0)
				elif (child is KnockbackHitbox):
					(child as KnockbackHitbox).hit.connect(_on_fireball_hit)
				else:
					pass
			if (!hub.temper.is_form_locked()):
				hub.temper.neutralize_temper_by(fireball_launch_temper_decrease)
			hub.movement.reset_current_horizontal_velocity()
			hub.char_body.velocity = (((Vector2.UP if !hub.char_body.is_on_floor() else Vector2.ZERO) + (Vector2.RIGHT * -hub.movement.get_facing_value())).normalized() * fire_tackle_fireball_recoil_strength)
		elif (!hub.temper.is_forcing_form_change() and hub.char_body.is_on_floor() and Input.is_action_pressed("Crouch")):
			var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name)
			if (selected_attack != null):
				hub.buffers.reset_attack_buffer()
				hub.attacks.set_queued_attack(selected_attack)
				hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Attacking"))
				hub.char_body.velocity.x *= fire_tackle_slide_cancel_penalty
				hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
				end_fire_tackle()
		else:
			saved_endlag_velocity = hub.char_body.velocity.x
			hub.audio.play_sound("attack_draelyn_endlag", -2)
			hub.animation.set_animation("DraelynFireTackleEndlag")
			hub.animation.set_animation_speed(1)
	
	hub.jumping.switch_to_falling_gravity()
	current_endlag_timer = (fire_tackle_endlag_cancelable_time if hub.jumping.can_wall_climb_from_fire_tackle() else fire_tackle_endlag_duration)

func endlag_update(delta : float):
	if (current_endlag_timer > 0 and !is_fire_tackle_endlag_canceled and !hub.damage.is_player_defeated and !hub.damage.is_player_damaged()):
		if (!hub.temper.is_forcing_form_change() and !is_player_firing_projectile and !did_player_bump and hub.char_body.is_on_floor() and Input.is_action_pressed("Crouch")):
			var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name)
			if (selected_attack != null):
				hub.buffers.reset_attack_buffer()
				hub.attacks.set_queued_attack(selected_attack)
				hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Attacking"))
				hub.char_body.velocity.x *= fire_tackle_slide_cancel_penalty
				hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
				end_fire_tackle()
				return
		
		if (!is_player_firing_projectile and !did_player_bump and current_endlag_timer <= fire_tackle_endlag_cancelable_time and can_cancel_fire_tackle_endlag()):
			is_fire_tackle_endlag_canceled = true
			if (hub.buffers.is_jump_buffer_active()):
				hub.buffers.refresh_jump_buffer()
			elif (hub.jumping.can_wall_climb_from_fire_tackle()):
				hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value())
			else:
				if (hub.char_body.is_on_floor() or hub.jumping.can_midair_jump()):
					hub.buffers.reset_jump_buffer()
			return
		elif (!did_player_bump and hub.char_body.is_on_floor() and hub.char_body.velocity.x != 0):
			saved_endlag_velocity = hub.char_body.velocity.x
			hub.char_body.velocity.x = (0.0 if hub.collisions.is_facing_a_wall() or hub.collisions.is_near_a_ledge(hub.movement.get_facing_value()) else move_toward(hub.char_body.velocity.x, 0, delta * fire_tackle_endlag_deceleration))
			hub.collisions.do_ledge_nudge(lerp(hub.collisions.ledge_nudge_easing, fire_tackle_max_ledge_nudge_ease, abs(hub.char_body.velocity.x) / fire_tackle_max_horizontal_speed))
			hub.char_body.apply_floor_snap()
			hub.jumping.landing_reset()
		elif (did_player_bump and hub.char_body.is_on_floor() and current_endlag_timer < fire_tackle_endlag_cancelable_time):
			hub.movement.reset_current_horizontal_velocity()
			hub.char_body.velocity.x = 0
		else:
			pass
		
		hub.char_body.velocity.y += hub.jumping.get_gravity_delta(delta)
		if (hub.char_body.velocity.y > hub.jumping.max_fall_speed):
			hub.char_body.velocity.y = hub.jumping.max_fall_speed
		
		var intended_velocity : Vector2 = hub.char_body.velocity
		hub.char_body.move_and_slide()
		hub.collisions.upward_slope_correction(intended_velocity)
		
		if (hub.char_body.velocity == Vector2.ZERO and hub.char_body.is_on_ceiling()):
			hub.char_body.velocity.x = saved_endlag_velocity
		
		current_endlag_timer = move_toward(current_endlag_timer, 0, delta)
	else:
		end_fire_tackle()

func can_cancel_fire_tackle_endlag():
	return (!hub.temper.is_forcing_form_change() and (hub.jumping.can_wall_climb_from_fire_tackle() or ((hub.get_input_vector().x * hub.movement.get_facing_value()) > 0 and (hub.buffers.is_jump_buffer_active() and (hub.char_body.is_on_floor() or hub.jumping.can_midair_jump())))))

func end_fire_tackle():
	current_attack_state = AttackState.NOTHING
	fire_tackle_particles.emitting = false
	hub.sprite_trail.deactivate_trail()
	
	if (hub.stream_player.playing):
		hub.stream_player.stop()
	
	if (fire_tackle_hitbox_instance != null):
		fire_tackle_hitbox_instance.queue_free()
	
	if (fire_tackle_arrow_effect_instance != null):
		fire_tackle_arrow_effect_instance.queue_free()
	
	hub.char_body.floor_snap_length = saved_floor_snap_distance
	
	hub.char_sprite.modulate = Color.WHITE
	hub.movement.current_horizontal_velocity = (hub.char_body.velocity.x if !hub.damage.is_player_damaged() else 0.0)
	if (abs(hub.movement.current_horizontal_velocity) > hub.buffers.highest_speed and !hub.damage.is_player_damaged()):
		hub.buffers.highest_speed = abs(hub.movement.current_horizontal_velocity)
		hub.buffers.refresh_speed_preservation_buffer()
	
	hub.attacks.set_attack_cooldown_timer()
	
	if (!is_fire_tackle_endlag_canceled and !hub.damage.is_player_damaged()):
		hub.form.start_form_change_cooldown_timer()
	
	if (hub.is_deactivated):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Deactivated"))
	elif (hub.force_stand):
		if (!hub.char_body.is_on_floor()):
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Falling"))
		else:
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))
	elif (hub.damage.is_player_defeated):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Damaged"))
	elif (hub.temper.is_forcing_form_change()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("FormChanging"))
	elif (hub.jumping.can_wall_climb_from_fire_tackle()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("WallClimbing"))
	elif (is_fire_tackle_endlag_canceled and hub.buffers.is_jump_buffer_active()):
		if (hub.char_body.is_on_floor()):
			hub.jumping.start_ground_jump()
		else:
			if (hub.jumping.can_midair_jump()):
				hub.jumping.do_midair_jump()
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))
	elif (hub.char_body.is_on_floor() and (hub.get_input_vector().x != 0 or hub.char_body.velocity.x != 0)):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Running"))
	elif (hub.char_body.velocity.y < 0 and !hub.char_body.is_on_floor()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))
	elif (hub.char_body.velocity.y >= 0 and !hub.char_body.is_on_floor()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Falling"))
	else:
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))

func _on_fire_tackle_hit():
	hub.fairy.change_current_magic_by(fire_tackle_hit_magic_gain)
	if (hub.temper.is_form_locked()):
		hub.temper.neutralize_temper_by(-fire_tackle_hit_temper_increase)
	else:
		hub.temper.neutralize_temper_by(fire_tackle_hit_temper_increase)

func _on_fireball_hit():
	hub.fairy.change_current_magic_by(fireball_hit_magic_gain)
	if (hub.temper.is_form_locked()):
		hub.temper.neutralize_temper_by(-fireball_hit_temper_increase)
	else:
		hub.temper.neutralize_temper_by(fireball_hit_temper_increase)
