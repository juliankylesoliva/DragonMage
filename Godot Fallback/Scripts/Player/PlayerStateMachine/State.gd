extends Node

class_name State

@export var can_update_camera_x_pos : bool = true

@export var can_update_camera_y_pos : bool = true

var state_machine : PlayerStateMachine
var hub : PlayerHub
var next_state : State

func state_process(_delta):
	pass

func state_input(_event : InputEvent):
	pass

func on_enter():
	pass

func on_exit():
	pass

func set_next_state(next : State):
	if (next_state == null && (next != self or self.name == "Attacking")):
		next_state = next
