extends CharacterBody2D

class_name EnemyProjectile

@export var projectile_sprite : AnimatedSprite2D

@export var move_speed : float = 3

@export var reflected_speed_boost : float = 2

@export var impact_effect_name : String = "DragoonProjectileImpact"

@export var reflect_impact_effect_name : String = "ReflectImpact"

@export var destroy_sound_name : String = "enemy_dragoon_projectile_destroy"

@export var reflect_sound_name : String = "attack_reflect"

var is_moving_right : bool = false

var is_reflected = false

func _physics_process(_delta):
	move_and_slide()

func setup(enemy_source : Enemy):
	velocity = (Vector2.RIGHT * enemy_source.movement.get_facing_value() * move_speed)
	is_moving_right = (enemy_source.movement.get_facing_value() >= 0)
	projectile_sprite.flip_h = !is_moving_right

func destroy_projectile():
	EffectFactory.get_effect(impact_effect_name, global_position)
	SoundFactory.play_sound_by_name(destroy_sound_name, global_position, 0, 1, "SFX")
	queue_free()

func reflect_projectile():
	is_reflected = true
	EffectFactory.get_effect(reflect_impact_effect_name, global_position)
	velocity.x *= -abs(reflected_speed_boost)
	is_moving_right = !is_moving_right
	projectile_sprite.flip_h = !is_moving_right
	SoundFactory.play_sound_by_name(reflect_sound_name, global_position, 0, 1, "SFX")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	hit_check(body)

func hit_check(body):
	if (!is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
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
			elif (!is_reflected and player_temp.damage.is_player_parrying()):
				reflect_projectile()
			else:
				pass
	elif (is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		var enemy_temp : Enemy = null
		
		for child in body.get_children():
			if (child is Enemy):
				enemy_temp = (child as Enemy)
				break
		
		if (enemy_temp != null):
			enemy_temp.defeat_enemy("PARRY")
			destroy_projectile()
	elif (is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "EnemyProjectile"):
		if (body is EnemyProjectile and !(body as EnemyProjectile).is_reflected):
			(body as EnemyProjectile).destroy_projectile()
	else:
		pass
