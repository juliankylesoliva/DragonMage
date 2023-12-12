extends State

class_name WallSlidingState

var effect_instance : AnimatedSprite2D

func state_process(_delta):
	hub.jumping.wall_slide_update()
	
	if (effect_instance != null):
		effect_instance.global_position = (hub.raycast_dm.global_position)
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_wall_jump()):
		hub.jumping.start_wall_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.is_wall_slide_canceled()):
		if (hub.char_body.is_on_floor() or hub.char_body.velocity.y == 0):
			set_next_state(state_machine.get_state_by_name("Standing"))
		else:
			hub.buffers.reset_speed_preservation_buffer()
			set_next_state(state_machine.get_state_by_name("Falling"))

func on_enter():
	if (effect_instance != null):
		effect_instance.queue_free()
	
	hub.jumping.start_wall_slide()
	hub.animation.set_animation("MagliWallSlide")
	effect_instance = EffectFactory.get_effect("WallSlideDust", hub.raycast_dm.global_position, 1, hub.movement.get_facing_value() < 0)

func on_exit():
	if (effect_instance != null):
		effect_instance.queue_free()
