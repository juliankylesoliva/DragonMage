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

var is_facing_right : bool = true
var current_horizontal_velocity : float = 0

func _ready():
	hub.char_body.set_max_slides(max_slides)

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

func do_movement(delta):
	var horizontal_axis = hub.get_input_vector().x
	
	if (hub.collisions.is_moving_against_a_wall()):
		current_horizontal_velocity = 0
	elif (horizontal_axis != 0):
		var accel = (acceleration if hub.char_body.is_on_floor() else air_acceleration)
		var turn = (turning_speed if hub.char_body.is_on_floor() else air_turning_speed)
		var accel_delta = (accel if !is_turning() else turn)
		current_horizontal_velocity = move_toward(current_horizontal_velocity, top_speed * horizontal_axis, accel_delta * delta)
	else:
		var decel = (deceleration if hub.char_body.is_on_floor() else air_deceleration)
		current_horizontal_velocity = move_toward(current_horizontal_velocity, 0, decel * delta)
	
	hub.char_body.velocity.x = current_horizontal_velocity
	
	hub.char_body.move_and_slide()

func get_speed_portion(clamped : bool = true):
	var ret_val = abs(hub.char_body.velocity.x / top_speed)
	return (min(1, ret_val) if clamped else ret_val)
