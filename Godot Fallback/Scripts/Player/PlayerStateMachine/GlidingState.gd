extends State

class_name GlidingState

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.jumping.glide_update(_delta)
	if (hub.jumping.can_wall_slide()):
		state_machine.switch_states(state_machine.get_state_by_name("WallSliding"))
	elif (Input.get_action_strength("Jump") == 0 or hub.char_body.is_on_floor() or hub.jumping.current_glide_time  >= hub.jumping.max_glide_time):
		state_machine.switch_states(state_machine.get_state_by_name("Falling"))

func on_enter():
	hub.jumping.start_glide()
	hub.animation.set_animation("MagliGlide")

func on_exit():
	hub.jumping.cancel_glide()
