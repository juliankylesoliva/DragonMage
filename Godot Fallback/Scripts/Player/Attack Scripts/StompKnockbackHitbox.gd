extends KnockbackHitbox

class_name StompKnockbackHitbox

var enemy_to_stomp : Enemy

var boss_to_stomp : Boss

func _on_body_entered(body):
	if (body is Boss):
		boss_to_stomp = (body as Boss)
	elif ((body.has_meta("Tag") and body.get_meta("Tag") == "Enemy")):
		set_enemy_to_stomp(body)
	else:
		pass

func _on_body_exited(body):
	if (body is Boss):
		boss_to_stomp = null
	elif ((body.has_meta("Tag") and body.get_meta("Tag") == "Enemy")):
		enemy_to_stomp = null
	else:
		pass

func set_enemy_to_stomp(body):
	for child in body.get_children():
			if (child is Enemy):
				enemy_to_stomp = (child as Enemy)
