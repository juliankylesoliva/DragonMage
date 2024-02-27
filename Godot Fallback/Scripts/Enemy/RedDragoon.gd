extends Enemy

@export var red_dragoon_projectile_scene : PackedScene

@export var projectile_spawn_point : Node2D

@export var pre_fire_windup : float = 0.25

@export var post_fire_cooldown : float = 2

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_projectile_state : String = "STANDBY"

var current_projectile_state_timer : float = 0

func _physics_process(delta):
	check_defeated_camera_distance()
	body.velocity.y += (base_gravity * gravity_scale * delta)
	if (is_defeated):
		if (!shape.disabled):
			shape.disabled = true
		else:
			body.move_and_slide()
	else:
		update_state_timer(delta)

func launch_projectile():
	if (current_projectile_state != "STANDBY" or !visibility_notifier.is_on_screen()):
		return
	current_projectile_state = "WINDUP"
	current_projectile_state_timer = pre_fire_windup
	sprite.play("AttackWindup")

func reset_timer_and_state():
	current_projectile_state = "STANDBY"
	current_projectile_state_timer = 0

func update_state_timer(delta : float):
	if (current_projectile_state == "WINDUP" or current_projectile_state == "COOLDOWN"):
		if (current_projectile_state_timer > 0):
			current_projectile_state_timer = move_toward(current_projectile_state_timer, 0, delta)
		
		if (current_projectile_state_timer <= 0):
			if (current_projectile_state == "WINDUP"):
				var proj_temp: Node = red_dragoon_projectile_scene.instantiate()
				body.add_sibling(proj_temp)
				(proj_temp as Node2D).global_position = projectile_spawn_point.global_position
				
				(proj_temp as EnemyProjectile).setup(self)
				
				current_projectile_state = "COOLDOWN"
				current_projectile_state_timer = post_fire_cooldown
				sprite.play("AttackLaunch")
			else:
				current_projectile_state = "STANDBY"
				current_projectile_state_timer = 0
				sprite.play("Idle")

func activate_enemy():
	movement.reset_to_initial_position()
	reset_timer_and_state()

func on_defeat():
	play_damage_sound()
	sprite.play("Defeat")

func on_player_approach():
	if (!is_defeated):
		movement.face_towards_player()
		sprite.play("Idle")

func on_player_retreat():
	if (!is_defeated):
		sprite.play("Idle")

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
	if (!is_defeated and player_detection.damage_player()):
		movement.face_away_from_player()
		collision_detection.play_player_collision_sound()
		collision_detection.spawn_player_collision_effect()
