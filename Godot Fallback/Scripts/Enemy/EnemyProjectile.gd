extends CharacterBody2D

class_name EnemyProjectile

@export var audio : AudioStreamPlayer2D

@export var projectile_sprite : AnimatedSprite2D

@export var move_speed : float = 3

@export var jump_speed : float = 0

@export var gravity_scale : float = 0

@export var floor_bounce_modifier : float = 0

@export var wall_bounce_modifier : float = 0

@export var destroy_on_wall_bounce : bool = false

@export var bounce_limit : int = 0

@export var reflected_speed_boost : float = 2

@export var max_reflects : int = 3

@export_enum("MAGIC", "FIRE") var damage_type : String = "FIRE"

@export var impact_effect_name : String = "DragoonProjectileImpact"

@export var reflect_impact_effect_name : String = "ReflectImpact"

@export var destroy_sound_name : String = "enemy_dragoon_projectile_destroy"

@export var reflect_sound_name : String = "attack_reflect"

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_moving_right : bool = false

var is_reflected = false

var saved_velocity : Vector2

var bounce_count : int = 0

var current_reflects : int = 0

func _physics_process(_delta):
	if ((is_on_floor() or is_on_ceiling()) and saved_velocity.y != 0):
		if (bounce_count < bounce_limit):
			bounce_count += 1
			velocity.y = (-saved_velocity.y * abs(floor_bounce_modifier))
		else:
			destroy_projectile()
			return
	
	if (is_on_wall() and saved_velocity.x != 0):
		if (destroy_on_wall_bounce):
			destroy_projectile()
			return
		
		if (bounce_count < bounce_limit):
			bounce_count += 1
			velocity.x = (-saved_velocity.x * abs(wall_bounce_modifier))
			is_reflected = !is_reflected
		else:
			destroy_projectile()
			return
	
	saved_velocity = velocity
	move_and_slide()
	velocity += (Vector2.DOWN * get_gravity_delta(_delta))

func boss_setup(boss_source : Boss):
	velocity = Vector2(boss_source.get_facing_value() * move_speed, -jump_speed)
	is_moving_right = (boss_source.get_facing_value() >= 0)
	projectile_sprite.flip_h = !is_moving_right

func setup(enemy_source : Enemy):
	velocity = (Vector2.RIGHT * enemy_source.movement.get_facing_value() * move_speed)
	is_moving_right = (enemy_source.movement.get_facing_value() >= 0)
	projectile_sprite.flip_h = !is_moving_right

func destroy_projectile():
	EffectFactory.get_effect(impact_effect_name, global_position, scale.x)
	SoundFactory.play_sound_by_name(destroy_sound_name, global_position, 0, audio.pitch_scale if audio != null else 1.0, "SFX")
	queue_free()

func reflect_projectile():
	if (current_reflects < max_reflects):
		is_reflected = !is_reflected
		EffectFactory.get_effect(reflect_impact_effect_name, global_position)
		velocity.x *= -abs(reflected_speed_boost)
		is_moving_right = !is_moving_right
		projectile_sprite.flip_h = !is_moving_right
		SoundFactory.play_sound_by_name(reflect_sound_name, global_position, 0, 1, "SFX")
		current_reflects += 1
	else:
		EffectFactory.get_effect(reflect_impact_effect_name, global_position)
		SoundFactory.play_sound_by_name(reflect_sound_name, global_position, 0, 1, "SFX")
		destroy_projectile()

func get_gravity_delta(delta : float):
	return (base_gravity * gravity_scale * delta)

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
			elif (!is_reflected and player_temp.damage.is_player_parrying() and current_reflects < max_reflects):
				reflect_projectile()
			else:
				pass
	elif (is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
		var enemy_temp : Enemy = null
		
		if (body is Enemy):
			enemy_temp = (body as Enemy)
		
		if (enemy_temp != null):
			if (enemy_temp.defeat_enemy("PARRY", true)):
				destroy_projectile()
			elif (enemy_temp.can_reflect_projectiles):
				reflect_projectile()
			else:
				destroy_projectile()
	elif (is_reflected and body.has_meta("Tag") and body.get_meta("Tag") == "EnemyProjectile"):
		if (body is EnemyProjectile and !(body as EnemyProjectile).is_reflected):
			(body as EnemyProjectile).destroy_projectile()
	else:
		pass
