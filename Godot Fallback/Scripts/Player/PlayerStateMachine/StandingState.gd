extends State

class_name StandingState

@export var num_blink_animations : int = 3
@export var min_blink_time : float = 3
@export var max_blink_time : float = 4
var current_blink_timer = 0

var prev_is_crouching = false

func state_process(_delta):
	prev_is_crouching = hub.movement.is_crouching
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	
	if (hub.movement.is_crouching):
		if (!Input.is_action_pressed("Crouch") and hub.collisions.is_in_ceiling_when_uncrouched()):
			hub.animation.set_animation("MagliCrouchHeadbonk")
		else:
			hub.animation.set_animation("MagliCrouch")
	else:
		if(Input.is_action_just_released("Crouch") or (prev_is_crouching and !hub.movement.is_crouching)):
			hub.animation.set_animation("MagliStand")
		update_blink_timer(_delta)
		if (!hub.char_sprite.is_playing()):
			if (!check_blink_animation()):
				hub.animation.set_animation("MagliStand")
				hub.animation.set_animation_speed(1)
	
	if (hub.char_body.is_on_floor() and (!hub.collisions.is_facing_a_wall() or (hub.get_input_vector().x * hub.movement.get_facing_value()) < 0) and hub.get_input_vector().x != 0):
		set_next_state(state_machine.get_state_by_name("Running"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (!hub.char_body.is_on_floor()):
		set_next_state((state_machine.get_state_by_name("Falling")))
	else:
		pass

func on_enter():
	hub.jumping.landing_reset()
	hub.animation.set_animation("MagliStand" if !hub.movement.is_crouching else "MagliCrouch")
	hub.animation.set_animation_speed(1)

func set_blink_timer():
	current_blink_timer = randf_range(min_blink_time, max_blink_time)

func update_blink_timer(delta):
	if (num_blink_animations <= 0):
		return
	
	current_blink_timer = move_toward(current_blink_timer, 0, delta)

func check_blink_animation():
	if (num_blink_animations <= 0):
		return false
	
	if (current_blink_timer <= 0):
		var blink_anim_num = (randi() % num_blink_animations)
		hub.animation.set_animation("MagliStandBlink{num}".format({"num": blink_anim_num}))
		hub.animation.set_animation_speed(1)
		set_blink_timer()
		return true
	
	return false
