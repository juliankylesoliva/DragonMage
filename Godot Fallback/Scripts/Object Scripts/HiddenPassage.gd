extends TileMap

class_name HiddenPassage

@export var alpha_change_rate : float = 5

@export var clear_alpha : float = 0

@export var solid_alpha : float = 1

var is_player_in_trigger : bool = false

var current_alpha : float = 1

func _process(delta):
	if (is_player_in_trigger):
		current_alpha = move_toward(current_alpha, 0, delta * alpha_change_rate)
	else:
		current_alpha = move_toward(current_alpha, 1, delta * alpha_change_rate)
	
	set_layer_modulate(0, Color(1, 1, 1, current_alpha))

func _on_rigid_body_2d_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_in_trigger = true

func _on_rigid_body_2d_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_in_trigger = false
