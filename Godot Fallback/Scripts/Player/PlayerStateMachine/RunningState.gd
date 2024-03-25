extends State

class_name RunningState

@export var dust_frames : Array

var did_turn_spark_appear : bool = false

var is_throwing : bool = false

func state_process(_delta):
	if (!hub.char_sprite.is_playing() and hub.char_sprite.animation == "MagliThrowGround"):
		is_throwing = false
	
	var did_a_wavedash : bool = (hub.form.is_a_mage() and hub.state_machine.previous_state.name == "Attacking" and hub.attacks.previous_attack.name == "Dodge" and abs(hub.movement.current_horizontal_velocity) > hub.movement.top_speed)
	var char_name : String = hub.form.get_current_form_name()
	var anim_name : String = ("MagliThrowGround" if is_throwing and !hub.movement.is_crouching else "{name}Move" if !hub.movement.is_crouching else "MagliDodge" if did_a_wavedash else "{name}CrouchWalk")
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.animation.set_animation(anim_name.format({"name" : char_name}))
	
	if (hub.movement.is_turning() and !hub.movement.is_crouching):
		if (is_throwing):
			is_throwing = false
			hub.animation.set_animation("{name}Move".format({"name" : char_name}))
		hub.animation.set_animation_frame(0)
		if (!did_turn_spark_appear):
			var spark_instance = EffectFactory.get_effect("TurnaroundSpark", hub.collisions.get_ground_point(), 1, hub.movement.get_facing_value() < 0)
			spark_instance.rotation = hub.char_body.up_direction.angle_to(hub.char_body.get_floor_normal())
			
			var sound_name : String = ("movement_magli_turnaround" if hub.form.is_a_mage() else "movement_draelyn_turnaround")
			did_turn_spark_appear = true
			SoundFactory.play_sound_by_name(sound_name, hub.char_body.global_position, 0, 1, "SFX")
	else:
		hub.animation.set_animation_speed(hub.movement.get_speed_portion())
		did_turn_spark_appear = false
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (((hub.collisions.is_moving_against_a_wall()) and (hub.get_input_vector().x * hub.movement.get_facing_value() > 0)) or (hub.get_input_vector().x == 0 and hub.char_body.velocity.x == 0)):
		set_next_state(state_machine.get_state_by_name("Standing"))
	elif (!hub.char_body.is_on_floor() and hub.char_body.velocity.y >= 0):
		set_next_state((state_machine.get_state_by_name("Falling")))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_enter():
	is_throwing = hub.char_sprite.animation.contains("MagliThrow")
	did_turn_spark_appear = false
	var prev_state_name : String = state_machine.previous_state.name
	var char_name : String = hub.form.get_current_form_name()
	var anim_name : String = ("{name}Move" if !hub.movement.is_crouching else "{name}CrouchWalk")
	if (hub.char_body.is_on_floor() or prev_state_name == "Falling" or prev_state_name == "Jumping"):
		hub.jumping.landing_reset()
	hub.animation.set_animation("MagliThrowGround" if is_throwing else anim_name.format({"name" : char_name}))
	hub.animation.set_animation_frame(1 if is_throwing else 0)

func on_exit():
	pass

func dust_check():
	did_turn_spark_appear = false
	if (hub.char_sprite.animation.contains("Move") and state_machine.current_state.name == "Running" and !hub.movement.is_crouching):
		for i in dust_frames:
			if (i == hub.char_sprite.frame):
				var effect_instance = EffectFactory.get_effect("WalkingDust", hub.collisions.get_ground_point(), 1, hub.movement.get_facing_value() < 0)
				effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.char_body.get_floor_normal())
				
				var walk_sound : String = ("jump_magli_landing" if hub.form.is_a_mage() else "jump_draelyn_landing")
				SoundFactory.play_sound_by_name(walk_sound, hub.char_body.global_position, 0, 1, "SFX")
				return

func _on_animated_sprite_2d_frame_changed():
	dust_check()

func _on_magic_blast_magic_blast_thrown():
	if (state_machine.current_state == self):
		is_throwing = true
		hub.animation.set_animation("MagliThrowGround")
		hub.animation.set_animation_speed(1)
