extends KnockbackHitbox

class_name BlastJumpKnockbackHitbox

func _on_body_entered(body):
	if (body is Breakable):
		do_break_object(body)

func do_break_object(body):
	(body as Breakable).break_object(self)
