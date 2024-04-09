extends Node

enum ControlMode
{
	KEYBOARD,
	GAMEPAD
}

const IMAGE_STRING_FORMAT : String = "[img=16x16]%s[/img]"

@export var print_actions_and_inputs : bool = false

@export var event_to_input_prompt_dictionary : Dictionary

var current_control_mode : ControlMode = ControlMode.KEYBOARD

signal control_mode_changed

func _ready():
	print_action_and_input_names()

func _input(event):
	if (current_control_mode == ControlMode.KEYBOARD and (event is InputEventJoypadButton or event is InputEventJoypadMotion)):
		current_control_mode = ControlMode.GAMEPAD
		control_mode_changed.emit()
	elif (current_control_mode == ControlMode.GAMEPAD and (event is InputEventKey)):
		current_control_mode = ControlMode.KEYBOARD
		control_mode_changed.emit()
	else:
		pass

func print_action_and_input_names():
	if (print_actions_and_inputs):
		for action_name in InputMap.get_actions():
			if (!action_name.begins_with("ui_")):
				print_debug(action_name)
				for event in InputMap.action_get_events(action_name):
					print_debug("\t%s" % event.as_text())

func parse_text(raw_text : String):
	var result_text : String = raw_text
	var regex : RegEx = RegEx.new()
	regex.compile("(\\[.+?\\])") # Extracts action names surrounded by brackets via regular expression
	var results : Array[RegExMatch] = regex.search_all(raw_text)
	
	if (results != null and results.size() > 0):
		for result in results:
			var current_prompt : String = result.get_string()
			var action_name : String = current_prompt.substr(1, current_prompt.length() - 2)
			if (InputMap.has_action(action_name)):
				var input_events : Array[InputEvent] = InputMap.action_get_events(action_name)
				for event in input_events:
					if (current_control_mode == ControlMode.GAMEPAD and (event is InputEventJoypadButton or event is InputEventJoypadMotion)):
						if (event_to_input_prompt_dictionary.has(event.as_text())):
							result_text = result_text.replace(current_prompt, (IMAGE_STRING_FORMAT % event_to_input_prompt_dictionary[event.as_text()]))
					elif (current_control_mode == ControlMode.KEYBOARD and (event is InputEventKey)):
						if (event_to_input_prompt_dictionary.has(event.as_text())):
							result_text = result_text.replace(current_prompt, (IMAGE_STRING_FORMAT % event_to_input_prompt_dictionary[event.as_text()]))
					else:
						pass
	return result_text
