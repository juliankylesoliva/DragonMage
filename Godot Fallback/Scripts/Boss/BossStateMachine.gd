extends Node

class_name BossStateMachine

@export var boss : Boss
@export var current_state : BossState
var previous_state : BossState

var states_list : Array[BossState]

func _ready():
	for child in get_children():
		if (child is BossState):
			states_list.append(child)
			
			child.state_machine = self
			child.boss = boss
		else:
			push_warning("Invalid State! ({name})".format({"name": child.name}))
			
	current_state.on_enter()

func _physics_process(delta):
	current_state.state_process(delta)
	if (current_state.next_state != null):
		switch_states(current_state.next_state)

func switch_states(new_state : BossState):
	if (current_state != null):
		current_state.on_exit()
		current_state.next_state = null
	
	previous_state = current_state
	current_state = new_state
	current_state.on_enter()

func get_state_by_name(state_name : String):
	for state in states_list:
		if (state.name == state_name):
			return state
	push_error("Invalid state name! ({str})".format({"str": state_name}))
	return null

func match_current_state_name(state_name : String):
	return (current_state.name == state_name)
