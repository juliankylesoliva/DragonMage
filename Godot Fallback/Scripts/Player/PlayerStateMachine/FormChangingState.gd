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
				set_next_state(state_machine.get_state_by_name("WallClimbing" if hub.jumping.can_wall_climb_from_wall_slide() else "Falling"))
			"WallClimbing":
				set_next_state(state_machine.get_state_by_name("WallSliding" if hub.jumping.can_wall_slide_from_wall_climb() else "Falling"))
			"WallVaulting":
				set_next_state(state_machine.get_state_by_name("Jumping" if hub.char_body.velocity.y < 0 else "Falling"))
			"Damaged":
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
