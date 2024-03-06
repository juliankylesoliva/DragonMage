extends CameraFollow

class_name FragmentCounterUI

@export var player_node : Node

@export var level_ref : Level

@export var rich_text_label : RichTextLabel

@export var text_template : String = "[right][font_size=24]{current}[font_size=16]/{min}\n[[color=#5941a9]{mage}[color=white]:[color=#f09a59]{dragon}[color=white]]"

@export_range(0, 1) var player_collision_alpha : float = 0.25

@export var player_collision_alpha_delta_multiplier : float = 5

var hub : PlayerHub

var is_player_colliding : bool = false

func _ready():
	super._ready()
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(delta):
	super._process(delta)
	uniform_process(delta)

func _physics_process(delta):
	super._physics_process(delta)
	uniform_process(delta)

func uniform_process(delta):
	update_modulate_alpha(delta)
	if (level_ref != null):
		rich_text_label.text = text_template.format({"current" : level_ref.get_total_fragments(), "min" : level_ref.min_fragment_req_for_medal, "mage" : level_ref.mage_fragments, "dragon" : level_ref.dragon_fragments})

func update_modulate_alpha(delta : float):
	modulate.a = move_toward(modulate.a, player_collision_alpha if is_player_colliding or hub.char_body.global_position.y < global_position.y else 1.0, delta * player_collision_alpha_delta_multiplier)

func _on_area_2d_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_colliding = true

func _on_area_2d_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_colliding = false
