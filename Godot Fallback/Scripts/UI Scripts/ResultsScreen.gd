extends Node2D

class_name ResultsScreen

@export var blue_bg : Sprite2D

@export var orange_bg : Sprite2D

@export var combine_point_offset : Vector2

@export var level : Level

@export var clear_timer : ClearTimer

@export var screen_width : float = 512

@export var bg_combine_duration : float = 1

@export var text_header_label : RichTextLabel

@export var clear_time_label : RichTextLabel

@export var damage_taken_label : RichTextLabel

@export var fragment_ratio_label : RichTextLabel

@export var mage_fragments_label : RichTextLabel

@export var dragon_fragments_label : RichTextLabel

@export var min_fragments_label : RichTextLabel

@export var medal_message_label : RichTextLabel

@export var retry_button_label : RichTextLabel

@export var menu_button_label : RichTextLabel

var bg_combine_lerp : float = 0

var results_mode : int = 0

func _physics_process(delta):
	follow_camera()
	match results_mode:
		0:
			update_bg_combine_lerp(delta)
		_:
			pass

func follow_camera():
	global_position = (get_viewport().get_camera_2d().global_position + combine_point_offset)

func update_bg_combine_lerp(delta : float):
	if (bg_combine_lerp < 1):
		bg_combine_lerp = move_toward(bg_combine_lerp, 1, delta / bg_combine_duration)
		blue_bg.position.x = lerp(-screen_width, 0.0, bg_combine_lerp)
		orange_bg.position.x = lerp(screen_width, 0.0, bg_combine_lerp)
	else:
		results_mode = 1

func on_level_complete():
	set_visible(true)
	set_process_mode(PROCESS_MODE_ALWAYS)
