extends Node2D

class_name MenuCursor

@export var left_cursor : AnimatedSprite2D

@export var right_cursor : AnimatedSprite2D

@export var magic_sfx : AudioStreamPlayer2D

@export var dragon_sfx : AudioStreamPlayer2D

@export var magic_move_sfx_stream : AudioStream

@export var dragon_move_sfx_stream : AudioStream

@export var magic_select_sfx_stream : AudioStream

@export var dragon_select_sfx_stream : AudioStream

@export var padding : float = 16

@export var initial_spacing : float = 0

@export var select_acceleration : float = 4096

@export var max_select_distance : float = 512

var is_select_mode_on : bool = false

var current_select_speed : float = 0

var current_select_offset : float = 0

var current_offset : float = 0

func _ready():
	set_spacing(initial_spacing)

func _physics_process(delta):
	if (is_select_mode_on):
		current_select_speed += abs(select_acceleration * delta)
		current_select_offset += abs(current_select_speed * delta)
		left_cursor.offset.x = (-current_offset + current_select_offset)
		right_cursor.offset.x = (current_offset - current_select_offset)
		if ((current_select_offset - current_offset) > max_select_distance):
			is_select_mode_on = false

func set_spacing(distance : float):
	var half : float = abs(distance / 2.0)
	left_cursor.offset.x = -(half + padding)
	right_cursor.offset.x = (half + padding)
	current_offset = right_cursor.offset.x

func reset_select_movement():
	is_select_mode_on = false
	current_select_speed = 0
	current_select_offset = 0
	left_cursor.offset.x = -current_offset
	right_cursor.offset.x = current_offset

func do_selection_movement():
	if (!is_select_mode_on):
		reset_select_movement()
		play_select_sound()
		is_select_mode_on = true

func play_move_sound():
	magic_sfx.stream = magic_move_sfx_stream
	dragon_sfx.stream = dragon_move_sfx_stream
	magic_sfx.play()
	dragon_sfx.play()

func play_select_sound():
	magic_sfx.stream = magic_select_sfx_stream
	dragon_sfx.stream = dragon_select_sfx_stream
	magic_sfx.play()
	dragon_sfx.play()
