extends KnockbackHitbox

class_name InvincibilityShieldHitbox

func _on_body_entered(body):
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		defeat_enemy(body)
	elif (body.has_meta("Tag") and body.get_meta("Tag") == "EnemyProjectile"):
		destroy_enemy_projectile(body)
	elif (body.has_meta("Tag") and body.get_meta("Tag") == "PlayerProjectile"):
		reflect_player_projectile(body)
	else:
		pass

func defeat_enemy(body):
	if (body is Enemy):
		var enemy : Enemy = (body as Enemy)
		if (enemy.defeat_enemy(damage_type)):
			#hit.emit()
			EffectFactory.get_effect("InvincibilityShieldImpact", body.global_position)
			return

func destroy_enemy_projectile(body):
	if (body is EnemyProjectile and !(body as EnemyProjectile).is_reflected):
		(body as EnemyProjectile).reflect_projectile()

func reflect_player_projectile(body):
	for child in body.get_children():
			if (child is FireballKnockbackHitbox):
				var temp_fireball : FireballKnockbackHitbox = (child as FireballKnockbackHitbox)
				if (temp_fireball.is_reflected):
					temp_fireball.reflect_projectile()
				break
