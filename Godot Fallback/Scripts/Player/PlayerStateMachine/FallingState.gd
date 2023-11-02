extends State

class_name FallingState

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.jumping.falling_update(_delta)
	
	if (hub.char_body.is_on_floor()):
		if (hub.char_body.velocity.x != 0):
			state_machine.switch_states(state_machine.get_state_by_name("Running"))
		else:
			state_machine.switch_states(state_machine.get_state_by_name("Standing"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	else:
		pass

func on_enter():
	hub.jumping.switch_to_falling_gravity()
	hub.animation.set_animation("MagliJump")
	hub.animation.set_animation_frame(1)
	hub.animation.set_animation_speed(1)
