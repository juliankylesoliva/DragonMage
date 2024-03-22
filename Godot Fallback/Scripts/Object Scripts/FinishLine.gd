extends AnimatedSprite2D

class_name FinishLine

@export var starting_z_index : int = 4

@export var broken_z_index : int = 3

signal level_finished

var is_tape_broken : bool = false

func _ready():
	z_index = starting_z_index

func _on_area_2d_body_entered(body):
	if (!is_tape_broken):
		if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
			is_tape_broken = true
			z_index = broken_z_index
			play("Break")
			PauseHandler.enable_pausing(false)
			level_finished.emit()
