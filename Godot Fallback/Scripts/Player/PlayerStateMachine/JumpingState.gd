extends State

class_name JumpingState

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.jumping.ground_jump_update(_delta)
	
	if (hub.char_body.velocity.y >= 0):
		state_machine.switch_states(state_machine.get_state_by_name("Falling"))

func on_enter():
	hub.jumping.switch_to_rising_gravity()
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(0)
