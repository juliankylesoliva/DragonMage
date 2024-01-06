extends State

class_name DamagedState

func state_process(_delta):
	hub.damage.update_knockback(_delta)
	hub.damage.update_hitstun_timer(_delta)
	hub.camera.damaged_horizontal_camera_update(_delta)
	
	if (!hub.damage.is_player_damaged()):
		if (hub.temper.is_forcing_form_change()):
			set_next_state(state_machine.get_state_by_name("FormChanging"))
		elif (hub.char_body.is_on_floor()):
			set_next_state(state_machine.get_state_by_name("Standing"))
		else:
			set_next_state(state_machine.get_state_by_name("Falling"))

func on_enter():
	hub.jumping.landing_reset()
	if (hub.movement.is_crouching and !hub.collisions.is_in_ceiling_when_uncrouched()):
		hub.movement.reset_crouch_state()
	if (!hub.temper.is_form_locked()):
		hub.temper.change_temper_by(hub.damage.mage_temper_damage if hub.form.current_mode == PlayerForm.CharacterMode.MAGE else hub.damage.dragon_temper_damage)
	hub.buffers.reset_speed_preservation_buffer()
	hub.jumping.reset_super_jump_timers()
	hub.audio.play_sound("damage_player")
	hub.jumping.switch_to_falling_gravity()
	hub.damage.do_knockback()
	hub.animation.set_animation("{name}Damage".format({"name" : hub.form.get_current_form_name()}))
	hub.animation.set_animation_speed(1)

func on_exit():
	if (!hub.char_body.is_on_floor()):
		hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	hub.damage.do_iframes()
