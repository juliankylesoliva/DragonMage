extends Node

var is_unpausing_locked : bool = false

func _input(event):
	if (event.is_action_pressed("Pause")):
		var tree : SceneTree = get_tree()
		var pause : bool = !tree.is_paused()
		if (!tree.is_paused() or !is_unpausing_locked):
			get_tree().set_pause(pause)

func enable_pausing(b : bool):
	set_unpause_lock(false)
	get_tree().set_pause(false)
	self.set_process_mode(PROCESS_MODE_ALWAYS if b else PROCESS_MODE_DISABLED)

func set_unpause_lock(b : bool):
	if (get_tree().is_paused()):
		is_unpausing_locked = b
