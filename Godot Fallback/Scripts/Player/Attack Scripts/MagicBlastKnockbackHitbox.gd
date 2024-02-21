extends KnockbackHitbox

class_name MagicBlastKnockbackHitbox

@export var enemy_defeat_knockback_multiplier : float = 1.5

@export_flags_2d_physics var player_layer

@export_flags_2d_physics var ground_layer

var rid_list : Array[RID]

func _on_body_entered(body):
	var temp_ray_mask = ray.collision_mask
	if (body is CharacterBody2D):
		if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
			do_magic_blast_knockback(body)
		elif (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
			defeat_enemy(body)
		else:
			pass
	elif (body is Breakable):
		ray.collision_mask = ground_layer
		do_break_object(body)
	else:
		pass
	ray.collision_mask = temp_ray_mask

func do_magic_blast_knockback(body):
	var hub : PlayerHub = null
	for child in body.get_children():
		if (child is PlayerHub):
			hub = (child as PlayerHub)
			break
	
	if (hub != null and hub.form.current_mode == PlayerForm.CharacterMode.MAGE):
		var target_pos : Vector2 = (hub.collision_shape.global_position - ray.global_position)
		ray.force_raycast_update()
		
		if (is_going_thru_a_wall(target_pos, hub.char_body.get_rid())):
			return
		
		if (rid_list.count(hub.char_body.get_rid()) > 0):
			return
		else:
			rid_list.append(hub.char_body.get_rid())
		
		var state_name : String = hub.state_machine.current_state.name
		var distance_to_projectile : float = (hub.collision_shape.global_position.distance_to(collision_shape.global_position))
		
		if (state_name != "Standing" and state_name != "WallSliding" and state_name != "Attacking" and state_name != "FormChanging"):
			var launch_direction : Vector2 = collision_shape.global_position.direction_to(hub.collision_shape.global_position)
			var launch_power : float = (knockback_strength / (1 + (distance_to_projectile / pixels_per_unit)))
			var launch_velocity = (launch_direction * launch_power)
			if (hub.char_body.is_on_floor() or state_name == "Gliding"):
				launch_velocity.y = 0
			hub.char_body.velocity += launch_velocity
			hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
		
		hub.attacks.get_attack_by_name(hub.attacks.standing_attack_name).activate_blast_jump()

func defeat_enemy(body):
	var target_pos : Vector2 = ((body as Node2D).global_position - ray.global_position)
	if (!is_going_thru_a_wall(target_pos, body.get_rid())):
		for child in body.get_children():
			if (child is Enemy):
				var enemy : Enemy = (child as Enemy)
				if (enemy.defeat_enemy(damage_type)):
					hit.emit()
					EffectFactory.get_effect("MagicImpact", body.global_position)
					var velocity_vector : Vector2 = (body.global_position - collision_shape.global_position)
					var distance : float = velocity_vector.length()
					velocity_vector = velocity_vector.normalized()
					velocity_vector *= (knockback_strength / (1 + (distance / pixels_per_unit)))
					velocity_vector *= enemy_defeat_knockback_multiplier
					enemy.body.velocity += velocity_vector
					return

func do_break_object(body):
	var target_pos : Vector2 = ((body as Node2D).global_position - ray.global_position)
	if (!is_going_thru_a_wall(target_pos, body.get_rid())):
		if ((body as Breakable).break_object(self)):
			hit.emit()

func is_going_thru_a_wall(target_pos : Vector2, body_rid : RID):
	ray.target_position = target_pos
	ray.force_raycast_update()
	
	if (!ray.is_colliding() or ray.get_collider_rid() != body_rid):
		return true
	return false
