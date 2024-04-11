extends Node2D

class_name DefeatScreen

@export var header_label : RichTextLabel

@export var screen_fade : ScreenFade

@export var label_messages : Array[String]

@export var message_change_cadence : int = 3

func _ready():
	self.hide()
	set_label_text()

func set_label_text():
	if (label_messages.size() > 0):
		header_label.text = ("[center][shake rate=40 level=10]%s[/shake]" % label_messages[(CheckpointHandler.death_counter / message_change_cadence) % label_messages.size()])

func do_defeat_screen():
	if (!self.is_visible()):
		self.global_position = get_viewport().get_camera_2d().get_screen_center_position()
		self.show()
		await get_tree().create_timer(2).timeout
		header_label.show()
		await get_tree().create_timer(2).timeout
		screen_fade.set_fade(1, 0.25, Color.BLACK)
		await get_tree().create_timer(0.25).timeout
		get_tree().reload_current_scene()
