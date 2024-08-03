extends State

class_name FallingState

var prev_is_crouching : bool = false

var is_throwing : bool = false

func state_process(_delta : float):
	var char_name : String = hub.form.get_current_form_name()
	prev_is_crouching = hub.movement.is_crouching
	if (!hub.force_stand):
		hub.movement.check_crouch_state()
		hub.movement.do_movement(_delta)
		hub.movement.update_facing_direction()
	else:
		hub.movement.do_movement(_delta)
	hub.jumping.falling_update(_delta)
	
	if (!hub.char_sprite.is_playing() and hub.char_sprite.animation == "MagliThrowAir"):
		is_throwing = false
		hub.animation.set_animation("{name}Fall".format({"name" : char_name}))
		hub.animation.set_animation_speed(1)
	
	if (hub.jumping.enable_crouch_jumping and !hub.jumping.is_fast_falling):
		if (prev_is_crouching and !hub.movement.is_crouching):
			hub.animation.set_animation("{name}Fall".format({"name" : char_name}))
			hub.animation.set_animation_speed(1)
		elif (!prev_is_crouching and hub.movement.is_crouching):
			hub.animation.set_animation("{name}CrouchFall".format({"name" : char_name}))
			hub.animation.set_animation_speed(1)
		else:
			pass
	elif (hub.jumping.enable_fast_falling and hub.jumping.is_fast_falling):
		hub.animation.set_animation("DraelynFastFall")
		hub.animation.set_animation_speed(1)
		hub.sprite_trail.activate_trail()
	else:
		pass
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	hub.jumping.update_wall_jump_lock_timer(_delta)
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.force_stand):
		if (hub.char_body.is_on_floor()):
			set_next_state(state_machine.get_state_by_name("Standing"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.fairy.is_using_fairy_ability() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.char_body.is_on_floor()):
		if (hub.jumping.can_fast_fall_slope_boost()):
			var selected_attack : Attack = (null if !hub.jumping.can_fast_fall_slope_boost() else hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name))
			if (selected_attack != null and selected_attack.can_use_attack() and Input.is_action_pressed("Crouch")):
				hub.attacks.current_attack = selected_attack
				set_next_state(state_machine.get_state_by_name("Attacking"))
			else:
				set_next_state(state_machine.get_state_by_name("Running"))
		else:
			set_next_state(state_machine.get_state_by_name("Standing"))
	elif (hub.stomp.is_stomping_enemy()):
		hub.stomp.do_stomp_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
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
	elif (hub.damage.is_player_defeated):
		set_next_state(state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_enter():
	is_throwing = hub.char_sprite.animation.contains("MagliThrow")
	hub.jumping.switch_to_falling_gravity()
	if (hub.jumping.is_fast_falling):
		hub.animation.set_animation("DraelynFastFall")
		hub.sprite_trail.activate_trail()
	else:
		hub.animation.set_animation("MagliThrowAir" if is_throwing else "{name}Fall".format({"name" : hub.form.get_current_form_name()}) if !hub.movement.is_crouching or !hub.jumping.enable_crouch_jumping else "{name}CrouchFall".format({"name" : hub.form.get_current_form_name()}))
		hub.animation.set_animation_frame(1 if is_throwing else 0)
	hub.animation.set_animation_speed(1)

func on_exit():
	if (hub.jumping.is_fast_falling and hub.char_body.is_on_floor()):
		if (hub.jumping.can_fast_fall_slope_boost()):
			hub.jumping.do_fast_fall_slope_boost()
		else:
			hub.jumping.charge_super_jump_with_fast_fall()
	elif (hub.jumping.can_speed_hop_slope_boost()):
		hub.jumping.do_speed_hop_slope_boost()
	else:
		pass
	
	if (hub.char_body.is_on_floor()):
		hub.stomp.reset_stomp_combo()
		
		var effect_instance : AnimatedSprite2D = EffectFactory.get_effect("LandingDust", hub.collisions.get_ground_point())
		effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.char_body.get_floor_normal())
		
		var walk_sound : String = ("jump_magli_landing" if hub.form.is_a_mage() else "jump_draelyn_landing")
		SoundFactory.play_sound_by_name(walk_sound, hub.char_body.global_position, 0, 1, "SFX")
	
	if (hub.jumping.is_fast_falling):
		hub.sprite_trail.deactivate_trail()
	hub.jumping.reset_fast_fall()

func _on_magic_blast_magic_blast_thrown():
	if (state_machine.current_state == self):
		is_throwing = true
		hub.animation.set_animation("MagliThrowAir")
		hub.animation.set_animation_speed(1)
