extends State

class_name GlidingState

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	#hub.movement.update_facing_direction()
	hub.jumping.glide_update(_delta)
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_wall_slide()):
		set_next_state(state_machine.get_state_by_name("WallSliding"))
	elif (!Input.is_action_pressed("Jump") or hub.char_body.is_on_floor() or hub.jumping.current_glide_time  >= hub.jumping.max_glide_time):
		set_next_state(state_machine.get_state_by_name("Falling"))

func on_enter():
	hub.jumping.start_glide()
	hub.animation.set_animation("MagliGlide")

func on_exit():
	hub.jumping.cancel_glide()