extends Enemy

enum EnemyProjectileState
{
	STANDBY,
	WINDUP,
	COOLDOWN
}

@export var red_dragoon_projectile_scene : PackedScene

@export var projectile_spawn_point : Node2D

@export var pre_fire_windup : float = 0.25

@export var post_fire_cooldown : float = 2

@export var dropped_shades_scene : PackedScene

@export var dropped_helmet_scene : PackedScene

@export var reflector_sprite : AnimatedSprite2D

@export var magic_particles : CPUParticles2D

@export var enable_wings : bool = false

@export var winged_turnaround_speed : float = 128

@export var winged_speed : float = 128

@export var flip_initial_winged_movement : bool = false

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

@export var magic_projectile_scale_modifier : float = 3.25

@export var magic_projectile_speed_modifier : float = 0.85

@export var magic_windup_modifier : float = 2

@export var magic_cooldown_modifier : float = 1.5

@export var magic_sound_pitch_modifer : float = 0.75

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_projectile_state : EnemyProjectileState = EnemyProjectileState.STANDBY

var current_projectile_state_timer : float = 0

var saved_winged_speed : Vector2 = Vector2.ZERO

var saved_turn_speed : float = 0

func _ready():
	if (enable_wings):
		movement.ignore_y_value = false
		movement.set_move_vector(Vector2(0, winged_speed if flip_initial_winged_movement else -winged_speed))
		movement.initial_move_vector = movement.current_move_vector
	if (enable_helmet):
		immunity_list.append("STOMP")
	can_reflect_projectiles = enable_reflector
	reflector_sprite.set_visible(enable_reflector)
	if (enable_magic):
		pre_fire_windup *= magic_windup_modifier
		post_fire_cooldown *= magic_cooldown_modifier
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
			spawn_shades()
			if (enable_helmet):
				spawn_helmet()
		else:
			body.move_and_slide()
	else:
		update_state_timer(delta)

func respawn_enemy():
	super.respawn_enemy()
	shape.disabled = false

func spawn_shades():
	var temp_shades : Node = dropped_shades_scene.instantiate()
	body.add_sibling(temp_shades)
	(temp_shades as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_shades as DragoonShades).setup(self)

func spawn_helmet():
	var temp_helmet : Node = dropped_helmet_scene.instantiate()
	body.add_sibling(temp_helmet)
	(temp_helmet as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_helmet as DragoonShades).setup(self)

func launch_projectile():
	if (current_projectile_state != EnemyProjectileState.STANDBY or !visibility_notifier.is_on_screen()):
		return
	current_projectile_state = EnemyProjectileState.WINDUP
	current_projectile_state_timer = pre_fire_windup
	if (enable_helmet):
		sprite.play("WingedAttackWindupHelmet" if enable_wings else "AttackWindupHelmet")
	else:
		sprite.play("WingedAttackWindup" if enable_wings else "AttackWindup")

func reset_timer_and_state():
	current_projectile_state = EnemyProjectileState.STANDBY
	current_projectile_state_timer = 0

func update_state_timer(delta : float):
	if (current_projectile_state == EnemyProjectileState.WINDUP or current_projectile_state == EnemyProjectileState.COOLDOWN):
		if (current_projectile_state_timer > 0):
			current_projectile_state_timer = move_toward(current_projectile_state_timer, 0, delta)
			if (enable_wings and current_projectile_state == EnemyProjectileState.COOLDOWN):
				if (enable_helmet):
					if (sprite.animation == "WingedAttackLaunchHelmet" and !sprite.is_playing()):
						sprite.play("WingedAttackCooldownHelmet")
				else:
					if (sprite.animation == "WingedAttackLaunch" and !sprite.is_playing()):
						sprite.play("WingedAttackCooldown")
		
		if (current_projectile_state_timer <= 0):
			if (current_projectile_state == EnemyProjectileState.WINDUP):
				var proj_temp: Node = red_dragoon_projectile_scene.instantiate()
				body.add_sibling(proj_temp)
				(proj_temp as Node2D).global_position = projectile_spawn_point.global_position
				
				(proj_temp as EnemyProjectile).setup(self)
				(proj_temp as EnemyProjectile).velocity *= (magic_projectile_speed_modifier if enable_magic else 1.0)
				(proj_temp as CharacterBody2D).scale *= (magic_projectile_scale_modifier if enable_magic else 1.0)
				(proj_temp as EnemyProjectile).audio.pitch_scale *= (magic_sound_pitch_modifer if enable_magic else 1.0)
				
				current_projectile_state = EnemyProjectileState.COOLDOWN
				current_projectile_state_timer = post_fire_cooldown
				if (enable_helmet):
					sprite.play("WingedAttackLaunchHelmet" if enable_wings else "AttackLaunchHelmet")
				else:
					sprite.play("WingedAttackLaunch" if enable_wings else "AttackLaunch")
			else:
				current_projectile_state = EnemyProjectileState.STANDBY
				current_projectile_state_timer = 0
				if (enable_helmet):
					sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
				else:
					sprite.play("WingedIdle" if enable_wings else "Idle")

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	if (enable_wings):
		movement.reset_to_initial_move_vector()
	reset_timer_and_state()

func deactivate_enemy():
	movement.set_physics_process(false)
	movement.set_process(false)
	if (enable_helmet):
		sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	else:
		sprite.play("WingedIdle" if enable_wings else "Idle")
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_defeat():
	play_damage_sound()
	sprite.play("WingedDefeat" if enable_wings else "Defeat")
	reflector_sprite.set_visible(false)
	magic_particles.set_emitting(false)

func on_far_from_home():
	if (!is_defeated and enable_wings):
		movement.turn_movement(winged_turnaround_speed)

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)
		movement.face_towards_player()
		if (enable_helmet):
			sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		else:
			sprite.play("WingedIdle" if enable_wings else "Idle")

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		if (enable_helmet):
			sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		else:
			sprite.play("WingedIdle" if enable_wings else "Idle")
		movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_player_enter_sightline():
	if (!is_defeated and visibility_notifier.is_on_screen()):
		launch_projectile()

func on_player_stay_sightline():
	if (!is_defeated and visibility_notifier.is_on_screen()):
		launch_projectile()

func on_touching_wall():
	if (!is_defeated):
		movement.flip_movement()

func on_touching_ledge():
	if (!is_defeated):
		movement.flip_movement()

func on_player_collision():
	if (!is_defeated):
		if (player_detection.check_player_parry()):
			defeat_enemy("PARRY")
		elif (player_detection.damage_player()):
			collision_detection.play_player_collision_sound()
			collision_detection.spawn_player_collision_effect()
		else:
			pass
