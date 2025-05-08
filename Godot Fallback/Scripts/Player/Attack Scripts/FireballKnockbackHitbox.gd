extends KnockbackHitbox

class_name FireballKnockbackHitbox

@export var enemy_defeat_knockback_multiplier : float = 1.5

@export var reflected_speed_boost : float = 1.25

@export var reflected_knockback_effect_radius : float = 20

@export var max_reflects : int = 2

var is_reflected : bool = false

var current_reflects : int = 0

func _on_body_entered(body):
	if (body is Breakable):
		do_break_object(body)
	elif (is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		var player_temp : PlayerHub = null
		
		for child in body.get_children():
			if (child is PlayerHub):
				player_temp = (child as PlayerHub)
				break
		
		if (player_temp != null):
			var direction = (body.global_position.x - global_position.x)
			direction = (1.0 if direction >= 0 else -1.0)
			if (player_temp.damage.take_damage(direction) or player_temp.damage.is_player_guarding()):
				destroy_projectile()
			elif (is_reflected and player_temp.damage.is_player_parrying()):
				reflect_projectile()
			else:
				pass
	elif (!is_reflected and body is Boss):
		do_damage_boss(body)
	elif !is_reflected and (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		defeat_enemy(body)
	elif (!is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "EnemyProjectile"):
		destroy_enemy_projectile(body)
	else:
		pass

func do_break_object(body):
	if ((body as Breakable).break_object(self)):
		hit.emit()

func do_damage_boss(body):
	if ((body as Boss).damage_boss(damage_type, damage_strength, (get_parent() as RigidBody2D).linear_velocity * enemy_defeat_knockback_multiplier)):
		hit.emit()
		EffectFactory.get_effect("FireImpact", body.global_position)

func defeat_enemy(body):
	if (body is Enemy):
		var enemy : Enemy = (body as Enemy)
		if (enemy.defeat_enemy(damage_type, true)):
			hit.emit()
			EffectFactory.get_effect("FireImpact", body.global_position)
			enemy.body.velocity += (Vector2.RIGHT * (get_parent() as RigidBody2D).linear_velocity.x * enemy_defeat_knockback_multiplier)
		elif (enemy.can_reflect_projectiles):
			reflect_projectile()
		else:
			pass

func reflect_projectile():
	if (current_reflects < max_reflects):
		is_reflected = !is_reflected
		EffectFactory.get_effect("ReflectImpact", global_position)
		(self.get_parent() as RigidBody2D).linear_velocity.x *= -abs(reflected_speed_boost)
		(self.get_parent() as SelfDestructTimer).refresh_lifetime()
		for child in self.get_parent().get_children():
			if (child is AnimatedSprite2D):
				var temp_parent_sprite : AnimatedSprite2D = (child as AnimatedSprite2D)
				temp_parent_sprite.flip_h = !temp_parent_sprite.flip_h
				break
		SoundFactory.play_sound_by_name("attack_reflect", global_position, 0, 1, "SFX")
		current_reflects += 1
		collision_shape.shape.radius = (reflected_knockback_effect_radius if is_reflected else knockback_effect_radius)
	else:
		EffectFactory.get_effect("ReflectImpact", global_position)
		SoundFactory.play_sound_by_name("attack_reflect", global_position, 0, 1, "SFX")
		destroy_projectile()

func destroy_projectile():
	EffectFactory.get_effect("FireImpact", global_position)
	SoundFactory.play_sound_by_name("attack_draelyn_bump", global_position, 4, 1, "SFX")
	self.get_parent().queue_free()

func destroy_enemy_projectile(body):
	if (body is EnemyProjectile and (body as EnemyProjectile).damage_type == "FIRE" and !(body as EnemyProjectile).is_reflected):
		(body as EnemyProjectile).destroy_projectile()
