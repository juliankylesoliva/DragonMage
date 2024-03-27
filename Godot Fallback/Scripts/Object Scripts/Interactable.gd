extends Node2D

class_name Interactable

@export var button_prompt : RichTextLabel

var player : PlayerHub

func interact(_hub : PlayerHub):
	pass

func on_player_entered():
	pass

func on_player_exited():
	pass

func _on_body_entered(body : Node2D):
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				player = (child as PlayerHub)
				break
		
		if (player != null):
			button_prompt.set_visible(true)
			player.interaction.set_interactable_ref(self)
			on_player_entered()

func _on_body_exited(body : Node2D):
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				player = (child as PlayerHub)
				break
		
		if (player != null):
			button_prompt.set_visible(false)
			player.interaction.unset_interactable_ref(self)
			player = null
			on_player_exited()
