extends RigidBody2D

class_name EnemyProjectile

@export var projectile_sprite : AnimatedSprite2D

@export var move_speed : float = 3

@export var impact_effect_name : String = "DragoonProjectileImpact"

@export var destroy_sound_name : String = "enemy_dragoon_projectile_destroy"

var is_moving_right : bool = false

func setup(enemy_source : Enemy):
	linear_velocity = (Vector2.RIGHT * enemy_source.movement.get_facing_value() * move_speed)
	is_moving_right = (enemy_source.movement.get_facing_value() >= 0)
	projectile_sprite.flip_h = !is_moving_right

func destroy_projectile():
	EffectFactory.get_effect(impact_effect_name, global_position)
	SoundFactory.play_sound_by_name(destroy_sound_name, global_position, 0, 1, "SFX")
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	hit_check(body)

func hit_check(body):
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				var player_temp : PlayerHub = (child as PlayerHub)
				var direction = (body.global_position.x - global_position.x)
				direction = (1.0 if direction >= 0 else -1.0)
				player_temp.damage.take_damage(direction)
				break
		destroy_projectile()
