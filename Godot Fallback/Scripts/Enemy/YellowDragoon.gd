extends Enemy

@export var move_speed : float = 4

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	check_defeated_camera_distance()
	body.velocity.y += (base_gravity * gravity_scale * delta)
	if (is_defeated):
		if (!shape.disabled):
			shape.disabled = true
		else:
			body.move_and_slide()

func activate_enemy():
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	sprite.play("Idle")

func on_defeat():
	play_damage_sound()
	sprite.play("Defeat")

func on_player_retreat():
	sprite.play("Idle")

func on_enter_sightline():
	movement.face_towards_player()
	movement.set_move_vector(Vector2.RIGHT * movement.get_facing_value() * move_speed)
	sprite.play("Walk")

func on_stay_sightline():
	sprite.play("Walk")

func on_touching_wall():
	movement.flip_movement(true)

func on_touching_ledge():
	movement.flip_movement(true)

func on_player_collision():
	if (!is_defeated and player_detection.damage_player()):
		movement.face_away_from_player()
		collision_detection.play_player_collision_sound()
		collision_detection.spawn_player_collision_effect()
