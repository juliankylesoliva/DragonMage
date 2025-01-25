extends Node2D

class_name ClearTimer

const MAX_TIME : float = 5999.99

@export var timer_label : RichTextLabel

@export var time_format : String = "{minutes}:{seconds}"

var current_time : float = 0

var is_timer_stopped : bool = false

func _ready():
	self.visible = OptionsHelper.enable_clear_timer_toggle
	if (CheckpointHandler.saved_clear_time >= 0):
		current_time = CheckpointHandler.saved_clear_time

func _physics_process(delta):
	if (!is_timer_stopped):
		self.visible = OptionsHelper.enable_clear_timer_toggle
		current_time = move_toward(current_time, MAX_TIME, delta)
		timer_label.text = time_format.format({"minutes" : "%02d" % (floor(current_time / 60) as int), "seconds" : "%04.1f" % fmod(current_time, 60.0)})

func start_timer():
	is_timer_stopped = false

func stop_timer():
	is_timer_stopped = true

func get_current_time():
	return current_time
