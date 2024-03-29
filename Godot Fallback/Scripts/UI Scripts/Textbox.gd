extends CanvasLayer

class_name Textbox

enum TextboxState
{
	READY,
	SCROLLING,
	FINISHED
}

@export var textbox_container : MarginContainer

@export var start_symbol : RichTextLabel

@export var end_symbol : RichTextLabel

@export var text_label : RichTextLabel

@export var start_symbol_char : String = ">"

@export var end_symbol_char : String = "\n\n\n\n\n\n[center][Interact]"

@export var text_scrolling_duration : float = 1

@export var accept_input_events : bool = true

# @export var default_stretch_ratio : float = 0.5

# @export var portrait_stretch_ratio : float = 3

var current_state : TextboxState = TextboxState.READY

var text_queue : Array[String]

func _ready():
	hide_textbox()

func _process(_delta):
	self.set_visible(!get_tree().is_paused())
	if (current_state == TextboxState.READY and !text_queue.is_empty()):
		display_text()

func _input(event):
	if (accept_input_events and event.is_action_pressed("Interact")):
		advance_textbox()

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
				hide_textbox()

func hide_textbox():
	text_label.text = ""
	end_symbol.text = ""
	start_symbol.text = ""
	textbox_container.set_visible(false)
	change_state(TextboxState.READY)

func set_text_scroll_duration(time : float):
	text_scrolling_duration = time

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
	text_label.text = next_text
	show_textbox()
	do_text_scrolling()

func do_text_scrolling():
	if (current_state == TextboxState.READY):
		change_state(TextboxState.SCROLLING)
		text_label.visible_ratio = 0
		
		while (textbox_container.visible and text_label.visible_ratio < 1):
			if (!get_tree().is_paused()):
				text_label.visible_ratio = move_toward(text_label.visible_ratio, 1, get_process_delta_time() / text_scrolling_duration)
			await get_tree().process_frame
		
		if (textbox_container.visible):
			end_symbol.text = TextPromptParser.parse_text(end_symbol_char)
			change_state(TextboxState.FINISHED)
		else:
			hide_textbox()

func skip_text_scrolling():
	text_label.visible_ratio = 1

func change_state(next_state : TextboxState):
	current_state = next_state
