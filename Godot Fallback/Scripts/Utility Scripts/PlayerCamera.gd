extends Node

class_name PlayerCamera

@export var hub : PlayerHub

@export var player_cam : Camera2D

@export var base_x_lookahead : float = 64

@export var max_x_lookahead : float = 192

@export var time_to_update_x : float = 0.25

@export var upper_camera_threshold : float = 128

@export var lower_camera_threshold : float = 0

@export var time_to_update_y : float = 0.25

var saved_y_position : float = 0

func _ready():
	saved_y_position = hub.char_body.global_position.y
	snap_camera_to_player()

func _process(delta):
	var x_lookahead : float = (base_x_lookahead * (hub.char_body.velocity.x / hub.movement.top_speed))
	if (abs(x_lookahead) > max_x_lookahead):
		if (x_lookahead > 0):
			x_lookahead = max_x_lookahead
		else:
			x_lookahead = -max_x_lookahead
	
	var target_x : float = (hub.char_body.global_position.x + x_lookahead)
	player_cam.global_position.x = (move_toward(player_cam.global_position.x, target_x, (abs(target_x - player_cam.global_position.x) / time_to_update_x) * delta) as int)
	
	if (hub.char_body.is_on_floor() or !is_between_thresholds()):
		saved_y_position = hub.char_body.position.y
	
	var target_y : float = saved_y_position
	player_cam.global_position.y = ((move_toward(player_cam.global_position.y, target_y, (abs(target_y - player_cam.global_position.y) / time_to_update_y) * delta) as int) if hub.char_body.is_on_floor() or player_cam.global_position.y != target_y else (saved_y_position as int))

func snap_camera_to_player():
	player_cam.global_position = (hub.char_body.global_position as Vector2i)

func is_above_upper_threshold():
	return (hub.char_body.global_position.y < (player_cam.get_screen_center_position().y - upper_camera_threshold))

func is_below_lower_threshold():
	return (hub.char_body.global_position.y > (player_cam.get_screen_center_position().y + lower_camera_threshold))

func is_between_thresholds():
	return (!is_above_upper_threshold() and !is_below_lower_threshold())
