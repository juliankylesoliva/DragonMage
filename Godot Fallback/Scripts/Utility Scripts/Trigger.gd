extends Area2D

class_name Trigger

signal trigger_entered

signal trigger_exited

@export var shape : CollisionShape2D

func _ready():
	body_entered.connect(activate_trigger_entered)
	body_exited.connect(activate_trigger_exited)

func activate_trigger_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				trigger_entered.emit()
				return

func activate_trigger_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				trigger_exited.emit()
				return
