extends State

class_name StandingState

func state_process(_delta):
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	
	if (hub.char_body.is_on_floor() and (!hub.collisions.is_facing_a_wall() or (hub.get_input_vector().x * hub.movement.get_facing_value()) < 0) and hub.get_input_vector().x != 0):
		set_next_state(state_machine.get_state_by_name("Running"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (!hub.char_body.is_on_floor()):
		set_next_state((state_machine.get_state_by_name("Falling")))
	else:
		pass

func on_enter():
	hub.animation.set_animation("MagliStand")
	hub.animation.set_animation_speed(0)
