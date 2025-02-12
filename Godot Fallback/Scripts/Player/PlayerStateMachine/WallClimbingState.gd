extends State

class_name WallClimbingState

@export var sprite_x_offset : float = 6

@export var effect_name_normal : String = "WallClimbSpark"

@export var effect_name_fast : String = "WallClimbSparkFast"

var spark_effect_instance : AnimatedSprite2D

func state_process(_delta):
	hub.animation.set_animation_speed(hub.jumping.get_climbing_animation_speed())
	hub.jumping.wall_climb_update(_delta)
	
	if (spark_effect_instance != null):
		spark_effect_instance.global_position = hub.raycast_dm.global_position
		if (spark_effect_instance.animation == effect_name_fast and -hub.char_body.velocity.y <= hub.jumping.min_climbing_speed):
			var frame_num = spark_effect_instance.frame
			var frame_progress = spark_effect_instance.frame_progress
			
			spark_effect_instance.animation = effect_name_normal
			spark_effect_instance.frame = frame_num
			spark_effect_instance.frame_progress = frame_progress
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	hub.camera.wall_climb_horizontal_camera_update(_delta, hub.jumping.stored_wall_climb_speed, hub.jumping.stored_wall_climb_speed > hub.jumping.min_climbing_speed)
	
	hub.jumping.update_wall_release_timer(_delta)
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.fairy.is_using_fairy_ability() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_start_wall_popup()):
		if ((hub.is_action_pressed("Jump") and !hub.is_action_pressed("Crouch")) or hub.get_input_vector().y > 0):
			hub.buffers.reset_jump_buffer()
			hub.jumping.start_wall_popup()
			set_next_state(state_machine.get_state_by_name("WallVaulting"))
		else:
			hub.jumping.do_ledge_snap()
			if ((hub.is_action_pressed("Crouch") and !hub.is_action_pressed("Jump")) or hub.get_input_vector().y < 0):
				var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name)
				if (selected_attack != null):
					hub.attacks.current_attack = selected_attack
					set_next_state(state_machine.get_state_by_name("Attacking"))
			else:
				set_next_state(state_machine.get_state_by_name("Running" if hub.char_body.is_on_floor() else "Falling"))
	elif (hub.jumping.is_wall_climb_canceled()):
		if ((hub.is_action_pressed("Jump") or hub.get_input_vector().y > 0) and (hub.jumping.current_wall_climb_time <= 0 or hub.char_body.velocity.y >= 0) and !hub.char_body.is_on_ceiling()):
			hub.buffers.reset_jump_buffer()
			hub.jumping.start_wall_popup()
			set_next_state(state_machine.get_state_by_name("WallVaulting"))
		else:
			hub.jumping.cancel_wall_climb()
			if (hub.char_body.is_on_ceiling()):
				var effect_instance = EffectFactory.get_effect("HeadbonkFX", hub.collisions.get_ceiling_point())
				effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ceiling_normal())
				SoundFactory.play_sound_by_name("jump_draelyn_headbonk", hub.char_body.global_position, -2)
			hub.buffers.reset_speed_preservation_buffer()
			
			if (hub.jumping.enable_crouch_jumping and hub.is_action_pressed("Crouch")):
				hub.movement.check_crouch_state()
			
			set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.damage.is_player_defeated):
		set_next_state(state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_enter():
	if (state_machine.previous_state.name != "WallSliding"):
		hub.jumping.reset_wall_release_timer()
	if (hub.jumping.is_fast_falling):
		hub.jumping.reset_fast_fall()
	
	if (spark_effect_instance != null):
		spark_effect_instance.queue_free()
	
	hub.jumping.start_wall_climb()
	hub.animation.set_animation("DraelynWallClimb")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(hub.jumping.get_climbing_animation_speed())
	hub.char_sprite.offset.x = (sprite_x_offset * -hub.movement.get_facing_value())
	
	var effect_name = (effect_name_fast if -hub.char_body.velocity.y > hub.jumping.min_climbing_speed else effect_name_normal)
	spark_effect_instance = EffectFactory.get_effect(effect_name, hub.raycast_dm.global_position, 1, hub.movement.get_facing_value() < 0)

func on_exit():
	if (spark_effect_instance != null):
		spark_effect_instance.queue_free()
	
	hub.jumping.end_wall_climb()
	hub.animation.set_animation_speed(1)
	hub.char_sprite.offset.x = 0
