extends Node2D

class_name ControlRebindingMenu

@export var bindings_display : RichTextLabel

@export var action_description_label : RichTextLabel

@export var max_bindings : int = 4

@export var rebind_input_time : float = 3

@export var rebindable_action_names : Array[StringName]

@export_multiline var action_descriptions : Dictionary

var current_action_list_index : int = 0

var action_to_edit : StringName = "Jump"

var is_accepting_menu_inputs : bool = true

var is_awaiting_input_rebind : bool = false

var current_rebind_timer : float = 0

func _ready():
	PauseHandler.enable_pausing(false)
	action_to_edit = rebindable_action_names[current_action_list_index]
	refresh_bindings_display()
	refresh_action_description()

func _process(_delta):
	if (current_rebind_timer > 0):
		current_rebind_timer = move_toward(current_rebind_timer, 0, _delta)
		if (current_rebind_timer <= 0):
			is_awaiting_input_rebind = false
		refresh_bindings_display()
	
	if (!self.is_visible() or !is_accepting_menu_inputs or is_awaiting_input_rebind):
		if (self.is_visible() and !is_awaiting_input_rebind and !is_accepting_menu_inputs):
			is_accepting_menu_inputs = true
		return
	
	var left_pressed : bool = Input.is_action_just_pressed("Menu Left")
	var right_pressed : bool = Input.is_action_just_pressed("Menu Right")
	
	if (Input.is_action_just_pressed("Menu Confirm")):
		if (InputMap.action_get_events(action_to_edit).size() < max_bindings):
			is_awaiting_input_rebind = true
			is_accepting_menu_inputs = false
			current_rebind_timer = rebind_input_time
		else:
			pass
	elif (Input.is_action_just_pressed("Menu Cancel")):
		toggle_menu(false)
	elif (Input.is_action_just_pressed("Menu Misc 1")):
		InputMap.load_from_project_settings()
		refresh_bindings_display()
	elif (Input.is_action_just_pressed("Menu Misc 2")):
		var matching_event_count : int = 0
		
		for event in InputMap.action_get_events(action_to_edit):
			if (TextPromptParser.is_using_gamepad() and ((event is InputEventJoypadButton) or (event is InputEventJoypadMotion))):
				InputMap.action_erase_event(action_to_edit, event)
				matching_event_count += 1
			elif (TextPromptParser.is_using_keyboard() and (event is InputEventKey)):
				InputMap.action_erase_event(action_to_edit, event)
				matching_event_count += 1
			else:
				pass
		
		if (matching_event_count <= 0):
			InputMap.action_erase_events(action_to_edit)
	elif ((left_pressed or right_pressed) and (!left_pressed or !right_pressed)):
		current_action_list_index += (1 if right_pressed else -1)
		if (current_action_list_index >= rebindable_action_names.size()):
			current_action_list_index = 0
		elif (current_action_list_index < 0):
			current_action_list_index = (rebindable_action_names.size() - 1)
		else:
			pass
		action_to_edit = rebindable_action_names[current_action_list_index]
		refresh_bindings_display()
		refresh_action_description()
	else:
		pass

func _input(event):
	if (is_awaiting_input_rebind and !event.is_released()):
		if (event is InputEventKey):
			var key : InputEventKey = (event as InputEventKey)
			InputMap.action_add_event(action_to_edit, key)
		elif (event is InputEventJoypadMotion):
			var joy_motion : InputEventJoypadMotion = (event as InputEventJoypadMotion)
			if (joy_motion.axis_value != 0):
				joy_motion.axis_value = (1.0 if joy_motion.axis_value > 0 else -1.0)
			InputMap.action_add_event(action_to_edit, joy_motion)
		elif (event is InputEventJoypadButton):
			var joy_button : InputEventJoypadButton = (event as InputEventJoypadButton)
			if (joy_button.is_pressed()):
				InputMap.action_add_event(action_to_edit, joy_button)
			else:
				return
		else:
			pass
		is_awaiting_input_rebind = false
		current_rebind_timer = 0
	
	refresh_bindings_display()

func toggle_menu(b : bool):
	if (b and !is_visible and !is_accepting_menu_inputs):
		current_action_list_index = 0
		action_to_edit = rebindable_action_names[current_action_list_index]
		refresh_bindings_display()
		refresh_action_description()
	set_visible(b)
	is_accepting_menu_inputs = b

func refresh_action_description():
	action_description_label.clear()
	action_description_label.set_text("")
	if (action_descriptions.keys().has(action_to_edit as StringName)):
		action_description_label.append_text(action_descriptions[action_to_edit])

func refresh_bindings_display():
	bindings_display.clear()
	bindings_display.set_text("")
	bindings_display.append_text("[center]")
	if (rebindable_action_names.has(action_to_edit)):
		bindings_display.append_text("CURRENT ACTION:\n")
		bindings_display.append_text(action_to_edit)
		bindings_display.append_text("\n\n[left]ASSIGNED INPUTS\n\n")
		for event in InputMap.action_get_events(action_to_edit):
			if (TextPromptParser.event_to_input_prompt_dictionary.keys().has(event.as_text())):
				bindings_display.append_text(TextPromptParser.IMAGE_STRING_FORMAT % TextPromptParser.event_to_input_prompt_dictionary[event.as_text()])
			else:
				bindings_display.append_text(event.as_text())
			bindings_display.append_text("\n")
		if (is_awaiting_input_rebind):
			bindings_display.append_text("Awaiting input, cancelling in {time_left}...".format({"time_left" : ceili(current_rebind_timer)}))
		bindings_display.append_text("\n")
