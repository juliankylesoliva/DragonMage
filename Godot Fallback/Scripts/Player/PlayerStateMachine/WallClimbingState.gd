extends State

class_name WallClimbingState

@export var sprite_x_offset : float = 6

func state_process(_delta):
	hub.animation.set_animation_speed(hub.jumping.get_climbing_animation_speed())
	hub.jumping.wall_climb_update(_delta)
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_start_wall_popup() and Input.is_action_pressed("Technical")):
		hub.jumping.do_ledge_snap()
		if (Input.is_action_pressed("Crouch")):
			var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name)
			if (selected_attack != null):
				hub.attacks.current_attack = selected_attack
				set_next_state(state_machine.get_state_by_name("Attacking"))
		else:
			set_next_state(state_machine.get_state_by_name("Running"))
	elif (hub.jumping.can_start_wall_popup()):
		hub.jumping.start_wall_popup()
		set_next_state(state_machine.get_state_by_name("WallVaulting"))
	elif (hub.jumping.is_wall_climb_canceled()):
		hub.jumping.cancel_wall_climb()
		
		if (hub.char_body.is_on_ceiling()):
			var effect_instance = EffectFactory.get_effect("HeadbonkFX", hub.collisions.get_ceiling_point())
			effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ceiling_normal())
			
			var sound_name : String = ("jump_magli_headbonk" if hub.form.current_mode == PlayerForm.CharacterMode.MAGE else "jump_draelyn_headbonk")
			SoundFactory.play_sound_by_name(sound_name, hub.char_body.global_position, -2)
		
		set_next_state(state_machine.get_state_by_name("Falling"))
	else:
		pass

func on_enter():
	if (hub.jumping.is_fast_falling):
		hub.jumping.reset_fast_fall()
	
	hub.jumping.start_wall_climb()
	hub.animation.set_animation("DraelynWallClimb")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(hub.jumping.get_climbing_animation_speed())
	hub.char_sprite.offset.x = (sprite_x_offset * -hub.movement.get_facing_value())

func on_exit():
	hub.jumping.end_wall_climb()
	hub.animation.set_animation_speed(1)
	hub.char_sprite.offset.x = 0
