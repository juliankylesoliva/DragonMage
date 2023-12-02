extends Node

class_name Attack

enum AttackState {NOTHING, STARTUP, ACTIVE, ENDLAG}

@export var uses_attack_state : bool = false

var hub : PlayerHub

var current_attack_state : AttackState = AttackState.NOTHING

func can_use_attack():
	return false

func use_attack():
	pass

func on_attack_state_enter():
	pass

func attack_state_process(_delta : float):
	pass

func on_attack_state_exit():
	pass
