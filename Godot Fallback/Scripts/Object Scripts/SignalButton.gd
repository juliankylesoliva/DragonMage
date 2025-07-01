extends Interactable

class_name SignalButton

signal button_pressed

@export var custom_prompt : String

@export var is_pressing_enabled : bool = true

@export var one_shot : bool = false

@export var button_texture_override : Texture2D = null

@export var button_sprite : Sprite2D

var prompt_template : String = "[center][Interact] %s"

var button_prompt_label : ButtonPromptTextLabel

func _ready():
	if (button_prompt is ButtonPromptTextLabel):
		button_prompt_label = (button_prompt as ButtonPromptTextLabel)
		if (button_prompt_label != null and !custom_prompt.is_empty()):
			button_prompt_label.set_raw_text(prompt_template % custom_prompt)

func interact(hub : PlayerHub):
	if (player != null and hub == player and is_pressing_enabled):
		button_pressed.emit()
		if (one_shot):
			is_pressing_enabled = false

func enable_pressing():
	is_pressing_enabled = true

func disable_pressing():
	is_pressing_enabled = false
