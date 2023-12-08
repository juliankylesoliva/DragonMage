extends Attack

class_name DodgeAttack

@export var dodge_initial_speed : float = 8

@export var dodge_deceleration : float = 8

@export var dodge_floor_snap_distance : float = 12

@export var slope_threshold : float = 0.4

var was_jump_input_on_first_frame : bool = false

var current_dodge_speed : float = 0

var did_player_leave_ground : bool = false

var dodge_direction : Vector2 = Vector2.ZERO

func can_use_attack():
	var state_name : String = hub.state_machine.current_state.name
	return (hub.form.current_mode == PlayerForm.CharacterMode.MAGE and state_name != "Attacking" and (hub.attacks.current_attack == null or hub.attacks.current_attack.name != self.name) and !hub.attacks.is_attack_cooldown_active() and hub.movement.is_crouching)

func on_attack_state_enter():
	current_attack_state = AttackState.ACTIVE
	SoundFactory.play_sound_by_name("movement_magli_dodge", hub.char_body.global_position, 0, 1, "SFX")
	was_jump_input_on_first_frame = (Input.is_action_just_pressed("Jump") or hub.state_machine.previous_state.name == "Jumping" or hub.state_machine.previous_state.name == "Falling")
	hub.jumping.switch_to_zero_gravity()
	hub.animation.set_animation("MagliDodge")
	hub.animation.set_animation_speed(1)
	current_dodge_speed = dodge_initial_speed
	did_player_leave_ground = (was_jump_input_on_first_frame or !hub.char_body.is_on_floor() or hub.state_machine.previous_state.name == "Jumping" or hub.state_machine.previous_state.name == "Falling")
	dodge_direction = Vector2(hub.movement.get_facing_value(), 1 if did_player_leave_ground else 0)
	hub.char_body.velocity = (dodge_direction * current_dodge_speed)
	hub.sprite_trail.activate_trail()
	if (was_jump_input_on_first_frame and hub.collisions.get_distance_to_ground() <= dodge_floor_snap_distance):
		hub.char_body.apply_floor_snap()

func attack_state_process(_delta : float):
	if (current_dodge_speed <= 0 or (did_player_leave_ground and hub.char_body.is_on_floor())):
		if (hub.jumping.can_ground_jump()):
			hub.jumping.start_ground_jump()
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))
		elif (hub.char_body.is_on_floor() and hub.char_body.velocity.x != 0):
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Running"))
		elif (hub.char_body.velocity.y < 0 and !hub.char_body.is_on_floor()):
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))
		elif (hub.char_body.velocity.y >= 0 and !hub.char_body.is_on_floor()):
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Falling"))
		else:
			hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))
	else:
		if (hub.collisions.is_facing_a_wall()):
			hub.char_body.velocity = Vector2(0, dodge_direction.y * current_dodge_speed if dodge_direction.y > 0 else 0.0)
		elif (dodge_direction.y == 0):
			var new_velocity : Vector2 = (Vector2.RIGHT * (current_dodge_speed if !hub.collisions.is_facing_a_wall() else 0.0))
			hub.char_body.velocity = (new_velocity * hub.movement.get_facing_value())
		else:
			hub.char_body.velocity = (dodge_direction * current_dodge_speed)
		
		if (!did_player_leave_ground and !hub.char_body.is_on_floor()):
			did_player_leave_ground = true
		
		hub.char_body.move_and_slide()
		current_dodge_speed = move_toward(current_dodge_speed, 0, dodge_deceleration * _delta)

func on_attack_state_exit():
	hub.sprite_trail.deactivate_trail()
	if (current_dodge_speed <= 0 or hub.collisions.is_facing_a_wall()):
		hub.char_body.velocity.x = 0
	elif (current_dodge_speed > 0 and hub.char_body.get_floor_angle() > slope_threshold):
		var new_velocity : Vector2 = (Vector2.RIGHT * (current_dodge_speed if !hub.collisions.is_facing_a_wall() else 0.0))
		hub.char_body.velocity = (new_velocity * hub.movement.get_facing_value())
	else:
		pass
	
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	
	hub.attacks.set_attack_cooldown_timer()
	hub.form.start_form_change_cooldown_timer()
	
	current_attack_state = AttackState.NOTHING
	was_jump_input_on_first_frame = false
	current_dodge_speed = 0
	did_player_leave_ground = false
	dodge_direction = Vector2.ZERO
