extends Node2D

class_name FragmentCounterUI

@export var player_node : Node

@export var level_ref : Level

@export var rich_text_label : RichTextLabel

@export var text_template : String = "[right][font_size=24]{current}[font_size=16]/{min}\n[[color=#5941a9]{mage}[color=white]:[color=#f09a59]{dragon}[color=white]]"

var hub : PlayerHub

func _ready():
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	if (level_ref != null):
		rich_text_label.text = text_template.format({"current" : level_ref.get_total_fragments(), "min" : level_ref.min_fragment_req_for_medal, "mage" : level_ref.mage_fragments, "dragon" : level_ref.dragon_fragments})
