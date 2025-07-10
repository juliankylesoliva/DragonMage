extends Node2D

class_name Fyerlarm

@export var anim_sprite : AnimatedSprite2D

@export var windup_duration : float = 2

@export var attack_duration : float = 1

@export var cooldown_duration : float = 3

@export var enemy_knockback_strength : float = 512

@export_color_no_alpha var windup_color : Color = Color.WHITE

@export_color_no_alpha var cooldown_color : Color = Color.WHITE

var bodies_in_hitbox : Array

var player_ref : PlayerHub = null

var current_state : int = 0

var state_timer : float = 0

func _process(delta):
	do_state_process(delta)

func _physics_process(_delta):
	if (current_state == 0 and player_ref != null):
		var temp_attack : Attack = player_ref.attacks.get_attack_by_name("FireTackle")
		if (temp_attack != null and (temp_attack is FireTackleAttack)):
			if (temp_attack.current_attack_state == Attack.AttackState.ACTIVE):
				set_to_state(1)

func set_to_state(num : int):
	match num:
		0:
			current_state = num
			anim_sprite.play("Idle")
			anim_sprite.modulate = Color.WHITE
			state_timer = 0
		1:
			current_state = num
			anim_sprite.play("Windup")
			anim_sprite.modulate = windup_color
			state_timer = windup_duration
		2:
			current_state = num
			anim_sprite.play("Attack")
			anim_sprite.modulate = Color.WHITE
			state_timer = attack_duration
		3:
			current_state = num
			anim_sprite.play("Cooldown")
			anim_sprite.modulate = cooldown_color
			state_timer = cooldown_duration
		_:
			current_state = 0
			anim_sprite.play("Idle")
			anim_sprite.modulate = Color.WHITE

func do_state_process(delta : float):
	if (state_timer > 0):
		state_timer = move_toward(state_timer, 0, delta)
	
	match current_state:
		1:
			if (state_timer <= 0):
				set_to_state(2)
		2:
			resolve_hitbox_bodies()
			if (state_timer <= 0):
				set_to_state(3)
		3:
			if (state_timer <= 0):
				set_to_state(0)
		_:
			set_to_state(0)

func resolve_hitbox_bodies():
	for body in bodies_in_hitbox:
		if (body is KnockbackHitbox and (body as KnockbackHitbox).damage_type == "FIRE"):
			if (body is FireballKnockbackHitbox):
				(body as FireballKnockbackHitbox).destroy_projectile()
		elif (body is EnemyProjectile and (body as EnemyProjectile).damage_type == "FIRE"):
			(body as EnemyProjectile).destroy_projectile()
		elif (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy" and (body is Enemy)):
			var temp_enemy : Enemy = (body as Enemy)
			if(temp_enemy.defeat_enemy("HAZARD")):
				temp_enemy.body.velocity += (enemy_knockback_strength * (temp_enemy.body.global_position - self.global_position).normalized())
		elif (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
			var player_temp : PlayerHub = null
		
			for child in body.get_children():
				if (child is PlayerHub):
					player_temp = (child as PlayerHub)
					break
			
			if (player_temp != null):
				var direction = (player_temp.char_body.global_position.x - global_position.x)
				direction = (1.0 if direction >= 0 else -1.0)
				player_temp.damage.take_damage(direction)
		else:
			pass

func _on_body_entered(body: Node2D) -> void:
	if (current_state == 0 and (body is KnockbackHitbox) and (body as KnockbackHitbox).damage_type == "FIRE"):
		set_to_state(1)
	elif (current_state == 0 and (body is EnemyProjectile) and (body as EnemyProjectile).damage_type == "FIRE"):
		set_to_state(1)
	elif (current_state == 0 and player_ref == null and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				player_ref = (child as PlayerHub)
				break
	elif (current_state == 0 and body.get_child_count() > 0):
		for child in body.get_children():
			if ((child is KnockbackHitbox) and (child as KnockbackHitbox).damage_type == "FIRE"):
				set_to_state(1)
				return
	else:
		pass

func _on_body_exited(body : Node2D):
	if (player_ref != null and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		player_ref = null

func _on_attack_area_body_entered(body: Node2D) -> void:
	if (!bodies_in_hitbox.has(body)):
		bodies_in_hitbox.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
	if (bodies_in_hitbox.has(body)):
		bodies_in_hitbox.erase(body)
