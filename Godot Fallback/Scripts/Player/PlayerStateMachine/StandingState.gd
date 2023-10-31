extends State

class_name StandingState

func state_process(_delta):
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	
	if (hub.char_body.is_on_floor() and hub.get_input_vector().x != 0 and hub.char_body.velocity.x != 0):
		set_next_state(state_machine.get_state_by_name("Running"))

func on_enter():
	hub.animation.set_animation("MagliStand")
	hub.animation.set_animation_speed(0)
