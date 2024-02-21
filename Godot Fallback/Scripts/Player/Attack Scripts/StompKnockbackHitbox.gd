extends KnockbackHitbox

class_name StompKnockbackHitbox

var enemy_to_stomp : Enemy

func _on_body_entered(body):
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		set_enemy_to_stomp(body)

func _on_body_exited(body):
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		enemy_to_stomp = null

func set_enemy_to_stomp(body):
	for child in body.get_children():
			if (child is Enemy):
				enemy_to_stomp = (child as Enemy)
