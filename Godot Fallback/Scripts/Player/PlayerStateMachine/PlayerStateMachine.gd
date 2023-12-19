extends Node

class_name PlayerStateMachine

@export var hub : PlayerHub
@export var current_state : State
var previous_state : State

var states_list : Array[State]

func _ready():
	for child in get_children():
		if (child is State):
			states_list.append(child)
			
			child.state_machine = self
			child.hub = hub
		else:
			push_warning("Invalid State! ({name})".format({"name": child.name}))
			
	current_state.on_enter()

func _physics_process(delta):
	current_state.state_process(delta)
	
	if (current_state.next_state != null):
		switch_states(current_state.next_state)

func switch_states(new_state : State):
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

func _input(event : InputEvent):
	current_state.state_input(event)
