extends KnockbackHitbox

class_name FireballKnockbackHitbox

func _on_body_entered(body):
	if (body is Breakable):
		do_break_object(body)

func do_break_object(body):
	if ((body as Breakable).break_object(self)):
		hit.emit()
