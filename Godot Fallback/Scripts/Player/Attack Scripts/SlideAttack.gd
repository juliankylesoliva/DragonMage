extends Attack

class_name SlideAttack

@export var slide_min_horizontal_speed : float = 5

@export var slide_max_horizontal_speed : float = 10

@export var slide_deceleration_rate : float = 2.5

@export var slide_min_duration : float = 0.2

@export var slide_uncancelable_time : float = 0.25

@export var slide_effect_fast : String = "SlideDustFast"

@export var slide_effect_normal : String = "SlideDust"

@export var slide_effect_slow : String = "SlideDustSlow"

@export var slide_effect_slowdown_threshold : float = 0.5

@export var slide_hang_time : float = 0.2

var prev_horizontal_velocity : float = 0

var prev_is_grounded : bool = false

var horizontal_result : float = 0

var current_slide_timer : float = 0

var current_slide_hang_timer : float = 0

var slide_effect_instance : AnimatedSprite2D = null

func can_use_attack():
	var state_name : String = hub.state_machine.current_state.name
	return (hub.form.current_mode == PlayerForm.CharacterMode.DRAGON and state_name != "Attacking" and (hub.attacks.current_attack == null or hub.attacks.current_attack.name != self.name) and (!hub.attacks.is_attack_cooldown_active() or hub.jumping.can_fast_fall_slope_boost()) and (hub.movement.is_crouching or hub.jumping.can_fast_fall_slope_boost()) and (state_name == "Standing" or state_name == "Running" or (state_name == "Falling" and hub.jumping.can_fast_fall_slope_boost())) and hub.char_body.is_on_floor() and (!hub.collisions.is_facing_a_wall() or (hub.jumping.can_fast_fall_slope_boost() and !hub.collisions.is_near_a_ledge(hub.movement.get_facing_value() and hub.get_input_vector().x == 0))))

func on_attack_state_enter():
	if (slide_effect_instance != null):
		slide_effect_instance.queue_free()
	
	if (!hub.movement.is_crouching):
		hub.movement.is_crouching = true
		hub.movement.current_min_crouch_timer = hub.movement.min_crouch_time
	
	prev_is_grounded = hub.char_body.is_on_floor()
	
	current_attack_state = AttackState.ACTIVE
	SoundFactory.play_sound_by_name("movement_draelyn_slide", hub.char_body.global_position, 0, 1, "SFX")
	prev_horizontal_velocity = abs(hub.movement.current_horizontal_velocity)
	hub.animation.set_animation("DraelynSlide")
	horizontal_result = abs(min((prev_horizontal_velocity + slide_min_horizontal_speed) , slide_max_horizontal_speed))
	hub.char_body.velocity = (Vector2.RIGHT * horizontal_result * hub.movement.get_facing_value())
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	current_slide_timer = 0
	current_slide_hang_timer = slide_hang_time
	hub.sprite_trail.activate_trail()
	
	var slide_effect_name : String = (slide_effect_fast if horizontal_result > slide_min_horizontal_speed else slide_effect_normal if horizontal_result > (slide_min_horizontal_speed * slide_effect_slowdown_threshold) else slide_effect_slow)
	slide_effect_instance = EffectFactory.get_effect(slide_effect_name, hub.raycast_dm.global_position, 1, hub.movement.get_facing_value() < 0)
	slide_effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ground_normal())

func attack_state_process(_delta : float):
	if (hub.force_stand):
		hub.char_body.velocity = Vector2.ZERO
		hub.movement.reset_current_horizontal_velocity()
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))
	elif (hub.is_deactivated):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Deactivated"))
	elif (hub.damage.is_player_defeated or hub.damage.is_player_damaged() or hub.collisions.is_facing_a_wall() or (current_slide_hang_timer <= 0 and (hub.collisions.is_near_a_ledge() or hub.collisions.get_distance_to_ground() > hub.char_body.floor_snap_length))):
		stop_slide()
	elif (!hub.collisions.is_in_ceiling_when_uncrouched() and current_slide_timer > slide_uncancelable_time and (hub.get_input_vector().x * hub.char_body.velocity.x) > 0 and hub.buffers.is_jump_buffer_active()):
		do_jump_cancel()
	elif (!hub.collisions.is_in_ceiling_when_uncrouched() and current_slide_timer > slide_uncancelable_time and hub.buffers.is_attack_buffer_active()):
		do_attack_cancel()
	elif (horizontal_result <= 0 or (current_slide_timer > slide_min_duration and (((!hub.movement.enable_crouch_toggle and !Input.is_action_pressed("Crouch")) or (hub.movement.enable_crouch_toggle and Input.is_action_just_pressed("Crouch"))) or (hub.get_input_vector().x * hub.movement.get_facing_value()) < 0))):
		stop_slide()
	else:
		slide_update(_delta)
	
	if (slide_effect_instance != null):
		slide_effect_instance.global_position = hub.raycast_dm.global_position
		slide_effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ground_normal())
		if (slide_effect_instance.animation == slide_effect_fast and abs(hub.char_body.velocity.x) <= slide_min_horizontal_speed):
			var frame_num = slide_effect_instance.frame
			var frame_progress = slide_effect_instance.frame_progress
			
			slide_effect_instance.animation = slide_effect_normal
			slide_effect_instance.frame = frame_num
			slide_effect_instance.frame_progress = frame_progress
		elif (slide_effect_instance.animation == slide_effect_normal and abs(hub.char_body.velocity.x) <= (slide_min_horizontal_speed * slide_effect_slowdown_threshold)):
			var frame_num = slide_effect_instance.frame
			var frame_progress = slide_effect_instance.frame_progress
			
			slide_effect_instance.animation = slide_effect_slow
			slide_effect_instance.frame = frame_num
			slide_effect_instance.frame_progress = frame_progress
		else:
			pass
	hub.camera.update_x_lookahead(_delta)
	hub.camera.update_y_lookahead(_delta)

func on_attack_state_exit():
	if (slide_effect_instance != null):
		slide_effect_instance.queue_free()
	
	hub.sprite_trail.deactivate_trail()
	current_attack_state = AttackState.NOTHING
	prev_horizontal_velocity = 0
	horizontal_result = 0
	current_slide_timer = 0
	current_slide_hang_timer = 0

func do_jump_cancel():
	if (current_attack_state != AttackState.ACTIVE):
		return
	
	hub.char_body.velocity.x = (hub.get_input_vector().x * horizontal_result)
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	hub.jumping.start_ground_jump()
	hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))

func do_attack_cancel():
	if (current_attack_state != AttackState.ACTIVE):
		return
	var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.standing_attack_name)
	if (selected_attack != null):
		hub.buffers.reset_attack_buffer()
		hub.attacks.set_queued_attack(selected_attack)
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Attacking"))

func stop_slide():
	hub.char_body.velocity.x = (0 if (hub.damage.is_player_damaged() or hub.collisions.is_facing_a_wall() or (hub.collisions.is_near_a_ledge() and hub.get_input_vector().x == 0)) else (hub.movement.get_facing_value() * min(horizontal_result, hub.movement.top_speed)))
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	if (hub.damage.is_player_defeated):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Damaged"))
	elif (hub.char_body.is_on_floor() and (hub.get_input_vector().x != 0 or hub.char_body.velocity.x != 0)):
		if (hub.collisions.is_near_a_ledge() and hub.collisions.get_distance_to_ground() >= hub.char_body.floor_snap_length):
			preserve_slide_speed()
		else:
			cap_slide_speed()
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Running"))
	elif (hub.char_body.velocity.y >= 0 and !hub.char_body.is_on_floor()):
		preserve_slide_speed()
		if (!hub.collisions.is_in_ceiling_when_uncrouched()):
			hub.movement.reset_crouch_state()
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Falling"))
	else:
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))

func cap_slide_speed():
	if (hub.get_input_vector().x != 0):
		hub.char_body.velocity.x = (min(hub.movement.top_speed, abs(hub.char_body.velocity.x)) * hub.movement.get_facing_value())
		hub.movement.current_horizontal_velocity = hub.char_body.velocity.x

func preserve_slide_speed():
	if (hub.get_input_vector().x != 0):
		hub.char_body.velocity.x = (hub.movement.get_facing_value() * horizontal_result)
		hub.movement.current_horizontal_velocity = hub.char_body.velocity.x

func slide_update(delta : float):
	if (current_attack_state != AttackState.ACTIVE):
		return
	
	hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value())
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	
	var intended_velocity : Vector2 = hub.char_body.velocity
	hub.char_body.move_and_slide()
	hub.collisions.upward_slope_correction(intended_velocity)
	
	current_slide_timer += delta
	if (current_slide_hang_timer > 0):
		current_slide_hang_timer = move_toward(current_slide_hang_timer, 0, delta)
	horizontal_result = move_toward(horizontal_result, 0, slide_deceleration_rate * delta)
