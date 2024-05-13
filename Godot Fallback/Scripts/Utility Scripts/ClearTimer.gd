extends Node

class_name ClearTimer

var current_time : float = 0

var is_timer_stopped : bool = false

func _ready():
	if (CheckpointHandler.saved_clear_time >= 0):
		current_time = CheckpointHandler.saved_clear_time

func _physics_process(delta):
	if (!is_timer_stopped):
		current_time += delta

func start_timer():
	is_timer_stopped = false

func stop_timer():
	is_timer_stopped = true

func get_current_time():
	return current_time
