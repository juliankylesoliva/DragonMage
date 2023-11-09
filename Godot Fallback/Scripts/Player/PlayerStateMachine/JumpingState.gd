extends State

class_name JumpingState

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	if (!hub.jumping.is_wall_jump_lock_timer_active()):
		hub.movement.update_facing_direction()
	else:
		hub.jumping.update_wall_jump_lock_timer(_delta)
	hub.jumping.ground_jump_update(_delta)
	
	if (hub.jumping.can_wall_slide()):
		state_machine.switch_states(state_machine.get_state_by_name("WallSliding"))
	elif (hub.char_body.velocity.y >= 0):
		state_machine.switch_states(state_machine.get_state_by_name("Falling"))
	else:
		pass

func on_enter():
	hub.jumping.switch_to_rising_gravity()
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(0)

func on_exit():
	hub.jumping.reset_wall_jump_lock_timer()
