extends Node2D

class_name MagicMeterUI

@export var player_node : Node

@export var fill_sprite : AnimatedSprite2D

@export var ability_icon : Sprite2D

@export var percent_label : RichTextLabel

@export_color_no_alpha var normal_fill_color : Color = Color.WHITE

@export_color_no_alpha var maxed_fill_color : Color = Color.WHITE

@export var zero_x_offset : float = -94

@export var near_zero_x_offset : float = -93

@export var full_x_offset : float = 0

@export_range(0, 1) var attack_unavailable_alpha : float = 0.5

@export var y_fade_offset_from_center : float = -96

@export var alpha_fade_time : float = 0.25

@export_range(0, 1) var target_alpha : float = 0.5

var hub : PlayerHub = null

var current_fade_y_threshold : float = 0

func _ready():
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	refresh_meter_ui()
	check_alpha_fade(_delta)

func refresh_meter_ui():
	if (!hub.fairy.is_using_fairy or !hub.fairy.enable_abilities):
		return
	
	var current_ability : Attack = hub.fairy.get_selected_ability()
	if (current_ability != null):
		ability_icon.modulate.a = (attack_unavailable_alpha if !current_ability.can_use_attack() else 1.0)
	
	if (!hub.fairy.is_magic_empty()):
		if (hub.fairy.is_magic_full()):
			percent_label.modulate = maxed_fill_color
			fill_sprite.modulate = maxed_fill_color
			fill_sprite.set_animation("Flashing")
		else:
			percent_label.modulate = normal_fill_color
			fill_sprite.modulate = normal_fill_color
			fill_sprite.set_animation("Steady")
		fill_sprite.offset.x = ((near_zero_x_offset - full_x_offset) * (1 - hub.fairy.get_current_magic_portion()))
	else:
		fill_sprite.offset.x = zero_x_offset
	
	percent_label.text = ("{num}%".format({"num" : (hub.fairy.current_magic as int)}))

func check_alpha_fade(delta):
	current_fade_y_threshold = calculate_fade_y_threshold()
	if (hub.char_body.global_position.y < current_fade_y_threshold):
		modulate.a = move_toward(modulate.a, target_alpha, delta / alpha_fade_time)
	else:
		modulate.a = move_toward(modulate.a, 1.0, delta / alpha_fade_time)

func calculate_fade_y_threshold():
	return (get_viewport().get_camera_2d().get_screen_center_position().y + y_fade_offset_from_center)
