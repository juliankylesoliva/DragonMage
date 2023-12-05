extends Attack

class_name FireTackleAttack

@export var fireball_scene : PackedScene

@export var fire_tackle_min_horizontal_speed : float = 6

@export var fire_tackle_max_horizontal_speed : float = 30

@export var fire_tackle_vertical_acceleration : float = 2

@export var fire_tackle_bonk_knockback : float = 3

@export var fire_tackle_startup_duration : float = 0.25

@export var fire_tackle_bump_immunity_duration : float = 0.2

@export var fire_tackle_duration : float = 0.5

@export var fire_tackle_fireball_recoil_strength : float = 4

@export var fire_tackle_fireball_base_launch_speed : float = 4

@export var fire_tackle_fireball_inertia_multiplier : float = 0.5

@export var fire_tackle_endlag_duration : float = 0.25

@export var fire_tackle_endlag_deceleration : float = 20

@export var fire_tackle_endlag_cancelable_time : float = 0.125

@export var fire_tackle_floor_snap_distance : float = 32

@export var fire_tackle_startup_hold_temper_drain_interval : float = 0.8

var is_attack_button_held : bool = false
var current_windup_timer : float = 0
var current_startup_hold_timer : float = 0
var previous_horizontal_velocity : float = 0
var current_vertical_axis : float = 0

var was_interacting_with_wall : bool = false
var horizontal_result : float = 0
var current_rising_speed : float = 0
var current_attack_timer : float = 0
var current_bump_immunity_timer : float = 0

var did_player_bump : bool = false
var is_player_firing_projectile : bool = false
var current_endlag_timer : float = 0
var is_fire_tackle_endlag_canceled : bool = false

func can_use_attack():
	var state_name : String = hub.state_machine.current_state.name
	return (hub.form.current_mode == PlayerForm.CharacterMode.DRAGON and (!hub.movement.is_crouching or !hub.collisions.is_in_ceiling_when_uncrouched()) and !hub.jumping.is_fast_falling and state_name != "Attacking" and (hub.attacks.current_attack == null or hub.attacks.current_attack.name != self.name) and !hub.attacks.is_attack_cooldown_active())

func on_attack_state_enter():
	hub.movement.reset_crouch_state()
	is_attack_button_held = true
	startup_init()

func attack_state_process(_delta : float):
	if (current_attack_state == AttackState.STARTUP):
		startup_update(_delta)
	elif (current_attack_state == AttackState.ACTIVE):
		active_update(_delta)
	elif (current_attack_state == AttackState.ENDLAG):
		endlag_update(_delta)
	else:
		pass

func on_attack_state_exit():
	current_windup_timer = 0
	current_startup_hold_timer = 0
	previous_horizontal_velocity = 0
	current_vertical_axis = 0
	
	was_interacting_with_wall = false
	horizontal_result = 0
	current_rising_speed = 0
	current_attack_timer = 0
	current_bump_immunity_timer = 0
	
	did_player_bump = false
	is_player_firing_projectile = false
	current_endlag_timer = 0
	is_fire_tackle_endlag_canceled = false

func startup_init():
	current_attack_state = AttackState.STARTUP
	hub.animation.set_animation("DraelynFireTackleWindup")
	hub.animation.set_animation_speed(1)
	current_windup_timer = fire_tackle_startup_duration
	current_startup_hold_timer = fire_tackle_startup_hold_temper_drain_interval
	previous_horizontal_velocity = abs(hub.char_body.velocity.x)
	current_vertical_axis = 0

func startup_update(delta : float):
	if ((current_windup_timer > 0 or is_attack_button_held)):
		if (!Input.is_action_pressed("Attack")):
			is_attack_button_held = false
		hub.char_body.velocity = Vector2.ZERO
		hub.movement.set_facing_direction(hub.get_input_vector().x)
		current_vertical_axis = hub.get_input_vector().y
		if (hub.char_body.is_on_floor() and current_vertical_axis < 0):
			current_vertical_axis = 0
		current_windup_timer = move_toward(current_windup_timer, 0, delta)
		if (current_windup_timer <= 0 and current_startup_hold_timer > 0):
			current_startup_hold_timer -= delta
			if (current_startup_hold_timer <= 0):
				current_startup_hold_timer += fire_tackle_startup_hold_temper_drain_interval
				# temper drain
	else:
		active_init()

func active_init():
	current_attack_state = AttackState.ACTIVE
	hub.animation.set_animation("DraelynFireTackleActive")
	hub.animation.set_animation_speed(1)
	was_interacting_with_wall = (hub.state_machine.previous_state.name == "WallVaulting" or hub.state_machine.previous_state.name == "WallClimbing")
	horizontal_result = (min(((hub.jumping.stored_wall_climb_speed if was_interacting_with_wall else previous_horizontal_velocity) + fire_tackle_min_horizontal_speed), fire_tackle_max_horizontal_speed) * hub.movement.get_facing_value())
	current_rising_speed = 0
	hub.char_body.velocity = Vector2(horizontal_result, (-abs(hub.char_body.velocity.x) if current_vertical_axis > 0 else 0))
	current_attack_timer = fire_tackle_duration
	current_bump_immunity_timer = fire_tackle_bump_immunity_duration

func active_update(delta : float):
	if (current_attack_timer > 0 and (current_bump_immunity_timer > 0 or (!hub.collisions.is_facing_a_wall() and !hub.char_body.is_on_ceiling()))):
		hub.char_body.velocity.x = (horizontal_result if !hub.collisions.is_facing_a_wall() else 0.0)
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
			hub.char_body.velocity = (Vector2.RIGHT * (horizontal_result if !hub.collisions.is_facing_a_wall() else 0.0))
		
		if (current_vertical_axis <= 0 and (hub.char_body.is_on_floor() or hub.collisions.get_distance_to_ground() <= fire_tackle_floor_snap_distance)):
			hub.char_body.apply_floor_snap()
		
		# Trail effect here
		
		hub.char_body.move_and_slide()
		current_attack_timer = move_toward(current_attack_timer, 0, delta)
		current_bump_immunity_timer = move_toward(current_bump_immunity_timer, 0, delta)
	else:
		endlag_init()

func endlag_init():
	current_attack_state = AttackState.ENDLAG
	did_player_bump = false
	is_player_firing_projectile = false
	if (hub.collisions.is_facing_a_wall() or hub.char_body.is_on_ceiling()):
		did_player_bump = true
		hub.buffers.reset_speed_preservation_buffer()
		hub.movement.reset_current_horizontal_velocity()
		hub.animation.set_animation("DraelynFireTackleBumped")
		hub.animation.set_animation_speed(1)
		hub.char_body.velocity = ((Vector2.UP + (Vector2.RIGHT * -hub.movement.get_facing_value())).normalized() * fire_tackle_bonk_knockback)
	else:
		if (hub.buffers.is_attack_buffer_active() or Input.is_action_pressed("Attack")):
			hub.buffers.reset_attack_buffer()
			hub.buffers.reset_speed_preservation_buffer()
			
			hub.animation.set_animation("DraelynFireTackleFireball")
			hub.animation.set_animation_speed(1)
			is_player_firing_projectile = true
			
			var fireball_instance = fireball_scene.instantiate()
			add_sibling(fireball_instance)
			var fireball_speed : float = ((fire_tackle_fireball_base_launch_speed * hub.movement.get_facing_value()) + (horizontal_result * fire_tackle_fireball_inertia_multiplier))
			(fireball_instance as Node2D).global_position = hub.char_body.global_position
			(fireball_instance as RigidBody2D).linear_velocity.x = fireball_speed
			for child in fireball_instance.get_children():
				if (child is AnimatedSprite2D):
					(child as AnimatedSprite2D).flip_h = (hub.movement.get_facing_value() < 0)
					break
			
			hub.movement.reset_current_horizontal_velocity()
			hub.char_body.velocity = (((Vector2.UP if !hub.char_body.is_on_floor() else Vector2.ZERO) + (Vector2.RIGHT * -hub.movement.get_facing_value())).normalized() * fire_tackle_fireball_recoil_strength)
		else:
			hub.animation.set_animation("DraelynFireTackleEndlag")
			hub.animation.set_animation_speed(1)
	
	hub.jumping.switch_to_falling_gravity()
	current_endlag_timer = fire_tackle_endlag_duration

func endlag_update(delta : float):
	if (current_endlag_timer > 0 and !is_fire_tackle_endlag_canceled):
		if (!is_player_firing_projectile and !did_player_bump and current_endlag_timer < fire_tackle_endlag_cancelable_time and can_cancel_fire_tackle_endlag()):
			is_fire_tackle_endlag_canceled = true
			if (hub.buffers.is_jump_buffer_active() and hub.char_body.is_on_floor()):
				hub.buffers.refresh_jump_buffer()
			elif (hub.jumping.can_wall_climb_from_fire_tackle()):
				hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value())
			else:
				hub.buffers.reset_jump_buffer()
			return
		elif (!did_player_bump and hub.char_body.is_on_floor() and hub.char_body.velocity.x != 0):
			hub.char_body.velocity.x = (0.0 if hub.collisions.is_facing_a_wall() or hub.collisions.is_near_a_ledge() else move_toward(hub.char_body.velocity.x, 0, delta * fire_tackle_endlag_deceleration))
			hub.collisions.do_ledge_nudge()
			hub.char_body.apply_floor_snap()
		elif (did_player_bump and hub.char_body.is_on_floor() and current_endlag_timer < fire_tackle_endlag_cancelable_time):
			hub.movement.reset_current_horizontal_velocity()
			hub.char_body.velocity.x = 0
		else:
			pass
		
		hub.char_body.velocity.y += hub.jumping.get_gravity_delta(delta)
		hub.char_body.move_and_slide()
		
		current_endlag_timer = move_toward(current_endlag_timer, 0, delta)
	else:
		end_fire_tackle()

func can_cancel_fire_tackle_endlag():
	return (true and (hub.jumping.can_wall_climb_from_fire_tackle() or (hub.get_input_vector().x * hub.movement.get_facing_value()) > 0 and hub.char_body.is_on_floor() and hub.buffers.is_jump_buffer_active()))

func end_fire_tackle():
	current_attack_state = AttackState.NOTHING
	
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	if (abs(hub.movement.current_horizontal_velocity) > hub.buffers.highest_speed):
		hub.buffers.highest_speed = hub.movement.current_horizontal_velocity
		hub.buffers.refresh_speed_preservation_buffer()
	
	hub.attacks.set_attack_cooldown_timer()
	hub.form.start_form_change_timer()
	
	if (hub.jumping.can_wall_climb_from_fire_tackle()):
		hub.state_machine.switch_states(hub.state_machine.get_state_by_name("WallClimbing"))
	elif (is_fire_tackle_endlag_canceled and hub.buffers.is_jump_buffer_active()):
		hub.jumping.start_ground_jump()
		hub.state_machine.switch_states(hub.state_machine.get_state_by_name("Jumping"))
	elif (hub.char_body.is_on_floor() and (hub.get_input_vector().x != 0 or hub.char_body.velocity.x != 0)):
		hub.state_machine.switch_states(hub.state_machine.get_state_by_name("Running"))
	elif (hub.char_body.velocity.y < 0 and !hub.char_body.is_on_floor()):
		hub.state_machine.switch_states(hub.state_machine.get_state_by_name("Jumping"))
	elif (hub.char_body.velocity.y >= 0 and !hub.char_body.is_on_floor()):
		hub.state_machine.switch_states(hub.state_machine.get_state_by_name("Falling"))
	else:
		hub.state_machine.switch_states(hub.state_machine.get_state_by_name("Standing"))
