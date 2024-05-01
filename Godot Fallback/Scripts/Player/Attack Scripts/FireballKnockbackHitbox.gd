extends KnockbackHitbox

class_name FireballKnockbackHitbox

@export var enemy_defeat_knockback_multiplier : float = 1.5

func _on_body_entered(body):
	if (body is Breakable):
		do_break_object(body)
	elif (body is Boss):
		do_damage_boss(body)
	elif (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		defeat_enemy(body)
	elif (body.has_meta("Tag") and body.get_meta("Tag") == "EnemyProjectile"):
		destroy_enemy_projectile(body)
	else:
		pass

func do_break_object(body):
	if ((body as Breakable).break_object(self)):
		hit.emit()

func do_damage_boss(body):
	if ((body as Boss).damage_boss(damage_type, damage_strength, (get_parent() as RigidBody2D).linear_velocity * enemy_defeat_knockback_multiplier)):
		hit.emit()

func defeat_enemy(body):
	for child in body.get_children():
		if (child is Enemy):
			var enemy : Enemy = (child as Enemy)
			if (enemy.defeat_enemy(damage_type)):
				hit.emit()
				EffectFactory.get_effect("FireImpact", body.global_position)
				enemy.body.velocity += (Vector2.RIGHT * (get_parent() as RigidBody2D).linear_velocity.x * enemy_defeat_knockback_multiplier)
				return

func destroy_enemy_projectile(body):
	if (body is EnemyProjectile and (body as EnemyProjectile).damage_type == "FIRE" and !(body as EnemyProjectile).is_reflected):
		(body as EnemyProjectile).destroy_projectile()
