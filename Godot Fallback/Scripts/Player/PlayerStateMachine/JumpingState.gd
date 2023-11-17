extends State

class_name JumpingState

var prev_is_crouching : bool = false

func state_process(_delta : float):
	prev_is_crouching = hub.movement.is_crouching
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	if (!hub.jumping.is_wall_jump_lock_timer_active()):
		hub.movement.update_facing_direction()
	else:
		hub.jumping.update_wall_jump_lock_timer(_delta)
	hub.jumping.ground_jump_update(_delta)
	
	if (hub.jumping.enable_crouch_jumping):
		if (prev_is_crouching and !hub.movement.is_crouching):
			hub.animation.set_animation("{name}Jump".format({"name" : hub.form.get_current_form_name()}))
			hub.animation.set_animation_frame(0)
			hub.animation.set_animation_speed(0)
		elif (!prev_is_crouching and hub.movement.is_crouching):
			hub.animation.set_animation("MagliCrouchJump")
			hub.animation.set_animation_frame(0)
			hub.animation.set_animation_speed(0)
		else:
			pass
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.jumping.can_wall_slide()):
		state_machine.switch_states(state_machine.get_state_by_name("WallSliding"))
	elif (hub.jumping.can_glide()):
		state_machine.switch_states(state_machine.get_state_by_name("Gliding"))
	elif (hub.char_body.velocity.y >= 0):
		state_machine.switch_states(state_machine.get_state_by_name("Falling"))
	else:
		pass

func on_enter():
	hub.jumping.switch_to_rising_gravity()
	if (state_machine.previous_state.name == "FormChanging"):
		var char_name : String = hub.form.get_current_form_name()
		hub.animation.set_animation("{name}Jump".format({"name" : char_name}) if !hub.movement.is_crouching else "MagliCrouchJump")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(0)

func on_exit():
	hub.jumping.reset_wall_jump_lock_timer()
