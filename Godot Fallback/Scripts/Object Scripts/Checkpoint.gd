extends Node2D

class_name Checkpoint

@export var level_origin : Level

@export var room_origin : Room

@export var subsequent_checkpoints : Array[Checkpoint]

@export var sprite : AnimatedSprite2D

@export var audio : AudioStreamPlayer

var is_activated : bool = false

signal checkpoint_activated

func _process(_delta):
	if (sprite.animation == "Activation" and !sprite.is_playing()):
		sprite.play("ActiveLoop")

func activate_subsequent_checkpoints():
	if (!is_activated):
		for checkpoint in subsequent_checkpoints:
			checkpoint.is_activated = true
			checkpoint.checkpoint_activated.emit()

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		activate()

func activate():
	if (!is_activated):
		is_activated = true
		sprite.play("Activation")
		audio.play()
		CheckpointHandler.save_checkpoint(level_origin.get_given_room_index(room_origin), self.global_position, level_origin.mage_fragments, level_origin.dragon_fragments, level_origin.fragment_array, level_origin.get_magical_scale_status(), level_origin.get_draconic_scale_status(), level_origin.get_balanced_scale_status(), level_origin.enemy_array)
		self.checkpoint_activated.emit()
		activate_subsequent_checkpoints()
