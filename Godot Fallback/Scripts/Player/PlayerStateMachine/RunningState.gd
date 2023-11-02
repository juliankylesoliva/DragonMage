extends State

class_name RunningState

func state_process(_delta):
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	
	if (hub.movement.is_turning()):
		hub.animation.set_animation_frame(0)
	else:
		hub.animation.set_animation_speed(hub.movement.get_speed_portion())
	
	if ((hub.get_input_vector().x == 0 and hub.char_body.velocity.x == 0) or hub.movement.is_running_into_a_wall()):
		set_next_state(state_machine.get_state_by_name("Standing"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (!hub.char_body.is_on_floor()):
		set_next_state((state_machine.get_state_by_name("Falling")))
	else:
		pass

func on_enter():
	hub.animation.set_animation("MagliRun")
