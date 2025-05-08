extends Area2D

class_name DoorKey

@export var sprite : AnimatedSprite2D

@export var audio : AudioStreamPlayer2D

@export var floating_amplitude : int = 2

@export var floating_speed_scale : float = 1

var is_collected : bool = false

var current_theta : float = 0

func _process(delta):
	if (!is_collected):
		current_theta += (floating_speed_scale * delta)
		if (current_theta > (PI * 2)):
			current_theta -= (PI * 2)
		sprite.position.y = (floating_amplitude * sin(current_theta))

func _on_body_entered(body):
	if (!is_collected and sprite.visible and body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				var hub : PlayerHub = (child as PlayerHub)
				if (!hub.damage.is_player_damaged()):
					hub.inventory.add_key()
					audio.play()
					sprite.visible = false
					is_collected = true
					set_deferred("monitoring", false)
				break

func force_collect():
	if (!is_collected):
		sprite.visible = false
		is_collected = true
		set_deferred("monitoring", false)
