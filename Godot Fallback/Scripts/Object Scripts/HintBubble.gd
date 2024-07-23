extends Interactable

@export var textbox : Textbox

@export var sprite : AnimatedSprite2D

@export_multiline var textbox_strings : Array[String]

@export_range(0, 1) var active_alpha : float = 0.6

func _process(_delta):
	if (textbox != null):
		sprite.modulate.a = (1.0 if textbox.current_state == Textbox.TextboxState.READY or player == null else active_alpha)
		if (player != null):
			button_prompt.set_visible(textbox.current_state == Textbox.TextboxState.READY)
			if (textbox.unformatted_text.contains("{player_name}")):
				textbox.update_player_name_format_text(player.form.get_current_form_name())

func interact(hub : PlayerHub):
	if (player != null and hub == player):
		if (textbox != null):
			textbox.accept_input_events = false
			if (textbox.current_state == Textbox.TextboxState.READY):
				for s in textbox_strings:
					textbox.queue_text(s)
			else:
				textbox.advance_textbox()

func on_player_exited():
	if (textbox != null):
		textbox.clear_all_text()
