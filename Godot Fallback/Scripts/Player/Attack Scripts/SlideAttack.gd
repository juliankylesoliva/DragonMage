extends Attack

class_name SlideAttack

@export var slide_min_horizontal_speed : float = 5

@export var slide_max_horizontal_speed : float = 10

@export var slide_deceleration_rate : float = 2.5

@export var slide_min_duration : float = 0.2

@export var slide_uncancelable_time : float = 0.25

var prev_horizontal_velocity : float = 0

var horizontal_result : float = 0

var current_slide_timer : float = 0

func can_use_attack():
	var state_name : String = hub.state_machine.current_state.name
	return (hub.form.current_mode == PlayerForm.CharacterMode.DRAGON and state_name != "Attacking" and (hub.attacks.current_attack == null or hub.attacks.current_attack.name != self.name) and (!hub.attacks.is_attack_cooldown_active() or hub.jumping.can_fast_fall_slope_boost()) and (hub.movement.is_crouching or hub.jumping.can_fast_fall_slope_boost()) and (state_name == "Standing" or state_name == "Running" or (state_name == "Falling" and hub.jumping.can_fast_fall_slope_boost())) and hub.char_body.is_on_floor() and ((!hub.collisions.is_facing_a_wall() and !hub.collisions.is_near_a_ledge(hub.movement.get_facing_value())) or (hub.jumping.can_fast_fall_slope_boost() and !hub.collisions.is_near_a_ledge(hub.movement.get_facing_value()))))

func on_attack_state_enter():
	if (!hub.movement.is_crouching):
		hub.movement.is_crouching = true
		hub.movement.current_min_crouch_timer = hub.movement.min_crouch_time
	current_attack_state = AttackState.ACTIVE
	prev_horizontal_velocity = abs(hub.movement.current_horizontal_velocity)
	hub.animation.set_animation("DraelynSlide")
	horizontal_result = abs(min((prev_horizontal_velocity + slide_min_horizontal_speed) , slide_max_horizontal_speed))
	hub.char_body.velocity = (Vector2.RIGHT * horizontal_result * hub.movement.get_facing_value())
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	current_slide_timer = 0

func attack_state_process(_delta : float):
	if (hub.collisions.is_facing_a_wall() or hub.collisions.is_near_a_ledge() or hub.collisions.get_distance_to_ground() > hub.char_body.floor_snap_length):
		stop_slide()
	elif (!hub.collisions.is_in_ceiling_when_uncrouched() and current_slide_timer > slide_uncancelable_time and (hub.get_input_vector().x * hub.char_body.velocity.x) > 0 and hub.buffers.is_jump_buffer_active()):
		do_jump_cancel()
	elif (!hub.collisions.is_in_ceiling_when_uncrouched() and current_slide_timer > slide_uncancelable_time and hub.buffers.is_attack_buffer_active()):
		do_attack_cancel()
	elif (horizontal_result <= 0 or (current_slide_timer > slide_min_duration and (!Input.is_action_pressed("Crouch") or (hub.get_input_vector().x * hub.movement.get_facing_value()) < 0))):
		stop_slide()
	else:
		slide_update(_delta)

func on_attack_state_exit():
	current_attack_state = AttackState.NOTHING
	prev_horizontal_velocity = 0
	horizontal_result = 0
	current_slide_timer = 0

func do_jump_cancel():
	if (current_attack_state != AttackState.ACTIVE):
		return
	hub.buffers.reset_jump_buffer()
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
	hub.char_body.velocity.x = (0 if (hub.collisions.is_facing_a_wall() or (hub.collisions.is_near_a_ledge() and hub.get_input_vector().x == 0)) else (hub.movement.get_facing_value() * min(horizontal_result, hub.movement.top_speed)))
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	if (hub.char_body.is_on_floor() and (hub.get_input_vector().x != 0 or hub.char_body.velocity.x != 0)):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Running"))
	elif (hub.char_body.velocity.y >= 0 and !hub.char_body.is_on_floor()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Falling"))
	else:
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))

func slide_update(delta : float):
	if (current_attack_state != AttackState.ACTIVE):
		return
	hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value())
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	hub.char_body.move_and_slide()
	current_slide_timer += delta
	horizontal_result = move_toward(horizontal_result, 0, slide_deceleration_rate * delta)