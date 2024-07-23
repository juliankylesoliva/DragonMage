extends CanvasLayer

class_name Textbox

enum TextboxState
{
	READY,
	SCROLLING,
	FINISHED
}

signal textbox_finished

@export var textbox_container : MarginContainer

@export var start_symbol : RichTextLabel

@export var end_symbol : RichTextLabel

@export var text_label : RichTextLabel

@export var start_symbol_char : String = ">"

@export var end_symbol_char_more : String = "\n\n\n\n\n>>\n[center][Interact]"

@export var end_symbol_char_last : String = "\n\n\n\n\n\n[center][Interact]"

@export var characters_per_second : float = 50

@export var accept_input_events : bool = true

@export var ui_canvas : CanvasLayer

# @export var default_stretch_ratio : float = 0.5

# @export var portrait_stretch_ratio : float = 3

var current_state : TextboxState = TextboxState.READY

var text_queue : Array[String]

var unformatted_text : String = ""

var current_characters : float = 0

func _ready():
	hide_textbox()
	GlobalSignals.bindings_changed.connect(on_bindings_changed)

func _process(_delta):
	self.set_visible(!get_tree().is_paused())
	if (current_state == TextboxState.READY and !text_queue.is_empty()):
		display_text()

func _input(event):
	if (accept_input_events):
		if (event.is_action_pressed("Interact")):
			advance_textbox()
		elif (event.is_action_pressed("Pause")):
			skip_textbox()
		else:
			pass

func advance_textbox():
	match current_state:
		TextboxState.READY:
			pass
		TextboxState.SCROLLING:
			skip_text_scrolling()
		TextboxState.FINISHED:
			if (!text_queue.is_empty()):
				hide_textbox()
				display_text()
			else:
				textbox_finished.emit()
				hide_textbox()

func skip_textbox():
	if (current_state != TextboxState.READY):
		text_queue.clear()
		hide_textbox()
		textbox_finished.emit()

func hide_textbox():
	unformatted_text = ""
	text_label.text = ""
	end_symbol.text = ""
	start_symbol.text = ""
	textbox_container.set_visible(false)
	if (ui_canvas != null and current_state != TextboxState.READY):
		for child in ui_canvas.get_children():
			child.show()
	change_state(TextboxState.READY)

func set_characters_per_second(cps : float):
	characters_per_second = cps

func show_textbox():
	start_symbol.text = start_symbol_char
	textbox_container.set_visible(true)

func queue_text(next_text : String):
	text_queue.push_back(next_text)

func clear_all_text():
	text_queue.clear()
	hide_textbox()

func display_text():
	var next_text : String = text_queue.pop_front()
	unformatted_text = next_text
	reformat_binding_text(next_text)
	show_textbox()
	if (ui_canvas != null):
		for child in ui_canvas.get_children():
			if (!(child is PauseMenu)):
				child.hide()
	do_text_scrolling()

func do_text_scrolling():
	if (current_state == TextboxState.READY):
		change_state(TextboxState.SCROLLING)
		text_label.visible_ratio = 0
		current_characters = 0
		
		while (textbox_container.visible and text_label.visible_ratio < 1):
			if (!get_tree().is_paused()):
				current_characters += (characters_per_second * get_physics_process_delta_time())
				text_label.visible_characters = (current_characters as int)
			await get_tree().process_frame
		text_label.visible_characters = -1
		
		if (textbox_container.visible):
			end_symbol.text = TextPromptParser.parse_text(end_symbol_char_more if !text_queue.is_empty() else end_symbol_char_last)
			change_state(TextboxState.FINISHED)
		else:
			hide_textbox()

func skip_text_scrolling():
	text_label.visible_ratio = 1

func change_state(next_state : TextboxState):
	current_state = next_state

func update_player_name_format_text(char_name : String):
	text_label.text = unformatted_text.format({"player_name" : char_name})
	reformat_binding_text(text_label.text)

func reformat_binding_text(text : String):
	text_label.text = TextPromptParser.parse_text(text)

func on_bindings_changed():
	reformat_binding_text(unformatted_text)
	if (textbox_container.visible and current_state == TextboxState.FINISHED):
		end_symbol.text = TextPromptParser.parse_text(end_symbol_char_more if !text_queue.is_empty() else end_symbol_char_last)
