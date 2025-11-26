extends Enemy

enum EnemyProjectileState
{
	MOVING,
	FIRING
}

@export var red_magent_projectile_scene : PackedScene

@export var projectile_spawn_point : Node2D

@export var move_speed : float = 32

@export var move_duration : float = 1

@export var firing_duration : float = 0.5

@export var reflector_sprite : AnimatedSprite2D

@export var magic_particles : CPUParticles2D

@export var enable_wings : bool = false

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

@export var magic_speed_modifier : float = 0.5

@export var magic_projectile_scale_modifier : float = 1.5

@export var magic_projectile_speed_modifier : float = 2

@export var magic_sound_pitch_modifer : float = 1.5

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_projectile_state : EnemyProjectileState = EnemyProjectileState.MOVING

var current_projectile_state_timer : float = 0

var current_movement_direction : int = 1

func _ready():
	movement.ignore_y_value = !enable_wings
	if (enable_helmet):
		immunity_list.append("STOMP")
	can_reflect_projectiles = enable_reflector
	reflector_sprite.set_visible(enable_reflector)
	if (enable_magic):
		move_speed *= magic_speed_modifier
		sprite.set_speed_scale(magic_speed_modifier)
	magic_particles.set_emitting(enable_magic)
	movement.set_physics_process(false)
	movement.set_process(false)
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func _physics_process(delta):
	check_defeated_camera_distance()
	if (!enable_wings or is_defeated):
		body.velocity.y += (base_gravity * gravity_scale * delta)
	
	if (is_defeated):
		if (!shape.disabled):
			shape.disabled = true
			#spawn_shades()
			#if (enable_helmet):
				#spawn_helmet()
		else:
			body.move_and_slide()
	else:
		update_state_timer(delta)

func respawn_enemy():
	super.respawn_enemy()
	shape.disabled = false

func update_state_timer(delta : float):
	if (current_projectile_state_timer > 0):
		current_projectile_state_timer = move_toward(current_projectile_state_timer, 0, delta)
		if (current_projectile_state_timer <= 0):
			match current_projectile_state:
				EnemyProjectileState.MOVING:
					do_state_switch(EnemyProjectileState.FIRING)
				EnemyProjectileState.FIRING:
					do_state_switch(EnemyProjectileState.MOVING)
				_:
					do_state_switch(EnemyProjectileState.MOVING)

func do_state_switch(next_state : EnemyProjectileState):
	if (current_projectile_state_timer > 0):
		current_projectile_state_timer = 0
	current_projectile_state = next_state
	match current_projectile_state:
		EnemyProjectileState.MOVING:
			movement.set_move_vector(Vector2.RIGHT * current_movement_direction * move_speed)
			current_projectile_state_timer = move_duration
		EnemyProjectileState.FIRING:
			current_movement_direction = movement.get_direction_to_home()
			if (current_movement_direction == 0.0):
				current_movement_direction = -movement.get_facing_value()
			movement.set_move_vector(Vector2.ZERO)
			movement.face_towards_player()
			var proj_temp: Node = red_magent_projectile_scene.instantiate()
			body.add_sibling(proj_temp)
			(proj_temp as Node2D).global_position = projectile_spawn_point.global_position
			
			(proj_temp as EnemyProjectile).setup(self)
			(proj_temp as EnemyProjectile).velocity *= (magic_projectile_speed_modifier if enable_magic else 1.0)
			(proj_temp as CharacterBody2D).scale *= (magic_projectile_scale_modifier if enable_magic else 1.0)
			(proj_temp as EnemyProjectile).audio.pitch_scale *= (magic_sound_pitch_modifer if enable_magic else 1.0)
			current_projectile_state_timer = firing_duration
		_:
			movement.set_move_vector(Vector2.RIGHT * current_movement_direction * move_speed)
			current_projectile_state_timer = move_duration

func mark_as_defeated():
	super.mark_as_defeated()
	reflector_sprite.set_visible(false)
	magic_particles.set_emitting(false)
	shape.disabled = true

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.set_facing_direction(-1)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	#if (enable_helmet):
	#	sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	#else:
	#	sprite.play("WingedIdle" if enable_wings else "Idle")

func deactivate_enemy():
	movement.set_physics_process(false)
	movement.set_process(false)
	#if (enable_helmet):
	#	sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	#else:
	#	sprite.play("WingedIdle" if enable_wings else "Idle")
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_defeat():
	play_damage_sound()
	#sprite.play("WingedDefeat" if enable_wings else "Defeat")
	reflector_sprite.set_visible(false)
	magic_particles.set_emitting(false)

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)
		movement.face_towards_player()
		do_state_switch(EnemyProjectileState.MOVING)

func on_player_retreat():
	if (!is_defeated):
		movement.reset_to_initial_move_vector()
		movement.set_physics_process(false)
		movement.set_process(false)
		#if (enable_helmet):
		#	sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		#else:
		#	sprite.play("WingedIdle" if enable_wings else "Idle")
		movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_player_collision():
	if (!is_defeated):
		if (player_detection.check_player_stomping()):
			pass
		elif (player_detection.check_player_parry()):
			defeat_enemy("PARRY")
		elif (player_detection.damage_player()):
			collision_detection.play_player_collision_sound()
			collision_detection.spawn_player_collision_effect()
		else:
			pass

func on_touching_wall():
	if (!is_defeated):
		do_state_switch(EnemyProjectileState.FIRING)
		pass

func on_touching_ledge():
	if (!is_defeated):
		do_state_switch(EnemyProjectileState.FIRING)
		pass
