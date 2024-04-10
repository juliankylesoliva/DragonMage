extends State

class_name WallVaultingState

func state_process(_delta):
	hub.jumping.wall_popup_update(_delta)
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.fairy.is_using_fairy_ability() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_wall_vault()):
		hub.jumping.start_wall_vault()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.is_wall_popup_canceled()):
		hub.jumping.cancel_wall_climb()
		
		if (hub.char_body.is_on_ceiling()):
			var effect_instance = EffectFactory.get_effect("HeadbonkFX", hub.collisions.get_ceiling_point())
			effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ceiling_normal())
			SoundFactory.play_sound_by_name("jump_draelyn_headbonk", hub.char_body.global_position, -2)
		
		set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.damage.is_player_defeated):
		set_next_state(state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_exit():
	hub.jumping.end_wall_popup()
