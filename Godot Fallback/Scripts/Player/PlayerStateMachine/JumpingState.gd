extends State

class_name JumpingState

var prev_is_crouching : bool = false

var has_headbonked : bool = false

var is_throwing : bool = false

func state_process(_delta : float):
	prev_is_crouching = hub.movement.is_crouching
	hub.collisions.do_ceiling_nudge()
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	if (!hub.jumping.is_wall_jump_lock_timer_active()):
		hub.movement.update_facing_direction()
	else:
		hub.jumping.update_wall_jump_lock_timer(_delta)
	hub.jumping.ground_jump_update(_delta)
	
	if (hub.jumping.magic_blast_attack.is_blast_jumping and !hub.movement.is_crouching):
		hub.animation.set_animation("MagliBoostJump")
	
	if (!hub.char_sprite.is_playing() and hub.char_sprite.animation == "MagliThrowAir"):
		is_throwing = false
		hub.animation.set_animation("MagliBoostJump" if hub.jumping.magic_blast_attack.is_blast_jumping and !hub.movement.is_crouching else "{name}Jump".format({"name" : hub.form.get_current_form_name()}))
		hub.animation.set_animation_speed(0)
	
	if (hub.jumping.enable_crouch_jumping):
		if (prev_is_crouching and !hub.movement.is_crouching):
			hub.animation.set_animation("MagliBoostJump" if hub.jumping.magic_blast_attack.is_blast_jumping and !hub.movement.is_crouching else "{name}Jump".format({"name" : hub.form.get_current_form_name()}))
			hub.animation.set_animation_speed(0)
		elif (!prev_is_crouching and hub.movement.is_crouching):
			is_throwing = false
			hub.animation.set_animation("{name}CrouchJump".format({"name" : hub.form.get_current_form_name()}))
			hub.animation.set_animation_speed(0)
		else:
			pass
	
	if (hub.char_body.is_on_ceiling() and !has_headbonked):
		has_headbonked = true
		
		var effect_instance = EffectFactory.get_effect("HeadbonkFX", hub.collisions.get_ceiling_point())
		effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ceiling_normal())
		
		var sound_name : String = ("jump_magli_headbonk" if hub.form.is_a_mage() else "jump_draelyn_headbonk")
		SoundFactory.play_sound_by_name(sound_name, hub.char_body.global_position, -2)
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	hub.jumping.update_wall_jump_lock_timer(_delta)
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.force_stand):
		hub.char_body.velocity.y = 0
		set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.fairy.is_using_fairy_ability() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.stomp.is_stomping_enemy()):
		hub.stomp.do_stomp_jump()
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
	elif (hub.jumping.is_fast_falling || hub.char_body.velocity.y >= 0):
		set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.damage.is_player_defeated):
		set_next_state(state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_enter():
	is_throwing = hub.char_sprite.animation.contains("MagliThrow")
	has_headbonked = false
	hub.jumping.switch_to_rising_gravity()
	hub.jumping.reset_fast_fall()
	if (state_machine.previous_state.name == "FormChanging"):
		var char_name : String = hub.form.get_current_form_name()
		hub.animation.set_animation("MagliBoostJump" if hub.jumping.magic_blast_attack.is_blast_jumping and !hub.movement.is_crouching else "{name}Jump".format({"name" : char_name}) if !hub.movement.is_crouching else "{name}CrouchJump".format({"name" : char_name}))
	elif (is_throwing):
		hub.animation.set_animation("MagliThrowAir")
		hub.animation.set_animation_frame(1)
	else:
		pass

func on_exit():
	has_headbonked = false
	if (hub.jumping.midair_jump_particles.emitting):
		hub.jumping.midair_jump_particles.emitting = false
	hub.jumping.reset_wall_jump_lock_timer()


func _on_magic_blast_magic_blast_thrown():
	if (state_machine.current_state == self):
		is_throwing = true
		hub.animation.set_animation("MagliThrowAir")
		hub.animation.set_animation_speed(1)
