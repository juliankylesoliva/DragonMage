extends Node

class_name SelfDestructTimer

@export var lifetime : float = 1

var current_lifetime_left : float = 0

func _ready():
	refresh_lifetime()

func _process(delta):
	if (current_lifetime_left > 0):
		current_lifetime_left = move_toward(current_lifetime_left, 0, delta)
	else:
		queue_free()

func refresh_lifetime():
	current_lifetime_left = lifetime

func set_active():
	set_process_mode(Node.PROCESS_MODE_INHERIT)
