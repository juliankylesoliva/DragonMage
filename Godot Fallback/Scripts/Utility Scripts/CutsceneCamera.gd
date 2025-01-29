extends Node

signal camera_movement_finished

@export var camera : Camera2D

@export var path : Path2D

@export var follow : PathFollow2D

@export var remote_transform : RemoteTransform2D

var is_moving : bool = false

var travel_time : float = 0

var disable_after_movement : bool = false

func _physics_process(delta):
	if (is_moving):
		if (!camera.is_enabled() or !camera.is_current()):
			self.set_enabled(true)
		follow.progress_ratio = move_toward(follow.progress_ratio, 1.0, delta / travel_time)
		if (follow.progress_ratio >= 1):
			finish_movement()

func set_enabled(b : bool):
	camera.set_enabled(b)
	if (b):
		camera.make_current()

func set_camera_position(pos : Vector2):
	camera.global_position = pos

func move_camera_from_to(from : Vector2, to : Vector2, time : float, disable_after : bool = false):
	if (is_moving):
		return
	
	remote_transform.set_update_position(false)
	path.curve.clear_points()
	path.curve.add_point(from)
	path.curve.add_point(to)
	follow.set_progress_ratio(0)
	
	remote_transform.set_update_position(true)
	travel_time = time
	is_moving = true
	disable_after_movement = disable_after

func move_camera_to(dest : Vector2, time : float, disable_after : bool = false):
	if (is_moving):
		return
	
	remote_transform.set_update_position(false)
	path.curve.clear_points()
	path.curve.add_point(camera.global_position)
	path.curve.add_point(dest)
	follow.set_progress_ratio(0)
	
	remote_transform.set_update_position(true)
	travel_time = time
	is_moving = true
	disable_after_movement = disable_after

func finish_movement():
	follow.set_progress_ratio(1)
	remote_transform.set_update_position(false)
	is_moving = false
	if (disable_after_movement):
		self.set_enabled(false)
	camera_movement_finished.emit()
