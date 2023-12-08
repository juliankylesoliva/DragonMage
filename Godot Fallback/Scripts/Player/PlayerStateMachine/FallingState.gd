extends State

class_name FallingState

var prev_is_crouching : bool = false

func state_process(_delta : float):
	var char_name : String = hub.form.get_current_form_name()
	prev_is_crouching = hub.movement.is_crouching
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.jumping.falling_update(_delta)
	
	if (hub.jumping.enable_crouch_jumping):
		if (prev_is_crouching and !hub.movement.is_crouching):
			hub.animation.set_animation("{name}Fall".format({"name" : char_name}))
			hub.animation.set_animation_speed(1)
		elif (!prev_is_crouching and hub.movement.is_crouching):
			hub.animation.set_animation("{name}CrouchFall".format({"name" : char_name}))
			hub.animation.set_animation_speed(1)
		else:
			pass
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.char_body.is_on_floor()):
		if (hub.char_body.velocity.x != 0 || hub.jumping.can_fast_fall_slope_boost()):
			var selected_attack : Attack = (null if !hub.jumping.can_fast_fall_slope_boost() else hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name))
			if (selected_attack != null and selected_attack.can_use_attack() and Input.is_action_pressed("Crouch")):
				hub.attacks.current_attack = selected_attack
				set_next_state(state_machine.get_state_by_name("Attacking"))
			else:
				set_next_state(state_machine.get_state_by_name("Running"))
		else:
			set_next_state(state_machine.get_state_by_name("Standing"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.can_wall_climb()):
		set_next_state(state_machine.get_state_by_name("WallClimbing"))
	elif (hub.jumping.can_wall_slide()):
		set_next_state(state_machine.get_state_by_name("WallSliding"))
	elif (hub.jumping.can_glide()):
		set_next_state(state_machine.get_state_by_name("Gliding"))
	elif (hub.jumping.can_midair_jump()):
		hub.jumping.do_midair_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	else:
		pass

func on_enter():
	hub.jumping.switch_to_falling_gravity()
	hub.animation.set_animation("{name}Fall".format({"name" : hub.form.get_current_form_name()}) if !hub.movement.is_crouching or !hub.jumping.enable_crouch_jumping else "MagliCrouchFall")
	hub.animation.set_animation_speed(1)

func on_exit():
	if (hub.jumping.is_fast_falling and hub.char_body.is_on_floor()):
		if (hub.jumping.can_fast_fall_slope_boost()):
			hub.jumping.do_fast_fall_slope_boost()
		else:
			hub.jumping.charge_super_jump_with_fast_fall()
	elif (hub.jumping.can_speed_hop_slope_boost()):
		hub.jumping.do_speed_hop_slope_boost()
	elif (hub.char_body.is_on_floor()):
		var walk_sound : String = ("jump_magli_landing" if hub.form.current_mode == PlayerForm.CharacterMode.MAGE else "jump_draelyn_landing")
		SoundFactory.play_sound_by_name(walk_sound, hub.char_body.global_position, 0, 1, "SFX")
	else:
		pass
	hub.jumping.reset_fast_fall()
