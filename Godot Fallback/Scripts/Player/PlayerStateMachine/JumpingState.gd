extends State

class_name JumpingState

var prev_is_crouching : bool = false

func state_process(_delta : float):
	prev_is_crouching = hub.movement.is_crouching
	hub.movement.check_crouch_state()
	hub.collisions.do_ceiling_nudge()
	hub.movement.do_movement(_delta)
	if (!hub.jumping.is_wall_jump_lock_timer_active()):
		hub.movement.update_facing_direction()
	else:
		hub.jumping.update_wall_jump_lock_timer(_delta)
	hub.jumping.ground_jump_update(_delta)
	
	if (hub.jumping.enable_crouch_jumping):
		if (prev_is_crouching and !hub.movement.is_crouching):
			hub.animation.set_animation("{name}Jump".format({"name" : hub.form.get_current_form_name()}))
			hub.animation.set_animation_speed(0)
		elif (!prev_is_crouching and hub.movement.is_crouching):
			hub.animation.set_animation("MagliCrouchJump")
			hub.animation.set_animation_speed(0)
		else:
			pass
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_wall_climb()):
		set_next_state(state_machine.get_state_by_name("WallClimbing"))
	elif (hub.jumping.can_wall_slide()):
		set_next_state(state_machine.get_state_by_name("WallSliding"))
	elif (hub.jumping.can_glide()):
		set_next_state(state_machine.get_state_by_name("Gliding"))
	elif (hub.jumping.can_midair_jump()):
		hub.jumping.do_midair_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.is_fast_falling || hub.char_body.velocity.y >= 0):
		set_next_state(state_machine.get_state_by_name("Falling"))
	else:
		pass

func on_enter():
	hub.jumping.switch_to_rising_gravity()
	if (state_machine.previous_state.name == "FormChanging"):
		var char_name : String = hub.form.get_current_form_name()
		hub.animation.set_animation("{name}Jump".format({"name" : char_name}) if !hub.movement.is_crouching else "MagliCrouchJump")

func on_exit():
	hub.jumping.reset_wall_jump_lock_timer()