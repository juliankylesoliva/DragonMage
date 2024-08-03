extends State

class_name WallSlidingState

var effect_instance : AnimatedSprite2D

var is_throwing : bool = false

func state_process(_delta):
	hub.jumping.wall_slide_update(_delta)
	
	if (effect_instance != null):
		effect_instance.global_position = (hub.raycast_dm.global_position)
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	if (!hub.char_sprite.is_playing() and hub.char_sprite.animation == "MagliThrowWall"):
		is_throwing = false
		hub.animation.set_animation("MagliWallSlide" if hub.jumping.current_wall_jumps < hub.jumping.max_wall_jumps else "MagliWallSlideTired")
	
	hub.jumping.update_wall_release_timer(_delta)
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.fairy.is_using_fairy_ability() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.stomp.is_stomping_enemy()):
		hub.stomp.do_stomp_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.can_wall_jump()):
		hub.jumping.start_wall_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.is_wall_slide_canceled()):
		if (hub.char_body.is_on_floor() or hub.char_body.velocity.y == 0):
			hub.movement.set_facing_direction(-hub.movement.get_facing_value())
			set_next_state(state_machine.get_state_by_name("Standing"))
		else:
			hub.buffers.reset_speed_preservation_buffer()
			
			if (hub.jumping.enable_crouch_jumping and Input.is_action_pressed("Crouch")):
				hub.movement.check_crouch_state()
			
			set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.damage.is_player_defeated):
		set_next_state(state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_enter():
	if (state_machine.previous_state.name != "WallClimbing"):
		hub.jumping.reset_wall_release_timer()
	is_throwing = hub.char_sprite.animation.contains("MagliThrow")
	
	if (effect_instance != null):
		effect_instance.queue_free()
	
	hub.jumping.start_wall_slide()
	hub.animation.set_animation("MagliThrowWall" if is_throwing else "MagliWallSlide" if hub.jumping.current_wall_jumps < hub.jumping.max_wall_jumps else "MagliWallSlideTired")
	hub.animation.set_animation_frame(1 if is_throwing else 0)
	effect_instance = EffectFactory.get_effect("WallSlideDust", hub.raycast_dm.global_position, 1, hub.movement.get_facing_value() < 0)

func on_exit():
	if (effect_instance != null):
		effect_instance.queue_free()

func _on_magic_blast_magic_blast_thrown():
	if (state_machine.current_state == self):
		is_throwing = true
		hub.animation.set_animation("MagliThrowWall")
		hub.animation.set_animation_speed(1)
