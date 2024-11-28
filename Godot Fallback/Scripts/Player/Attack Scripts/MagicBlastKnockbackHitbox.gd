extends KnockbackHitbox

class_name MagicBlastKnockbackHitbox

@export var enemy_defeat_knockback_multiplier : float = 1.5

@export var knockback_falloff_threshold : float = 32

@export var active_blast_jump_frames : int = 2

@export_flags_2d_physics var player_layer

@export_flags_2d_physics var ground_layer

@export_flags_2d_physics var enemy_layer

@export_flags_2d_physics var enemy_projectile_layer

var rid_list : Array[RID]

var bodies_entered : Array[Node2D]

var current_blast_jump_frames : int = 0

func _ready():
	super._ready()
	current_blast_jump_frames = active_blast_jump_frames

func _physics_process(_delta):
	resolve_bodies_entered()
	if (current_blast_jump_frames > 0):
		current_blast_jump_frames -= 1
	super._physics_process(_delta)

func _on_body_entered(body):
	for i in bodies_entered.size():
		var distance_a : float = ray.global_position.distance_to(body.global_position)
		var distance_b : float = ray.global_position.distance_to(bodies_entered[i].global_position)
		if (distance_a < distance_b):
			bodies_entered.insert(i, body)
			return
	bodies_entered.append(body)

func resolve_bodies_entered():
	ray.clear_exceptions()
	while (bodies_entered.size() > 0):
		var body = bodies_entered.pop_front()
		var temp_ray_mask = ray.collision_mask
		if (body is Boss):
			do_damage_boss(body)
		elif (body is CharacterBody2D):
			if (body.has_meta("Tag") and body.get_meta("Tag") == "Player" and current_blast_jump_frames > 0):
				do_magic_blast_knockback(body)
			elif (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy"):
				ray.collision_mask = enemy_layer
				defeat_enemy(body)
			elif (body.has_meta("Tag") and body.get_meta("Tag") == "EnemyProjectile"):
				ray.collision_mask = enemy_projectile_layer
				destroy_enemy_projectile(body)
			else:
				pass
		elif (body is Breakable):
			ray.collision_mask = ground_layer
			do_break_object(body)
		else:
			pass
		ray.collision_mask = temp_ray_mask
		if (body is CollisionObject2D):
			ray.add_exception(body as CollisionObject2D)
	ray.clear_exceptions()

func do_damage_boss(body):
	var target_pos : Vector2 = ((body as Node2D).global_position - ray.global_position)
	if (!is_going_thru_a_wall(target_pos, body.get_rid())):
		if ((body as Boss).damage_boss(damage_type, damage_strength, calculate_knockback(body))):
			hit.emit()
			EffectFactory.get_effect("MagicImpact", body.global_position)

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
			var launch_power : float = (knockback_strength / (1 + (((distance_to_projectile - knockback_falloff_threshold) / pixels_per_unit) if distance_to_projectile > knockback_falloff_threshold else 0.0)))
			var speed_falloff : float = (abs(hub.movement.top_speed / hub.movement.current_horizontal_velocity) if abs(hub.movement.current_horizontal_velocity) > hub.movement.top_speed else 1.0)
			var launch_velocity = (launch_direction * launch_power)
			launch_velocity.x *= speed_falloff
			if (hub.char_body.is_on_floor() or state_name == "Gliding"):
				launch_velocity.y = 0
			hub.char_body.velocity += launch_velocity
			hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
		
		hub.attacks.get_attack_by_name(hub.attacks.standing_attack_name).activate_blast_jump()
		active_blast_jump_frames = 0

func defeat_enemy(body):
	var target_pos : Vector2 = ((body as Node2D).global_position - ray.global_position)
	if (!is_going_thru_a_wall(target_pos, body.get_rid())):
		for child in body.get_children():
			if (child is Enemy):
				var enemy : Enemy = (child as Enemy)
				if (enemy.defeat_enemy(damage_type)):
					hit.emit()
					EffectFactory.get_effect("MagicImpact", body.global_position)
					var velocity_vector : Vector2 = calculate_knockback(body)
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

func destroy_enemy_projectile(body):
	var target_pos : Vector2 = ((body as Node2D).global_position - ray.global_position)
	if (!is_going_thru_a_wall(target_pos, body.get_rid())):
		if (body is EnemyProjectile and (body as EnemyProjectile).damage_type == "MAGIC" and !(body as EnemyProjectile).is_reflected):
			(body as EnemyProjectile).destroy_projectile()

func calculate_knockback(body):
	var velocity_vector : Vector2 = (body.global_position - collision_shape.global_position)
	var distance : float = velocity_vector.length()
	velocity_vector = velocity_vector.normalized()
	velocity_vector *= (knockback_strength / (1 + (distance / pixels_per_unit)))
	velocity_vector *= enemy_defeat_knockback_multiplier
	return velocity_vector
