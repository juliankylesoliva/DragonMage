extends PathFollow2D

class_name ImpostorSwordProjectile

@export var sprite : AnimatedSprite2D

@export var travel_time : float = 2

@export var player_collision_effect_name : String = "EnemyContactImpact"

@export var player_collision_sound_name : String = "enemy_contact_impact"

@export var reflect_impact_effect_name : String = "ReflectImpact"

@export var reflect_sound_name : String = "attack_reflect"

var is_moving : bool = false

var is_reflected : bool = false

var target_ratio : float = 0

func _physics_process(delta):
	if (!is_moving):
		return
	
	if (progress_ratio != target_ratio):
		progress_ratio = move_toward(progress_ratio, target_ratio, delta / travel_time)
		if (progress_ratio == target_ratio):
			self.queue_free()
	

func start_moving(is_reverse : bool, is_facing_right : bool):
	if (!is_moving):
		self.position = Vector2.ZERO
		progress_ratio = (1.0 if is_reverse else 0.0)
		target_ratio = (0.0 if is_reverse else 1.0)
		sprite.flip_h = (is_reverse == is_facing_right)
		is_moving = true

func reflect_projectile():
	if (is_moving and !is_reflected):
		is_reflected = true
		EffectFactory.get_effect(reflect_impact_effect_name, global_position)
		SoundFactory.play_sound_by_name(reflect_sound_name, global_position, 0, 1, "SFX")
		sprite.flip_h = !sprite.flip_h
		target_ratio = (1.0 if target_ratio <= 0.0 else 0.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		var player_temp : PlayerHub = null
		
		for child in body.get_children():
			if (child is PlayerHub):
				player_temp = (child as PlayerHub)
				break
		
		if (player_temp != null):
			var direction = (body.global_position.x - global_position.x)
			direction = (1.0 if direction >= 0 else -1.0)
			if (player_temp.damage.take_damage(direction) or player_temp.damage.is_player_guarding()):
				EffectFactory.get_effect(player_collision_effect_name, player_temp.char_body.global_position)
				SoundFactory.play_sound_by_name(player_collision_sound_name, player_temp.char_body.global_position, 0, 1, "SFX")
			elif (!is_reflected and (player_temp.damage.is_player_parrying() or player_temp.damage.is_invincibility_shield_active())):
				reflect_projectile()
			else:
				pass
