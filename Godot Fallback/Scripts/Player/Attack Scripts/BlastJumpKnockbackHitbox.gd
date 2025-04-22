extends KnockbackHitbox

class_name BlastJumpKnockbackHitbox

@export var enemy_defeat_knockback_multiplier : float = 1.5

var player_body : CharacterBody2D

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
	if ((body as Boss).damage_boss(damage_type, damage_strength, player_body.velocity * enemy_defeat_knockback_multiplier)):
		hit.emit()
		EffectFactory.get_effect("MagicImpact", body.global_position)

func defeat_enemy(body):
	if (body is Enemy):
		var enemy : Enemy = (body as Enemy)
		if (enemy.defeat_enemy(damage_type)):
			hit.emit()
			EffectFactory.get_effect("MagicImpact", body.global_position)
			enemy.body.velocity += (Vector2.RIGHT * player_body.velocity.x * enemy_defeat_knockback_multiplier)
			return

func destroy_enemy_projectile(body):
	if (body is EnemyProjectile and (body as EnemyProjectile).damage_type == "MAGIC" and !(body as EnemyProjectile).is_reflected):
		(body as EnemyProjectile).destroy_projectile()
