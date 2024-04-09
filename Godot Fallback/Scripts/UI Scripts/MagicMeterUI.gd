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

var hub : PlayerHub = null

func _ready():
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	refresh_meter_ui()

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
