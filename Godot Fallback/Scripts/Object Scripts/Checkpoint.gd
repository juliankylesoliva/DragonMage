extends Node2D

class_name Checkpoint

@export var level_origin : Level

@export var subsequent_checkpoints : Array[Checkpoint]

@export var sprite : AnimatedSprite2D

@export var audio : AudioStreamPlayer

var is_activated : bool = false

func _process(_delta):
	if (sprite.animation == "Activation" and !sprite.is_playing()):
		sprite.play("ActiveLoop")

func activate_subsequent_checkpoints():
	for checkpoint in subsequent_checkpoints:
		checkpoint.is_activated = true

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		if (!is_activated):
			is_activated = true
			sprite.play("Activation")
			audio.play()
			CheckpointHandler.save_checkpoint(level_origin.get_current_room_index(), self.global_position, level_origin.mage_fragments, level_origin.dragon_fragments, level_origin.fragment_array)
			activate_subsequent_checkpoints()
