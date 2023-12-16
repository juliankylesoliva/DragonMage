extends Node

class_name PlayerMovement

@export var hub : PlayerHub

## Used to reduce jitter when using move_and_slide() up a steep slope and into a wall.
@export var max_slides : int = 60

## Affects what direction(s) this character can interact with walls in while in midair.
@export var can_change_facing_direction_in_midair : bool = true

## The maximum ground speed this character can run at.
@export var top_speed : float = 5.25

## Affects how quickly this character reaches top speed while on the ground.
@export var acceleration : float = 25

## Affects how quickly this character comes to a stop while on the ground.
@export var deceleration : float = 20

## Affects how quickly this character changes directions while on the ground.
@export var turning_speed : float = 45

## Affects how quickly this character reaches top speed while in the air.
@export var air_acceleration : float = 80.0

## Affects how quickly this character comes to a stop while in the air.
@export var air_deceleration : float = 60.0

## Affects how quickly this character changes directions while in the air.
@export var air_turning_speed : float = 70.0

@export var enable_crouch_walking : bool = true

@export var crouching_top_speed : float = 2.625

@export var min_crouch_time : float = 0.1

@export var crouch_cooldown_time : float = 0.167

var is_facing_right : bool = true
var is_crouching : bool = false
var current_min_crouch_timer : float = 0
var current_crouch_cooldown_timer : float = 0
var current_horizontal_velocity : float = 0

func _ready():
	hub.char_body.set_max_slides(max_slides)

func _process(delta):
	update_min_crouch_timer(delta)
	update_crouch_cooldown_timer(delta)

func update_facing_direction():
	if ((!can_change_facing_direction_in_midair and !hub.char_body.is_on_floor())):
		return
	set_facing_direction(hub.get_input_vector().x)

func set_facing_direction(horizontal_axis : float):
	if (horizontal_axis > 0):
		is_facing_right = true
		hub.char_sprite.flip_h = false
	elif (horizontal_axis < 0):
		is_facing_right = false
		hub.char_sprite.flip_h = true
	else:
		pass

func get_facing_value():
	return (1 if is_facing_right else -1)

func is_turning():
	var horizontal_axis = hub.get_input_vector().x
	return (horizontal_axis * current_horizontal_velocity < 0)

func check_crouch_state():
	var state_name : String = hub.state_machine.current_state.name
	if (state_name != "Standing" and state_name != "Running" and state_name != "Jumping" and state_name != "Falling"):
		is_crouching = false
		return
	
	if (!is_crouching):
		is_crouching = (current_crouch_cooldown_timer <= 0 and Input.is_action_pressed("Crouch") and (hub.jumping.enable_crouch_jumping or hub.char_body.is_on_floor()))
		if (is_crouching):
			current_min_crouch_timer = min_crouch_time
	else:
		is_crouching = (current_min_crouch_timer > 0 or hub.collisions.is_in_ceiling_when_uncrouched() or (Input.is_action_pressed("Crouch") and (hub.char_body.is_on_floor() or hub.jumping.enable_crouch_jumping)))
		if (!is_crouching and state_name == "Jumping" and !hub.jumping.enable_crouch_jumping):
			hub.animation.set_animation("{name}Jump".format({"name" : hub.form.get_current_form_name()}))
			hub.animation.set_animation_frame(0)
			hub.animation.set_animation_speed(0)
		if (!is_crouching):
			current_crouch_cooldown_timer = crouch_cooldown_time

func reset_current_horizontal_velocity():
	current_horizontal_velocity = 0

func reset_crouch_state():
	current_min_crouch_timer = 0
	if (is_crouching):
		current_crouch_cooldown_timer = crouch_cooldown_time
	is_crouching = false

func update_min_crouch_timer(delta):
	if (current_min_crouch_timer > 0):
		current_min_crouch_timer = move_toward(current_min_crouch_timer, 0, delta)

func update_crouch_cooldown_timer(delta):
	if (current_crouch_cooldown_timer > 0):
		current_crouch_cooldown_timer = move_toward(current_crouch_cooldown_timer, 0, delta)

func do_movement(delta):
	if (hub.jumping.is_wall_jump_lock_timer_active()):
		hub.char_body.move_and_slide()
		return
	
	var horizontal_axis = hub.get_input_vector().x
	
	if (horizontal_axis != 0 and (!is_crouching or enable_crouch_walking)):
		if (hub.collisions.is_moving_against_a_wall()):
			current_horizontal_velocity = 0
		elif ((current_horizontal_velocity * horizontal_axis) >= 0):
			var accel = (acceleration if hub.char_body.is_on_floor() else air_acceleration)
			var turn = (turning_speed if hub.char_body.is_on_floor() else air_turning_speed)
			var accel_delta = (accel if !is_turning() else turn)
			var target_speed = (top_speed if !is_crouching else crouching_top_speed)
			
			if (abs(current_horizontal_velocity) < target_speed):
				current_horizontal_velocity = move_toward(current_horizontal_velocity, target_speed * horizontal_axis, accel_delta * delta)
			elif (hub.char_body.is_on_floor() and abs(current_horizontal_velocity) > target_speed):
				if (current_horizontal_velocity != 0):
					current_horizontal_velocity = move_toward(current_horizontal_velocity, target_speed * horizontal_axis, deceleration * delta)
			else:
				pass
		else:
			if (current_horizontal_velocity != 0):
				var turn = (turning_speed if hub.char_body.is_on_floor() else air_turning_speed)
				var target_speed = (top_speed if !is_crouching else crouching_top_speed)
				current_horizontal_velocity = move_toward(current_horizontal_velocity, -target_speed if current_horizontal_velocity > 0 else target_speed, turn * delta)
				hub.collisions.do_ledge_nudge()
	else:
		var decel = (deceleration if hub.char_body.is_on_floor() else air_deceleration)
		current_horizontal_velocity = (move_toward(current_horizontal_velocity, 0, decel * delta) if !hub.collisions.is_near_a_ledge() else 0.0)
		hub.collisions.do_ledge_nudge()
	
	hub.char_body.velocity.x = current_horizontal_velocity
	hub.char_body.move_and_slide()

func get_speed_portion(clamped : bool = true):
	var ret_val = abs(hub.char_body.velocity.x / (top_speed if !is_crouching else crouching_top_speed))
	return (min(1, ret_val) if clamped else ret_val)
