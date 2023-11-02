extends Node

class_name PlayerBuffers

@export var hub : PlayerHub

## Allows a player to press the jump button early and still have their input be registered within a small window of time.
@export var jump_buffer_time : float = 0.15
var jump_buffer_time_left : float = 0

## Allows a player to jump within a small window of time if they had just ran off of a ledge.
@export var coyote_time : float = 0.2
var coyote_time_left : float = 0
var prev_is_on_floor : bool = false

func _ready():
	prev_is_on_floor = hub.char_body.is_on_floor()

func _input(event):
	if (event.is_action_pressed("Jump")):
		refresh_jump_buffer()

func _process(delta):
	check_jump_buffer(delta)
	check_coyote_time(delta)

func check_jump_buffer(delta : float):
	if (is_jump_buffer_active()):
		jump_buffer_time_left = move_toward(jump_buffer_time_left, 0, delta)

func is_jump_buffer_active():
	return jump_buffer_time_left > 0

func reset_jump_buffer():
	jump_buffer_time_left = 0

func refresh_jump_buffer():
	jump_buffer_time_left = jump_buffer_time

func check_coyote_time(delta : float):
	if (!hub.char_body.is_on_floor() and prev_is_on_floor and coyote_time_left <= 0 and hub.char_body.velocity.y >= 0):
		coyote_time_left = coyote_time
	elif ((hub.char_body.is_on_floor() and !prev_is_on_floor) or (hub.char_body.is_on_floor() and prev_is_on_floor)):
		coyote_time_left = 0
	else:
		pass
	
	if (coyote_time_left > 0):
		coyote_time_left = move_toward(coyote_time_left, 0, delta)
	
	prev_is_on_floor = hub.char_body.is_on_floor()

func is_coyote_time_active():
	return coyote_time_left > 0
