extends Node2D

class_name FragmentCounterUI

@export var player_node : Node

@export var level_ref : Level

@export var rich_text_label : RichTextLabel

@export var text_template : String = "[right][color={medal}][font_size=24]{current}[font_size=16][color=white]/[color={status}]{min}\n[color=white][[color=#5941a9]{mage}[color=white]:[color=#f09a59]{dragon}[color=white]]"

@export var blue_hex : String = "#ffffff"

@export var orange_hex : String = "#ffffff"

@export var gray_hex : String = "#ffffff"

@export var red_hex : String = "#ffffff"

@export var y_fade_offset_from_center : float = -96

@export var alpha_fade_time : float = 0.25

@export_range(0, 1) var target_alpha : float = 0.5

var hub : PlayerHub

var current_fade_y_threshold : float = 0

func _ready():
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	if (level_ref != null):
		rich_text_label.text = text_template.format({"medal" : (blue_hex if level_ref.get_medal_type() == "MAGIC" else orange_hex if level_ref.get_medal_type() == "DRAGON" else gray_hex if level_ref.get_medal_type() == "BALANCE" else "white"), "current" : level_ref.get_total_fragments(), "status" : ("white" if level_ref.is_medal_possible() else red_hex), "min" : level_ref.min_fragment_req_for_medal, "mage" : level_ref.mage_fragments, "dragon" : level_ref.dragon_fragments, "deaths" : CheckpointHandler.death_counter})
	check_alpha_fade(_delta)

func check_alpha_fade(delta):
	current_fade_y_threshold = calculate_fade_y_threshold()
	if (hub.char_body.global_position.y < current_fade_y_threshold):
		modulate.a = move_toward(modulate.a, target_alpha, delta / alpha_fade_time)
	else:
		modulate.a = move_toward(modulate.a, 1.0, delta / alpha_fade_time)

func calculate_fade_y_threshold():
	return (get_viewport().get_camera_2d().get_screen_center_position().y + y_fade_offset_from_center)
