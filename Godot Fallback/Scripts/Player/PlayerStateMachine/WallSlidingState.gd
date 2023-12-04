extends State

class_name WallSlidingState

func state_process(_delta):
	hub.jumping.wall_slide_update()
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_wall_jump()):
		hub.jumping.start_wall_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.is_wall_slide_canceled()):
		if (hub.char_body.is_on_floor() or hub.char_body.velocity.y == 0):
			set_next_state(state_machine.get_state_by_name("Standing"))
		else:
			set_next_state(state_machine.get_state_by_name("Falling"))

func on_enter():
	hub.jumping.start_wall_slide()
	hub.animation.set_animation("MagliWallSlide")
