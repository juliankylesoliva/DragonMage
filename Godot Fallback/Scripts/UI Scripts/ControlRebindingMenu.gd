extends MenuTemplate

class_name ControlRebindingMenu

@export var bindings_display : RichTextLabel

@export var action_description_label : RichTextLabel

@export var max_bindings : int = 4

@export var rebind_input_time : float = 3

@export var rebindable_action_names : Array[StringName]

@export_multiline var action_descriptions : Dictionary

var action_to_edit : StringName = "Jump"

var is_awaiting_input_rebind : bool = false

var current_rebind_timer : float = 0

func _ready():
	PauseHandler.enable_pausing(false)
	action_to_edit = rebindable_action_names[current_selection]
	max_selections = rebindable_action_names.size()
	refresh_bindings_display()
	refresh_action_description()

func _process(_delta):
	if (current_rebind_timer > 0):
		current_rebind_timer = move_toward(current_rebind_timer, 0, _delta)
		if (current_rebind_timer <= 0):
			is_awaiting_input_rebind = false
		refresh_bindings_display()
	
	if (!self.is_visible() or !enable_input or is_awaiting_input_rebind):
		if (self.is_visible() and !is_awaiting_input_rebind and !enable_input):
			enable_input = true
		return
	
	super._process(_delta)

func _input(event):
	if (is_awaiting_input_rebind and !event.is_released()):
		if (event is InputEventKey):
			var key : InputEventKey = (event as InputEventKey)
			InputMap.action_add_event(action_to_edit, key)
			menu_cursor.play_accept_sound()
		elif (event is InputEventJoypadMotion):
			var joy_motion : InputEventJoypadMotion = (event as InputEventJoypadMotion)
			if (joy_motion.axis_value != 0):
				joy_motion.axis_value = (1.0 if joy_motion.axis_value > 0 else -1.0)
			InputMap.action_add_event(action_to_edit, joy_motion)
			menu_cursor.play_accept_sound()
		elif (event is InputEventJoypadButton):
			var joy_button : InputEventJoypadButton = (event as InputEventJoypadButton)
			if (joy_button.is_pressed()):
				InputMap.action_add_event(action_to_edit, joy_button)
				menu_cursor.play_accept_sound()
			else:
				return
		else:
			pass
		is_awaiting_input_rebind = false
		current_rebind_timer = 0
	
	refresh_bindings_display()

func on_selection_confirm():
	if (InputMap.action_get_events(action_to_edit).size() < max_bindings):
			is_awaiting_input_rebind = true
			enable_input = false
			current_rebind_timer = rebind_input_time
			menu_cursor.play_accept_sound()

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()
		menu_cursor.show()

func on_menu_misc_1():
	InputMap.load_from_project_settings()
	menu_cursor.play_accept_sound()
	refresh_bindings_display()

func on_menu_misc_2():
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
	menu_cursor.play_cancel_sound()
	refresh_bindings_display()

func on_left_pressed():
	decrement_selection()

func on_right_pressed():
	increment_selection()

func on_selection_change():
	action_to_edit = rebindable_action_names[current_selection]
	refresh_bindings_display()
	refresh_action_description()
	menu_cursor.play_move_sound()

func on_selection_reset():
	action_to_edit = rebindable_action_names[current_selection]
	refresh_bindings_display()
	refresh_action_description()

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
			bindings_display.append_text("Awaiting input, canceling in {time_left}...".format({"time_left" : ceili(current_rebind_timer)}))
		bindings_display.append_text("\n")
