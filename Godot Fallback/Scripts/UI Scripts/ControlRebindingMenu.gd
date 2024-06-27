extends Node

class_name ControlRebindingMenu

@export var test_label : RichTextLabel

@export var rebindable_action_names : Array[StringName]

var current_action_list_index : int = 0

var action_to_edit : StringName = "Jump"

var is_awaiting_input_rebind : bool = false

func _ready():
	PauseHandler.enable_pausing(false)
	action_to_edit = rebindable_action_names[current_action_list_index]
	refresh_test_label()

func _process(_delta):
	var left_pressed : bool = Input.is_action_just_pressed("Menu Left")
	var right_pressed : bool = Input.is_action_just_pressed("Menu Right")
	
	if ((left_pressed or right_pressed) and (!left_pressed or !right_pressed)):
		current_action_list_index += (1 if right_pressed else -1)
		if (current_action_list_index >= rebindable_action_names.size()):
			current_action_list_index = 0
		elif (current_action_list_index < 0):
			current_action_list_index = (rebindable_action_names.size() - 1)
		else:
			pass
		action_to_edit = rebindable_action_names[current_action_list_index]
		refresh_test_label()

func _input(event):
	if (is_awaiting_input_rebind):
		if (event is InputEventKey):
			for e in InputMap.action_get_events(action_to_edit):
				if (e is InputEventKey):
					InputMap.action_erase_event(action_to_edit, e)
			var key : InputEventKey = (event as InputEventKey)
			key.keycode = KEY_NONE
			key.unicode = KEY_NONE
			InputMap.action_add_event(action_to_edit, key)
		is_awaiting_input_rebind = false
	
	refresh_test_label()

func refresh_test_label():
	test_label.clear()
	test_label.set_text("")
	test_label.append_text("[center]")
	if (rebindable_action_names.has(action_to_edit)):
		test_label.append_text("CURRENT ACTION:\n")
		test_label.append_text(action_to_edit)
		test_label.append_text("\n\n[left]BINDINGS\n\n")
		for event in InputMap.action_get_events(action_to_edit):
			if (TextPromptParser.event_to_input_prompt_dictionary.keys().has(event.as_text())):
				test_label.append_text(TextPromptParser.IMAGE_STRING_FORMAT % TextPromptParser.event_to_input_prompt_dictionary[event.as_text()])
			else:
				test_label.append_text(event.as_text())
			test_label.append_text("\n")
		test_label.append_text("\n")
