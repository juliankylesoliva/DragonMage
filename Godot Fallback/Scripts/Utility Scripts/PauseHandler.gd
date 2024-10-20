extends Node

var is_unpausing_locked : bool = false

signal game_paused

signal game_unpaused

func _input(event):
	if (event.is_action_pressed("Pause")):
		do_pause()

func do_pause():
	var tree : SceneTree = get_tree()
	var pause : bool = !tree.is_paused()
	if (!tree.is_paused() or !is_unpausing_locked):
		get_tree().set_pause(pause)
		if (pause):
			game_paused.emit()
		else:
			game_unpaused.emit()

func enable_pausing(b : bool):
	set_unpause_lock(false)
	get_tree().set_pause(false)
	self.set_process_mode(PROCESS_MODE_ALWAYS if b else PROCESS_MODE_DISABLED)
	game_unpaused.emit()

func set_unpause_lock(b : bool):
	if (get_tree().is_paused()):
		is_unpausing_locked = b
