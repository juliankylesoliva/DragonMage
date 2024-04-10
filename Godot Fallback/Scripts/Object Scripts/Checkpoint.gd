extends Node2D

class_name Checkpoint

@export var level_origin : Level

var is_activated : bool = false

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		if (!is_activated):
			is_activated = true
			CheckpointHandler.save_checkpoint(level_origin.get_current_room_index(), self.global_position, level_origin.mage_fragments, level_origin.dragon_fragments, level_origin.fragment_array)
