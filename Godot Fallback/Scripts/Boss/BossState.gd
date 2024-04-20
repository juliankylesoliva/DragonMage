extends Node

class_name BossState

var state_machine : BossStateMachine
var boss : Boss
var next_state : BossState

func state_process(_delta):
	pass

func on_enter():
	pass

func on_exit():
	pass

func set_next_state(next : BossState):
	if (next_state == null && next != self):
		next_state = next
