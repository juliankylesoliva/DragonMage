extends Node2D

class_name LevelIntroScreen

signal intro_finished

@export var screen_width : float = 512

@export var bg_combine_duration : float = 0.5

@export var blue_bg : Sprite2D

@export var orange_bg : Sprite2D

@export var chapter_char : String = "#"

@export var section_char : String = "#"

@export var chapter_section_format : String = "Chapter {chapter}-{section}"

@export var level_name_left : String = "Title L"

@export var level_name_right : String = "Title R"

@export var left_name_format : String = "[left][color=#5941a9]{first}[color=white]{rest}"

@export var right_name_format : String = "[right][color=#f09a59]{first}[color=white]{rest}"

@export var subtitle_text : String = "Subtitle"

@export var subtitle_format : String = "[right]~ {sub} -"

@export var start_message_format : String = "[center]Go for it, {name}!"

@export var mage_name_image : String = "[img=93x42]res://Sprites/UI/MagliNameSprite.png[/img]"

@export var dragon_name_image : String = "[img=147x21]res://Sprites/UI/DraelynNameSprite.png[/img]"

@export var chapter_header_label : RichTextLabel

@export var level_name_left_label : RichTextLabel

@export var level_name_right_label : RichTextLabel

@export var level_subtitle_label : RichTextLabel

@export var start_message_label : RichTextLabel

func _ready():
	PauseHandler.game_paused.connect(hide_level_name_on_pause)

func do_level_intro():
	slide_from_offset(blue_bg, Vector2.LEFT * screen_width, bg_combine_duration)
	slide_from_offset(orange_bg, Vector2.RIGHT * screen_width, bg_combine_duration)
	await get_tree().create_timer(0.25).timeout
	chapter_header_label.text = chapter_section_format.format({"chapter" : chapter_char.substr(0, 1), "section" : section_char.substr(0, 1)})
	slide_control_from_offset(chapter_header_label, Vector2.LEFT * screen_width, bg_combine_duration)
	await get_tree().create_timer(0.25).timeout
	level_name_left_label.text = left_name_format.format({"first" : level_name_left.substr(0, 1), "rest" : level_name_left.substr(1)})
	level_name_right_label.text = right_name_format.format({"first" : level_name_right.substr(0, 1), "rest" : level_name_right.substr(1)})
	slide_control_from_offset(level_name_left_label, Vector2.LEFT * screen_width, bg_combine_duration)
	slide_control_from_offset(level_name_right_label, Vector2.RIGHT * screen_width, bg_combine_duration)
	await get_tree().create_timer(0.25).timeout
	level_subtitle_label.text = subtitle_format.format({"sub" : subtitle_text})
	slide_control_from_offset(level_subtitle_label, Vector2.RIGHT * screen_width, bg_combine_duration)
	await get_tree().create_timer(0.5).timeout
	start_message_label.text = start_message_format.format({"name" : (dragon_name_image if FormSelectionHelper.is_dragon_selected() else mage_name_image)})
	slide_control_from_offset(start_message_label, Vector2.LEFT * screen_width, bg_combine_duration)
	await get_tree().create_timer(1.5).timeout
	slide_control_to_offset(start_message_label, Vector2.RIGHT * screen_width, bg_combine_duration)
	await get_tree().create_timer(0.5).timeout
	slide_to_offset(blue_bg, Vector2.LEFT * screen_width, bg_combine_duration)
	slide_to_offset(orange_bg, Vector2.RIGHT * screen_width, bg_combine_duration)
	intro_finished.emit()
	await get_tree().create_timer(0.75).timeout
	slide_control_to_offset(chapter_header_label, Vector2.LEFT * screen_width, bg_combine_duration)
	slide_control_to_offset(level_name_left_label, Vector2.LEFT * screen_width, bg_combine_duration)
	slide_control_to_offset(level_name_right_label, Vector2.RIGHT * screen_width, bg_combine_duration)
	slide_control_to_offset(level_subtitle_label, Vector2.RIGHT * screen_width, bg_combine_duration)

func slide_from_offset(node : Node2D, offset : Vector2, time : float):
	var target_position : Vector2 = node.position
	var lerp_value : float = 0
	node.set_visible(true)
	while (lerp_value < 1):
		lerp_value = move_toward(lerp_value, 1, get_physics_process_delta_time() / time)
		node.position.x = lerp(target_position.x + offset.x, target_position.x, lerp_value)
		node.position.y = lerp(target_position.y + offset.y, target_position.y, lerp_value)
		await get_tree().process_frame

func slide_to_offset(node : Node2D, offset : Vector2, time : float):
	var target_position : Vector2 = (node.position + offset)
	var lerp_value : float = 0
	while (lerp_value < 1):
		lerp_value = move_toward(lerp_value, 1, get_physics_process_delta_time() / time)
		node.position.x = lerp(target_position.x - offset.x, target_position.x, lerp_value)
		node.position.y = lerp(target_position.y - offset.y, target_position.y, lerp_value)
		await get_tree().process_frame
	node.set_visible(false)

func slide_control_from_offset(node : Control, offset : Vector2, time : float):
	var target_position : Vector2 = node.position
	var lerp_value : float = 0
	node.set_visible(true)
	while (lerp_value < 1):
		lerp_value = move_toward(lerp_value, 1, get_physics_process_delta_time() / time)
		node.position.x = lerp(target_position.x + offset.x, target_position.x, lerp_value)
		node.position.y = lerp(target_position.y + offset.y, target_position.y, lerp_value)
		await get_tree().process_frame

func slide_control_to_offset(node : Control, offset : Vector2, time : float):
	var target_position : Vector2 = (node.position + offset)
	var lerp_value : float = 0
	while (lerp_value < 1):
		lerp_value = move_toward(lerp_value, 1, get_physics_process_delta_time() / time)
		node.position.x = lerp(target_position.x - offset.x, target_position.x, lerp_value)
		node.position.y = lerp(target_position.y - offset.y, target_position.y, lerp_value)
		await get_tree().process_frame
	node.set_visible(false)

func hide_level_name_on_pause():
	chapter_header_label.set_visible(false)
	level_name_left_label.set_visible(false)
	level_name_right_label.set_visible(false)
	level_subtitle_label.set_visible(false)
