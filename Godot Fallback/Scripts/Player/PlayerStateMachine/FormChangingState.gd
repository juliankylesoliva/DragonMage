extends State

class_name FormChangingState

var prev_velocity : Vector2 = Vector2.ZERO

func state_process(_delta):
	if (!hub.form.is_changing_form()):
		var prev_state : String = state_machine.previous_state.name
		match prev_state:
			"Gliding":
				set_next_state(state_machine.get_state_by_name("Falling"))
			"WallSliding":
				hub.buffers.refresh_speed_preservation_buffer()
				set_next_state(state_machine.get_state_by_name("WallClimbing" if hub.jumping.can_wall_climb_from_wall_slide() else "Jumping" if prev_velocity.y < 0 else "Falling"))
			"WallClimbing":
				if (hub.jumping.stored_wall_climb_speed > hub.buffers.highest_speed):
					hub.buffers.highest_speed = hub.jumping.stored_wall_climb_speed
					hub.buffers.refresh_speed_preservation_buffer()
				set_next_state(state_machine.get_state_by_name("WallSliding" if hub.jumping.can_wall_slide_from_wall_climb() else "Falling"))
			"WallVaulting":
				if (hub.jumping.stored_wall_climb_speed > hub.buffers.highest_speed):
					hub.buffers.highest_speed = hub.jumping.stored_wall_climb_speed
					hub.buffers.refresh_speed_preservation_buffer()
				set_next_state(state_machine.get_state_by_name("Jumping" if prev_velocity.y < 0 else "Falling"))
			"Damaged":
				if (hub.char_body.is_on_floor()):
					set_next_state(state_machine.get_state_by_name("Standing"))
				else:
					set_next_state(state_machine.get_state_by_name("Falling"))
			"Attacking":
				if (hub.char_body.is_on_floor() and (hub.get_input_vector().x != 0 or prev_velocity.x != 0)):
					set_next_state(state_machine.get_state_by_name("Running"))
				elif (prev_velocity.y < 0 and !hub.char_body.is_on_floor()):
					set_next_state(state_machine.get_state_by_name("Jumping"))
				elif (prev_velocity.y >= 0 and !hub.char_body.is_on_floor()):
					set_next_state(state_machine.get_state_by_name("Falling"))
				else:
					set_next_state(state_machine.get_state_by_name("Standing"))
			_:
				set_next_state(state_machine.get_state_by_name(prev_state))
	else:
		hub.char_body.velocity = Vector2.ZERO

func on_enter():
	hub.form.do_form_change()
	
	prev_velocity = hub.char_body.velocity
	hub.jumping.switch_to_zero_gravity()
	hub.char_body.velocity = Vector2.ZERO
	hub.form.start_form_change_timer()

func on_exit():
	if (prev_velocity.y < 0):
		hub.jumping.switch_to_rising_gravity()
	else:
		hub.jumping.switch_to_falling_gravity()
	
	if (-prev_velocity.y > hub.jumping.initial_jump_velocity):
		prev_velocity.y = -hub.jumping.initial_jump_velocity
	
	hub.char_body.velocity = prev_velocity
	hub.form.start_form_change_cooldown_timer()
