extends Node2D

class_name DefeatScreen

@export var header_label : RichTextLabel

@export var screen_fade : ScreenFade

func _ready():
	self.hide()

func do_defeat_screen():
	if (!self.is_visible()):
		self.global_position = get_viewport().get_camera_2d().get_screen_center_position()
		self.show()
		await get_tree().create_timer(2).timeout
		header_label.show()
		await get_tree().create_timer(3).timeout
		screen_fade.set_fade(1, 0.25, Color.BLACK)
		await get_tree().create_timer(0.25).timeout
		get_tree().reload_current_scene()
