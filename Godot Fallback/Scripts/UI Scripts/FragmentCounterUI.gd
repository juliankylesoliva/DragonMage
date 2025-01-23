extends Node2D

class_name FragmentCounterUI

@export var player_node : Node

@export var level_ref : Level

@export var rich_text_label : RichTextLabel

@export var text_template : String = "[right][font_size=24]~[color=#443482]{mage}[color=white]:[color=#cf7a30]{dragon}[color=white]-\n[font_size=16][{magical_scale}{draconic_scale}{balanced_scale}]"

@export var magical_scale_hud_blank : String

@export var magical_scale_hud_collected : String

@export var draconic_scale_hud_blank : String

@export var draconic_scale_hud_collected : String

@export var balanced_scale_hud_blank : String

@export var balanced_scale_hud_collected : String

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
		var magical_scale_result : String = ("-" if level_ref.magical_scale == null else magical_scale_hud_collected if level_ref.magical_scale.is_collected else magical_scale_hud_blank)
		var draconic_scale_result : String = ("-" if level_ref.draconic_scale == null else draconic_scale_hud_collected if level_ref.draconic_scale.is_collected else draconic_scale_hud_blank)
		var balanced_scale_result : String = ("-" if level_ref.balanced_scale == null else balanced_scale_hud_collected if level_ref.balanced_scale.is_collected else balanced_scale_hud_blank)
		rich_text_label.text = text_template.format({"mage" : level_ref.mage_fragments, "dragon" : level_ref.dragon_fragments, "magical_scale" : magical_scale_result, "draconic_scale" : draconic_scale_result, "balanced_scale" : balanced_scale_result})
	check_alpha_fade(_delta)

func check_alpha_fade(delta):
	current_fade_y_threshold = calculate_fade_y_threshold()
	if (hub.char_body.global_position.y < current_fade_y_threshold):
		modulate.a = move_toward(modulate.a, target_alpha, delta / alpha_fade_time)
	else:
		modulate.a = move_toward(modulate.a, 1.0, delta / alpha_fade_time)

func calculate_fade_y_threshold():
	return (get_viewport().get_camera_2d().get_screen_center_position().y + y_fade_offset_from_center)
