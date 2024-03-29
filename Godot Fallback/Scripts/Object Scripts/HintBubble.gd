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

func interact(hub : PlayerHub):
	if (player != null and hub == player):
		if (textbox != null):
			if (textbox.current_state == Textbox.TextboxState.READY):
				for s in textbox_strings:
					textbox.queue_text(TextPromptParser.parse_text(s))
			else:
				textbox.advance_textbox()

func on_player_exited():
	if (textbox != null):
		textbox.clear_all_text()
