extends State

class_name RunningState

func state_process(_delta):
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.animation.set_animation("MagliRun" if !hub.movement.is_crouching else "MagliCrouchWalk")
	
	if (hub.movement.is_turning()):
		hub.animation.set_animation_frame(0)
	else:
		hub.animation.set_animation_speed(hub.movement.get_speed_portion())
	
	if (((hub.collisions.is_moving_against_a_wall()) and (hub.get_input_vector().x * hub.movement.get_facing_value() > 0)) or (hub.get_input_vector().x == 0 and hub.char_body.velocity.x == 0)):
		set_next_state(state_machine.get_state_by_name("Standing"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (!hub.char_body.is_on_floor()):
		set_next_state((state_machine.get_state_by_name("Falling")))
	else:
		pass

func on_enter():
	var prev_state_name : String = state_machine.previous_state.name
	if (prev_state_name == "Falling" or prev_state_name == "Jumping"):
		hub.jumping.landing_reset()
	hub.animation.set_animation("MagliRun" if !hub.movement.is_crouching else "MagliCrouchWalk")
