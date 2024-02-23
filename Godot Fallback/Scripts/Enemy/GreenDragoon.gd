extends Enemy

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

func on_player_approach():
	if (!is_defeated):
		movement.set_physics_process(true)
		movement.set_process(true)
		sprite.play("Walk")

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		sprite.play("Idle")

func on_player_collision():
	if (!is_defeated and player_detection.damage_player()):
		movement.face_away_from_player()
		collision_detection.play_player_collision_sound()
		collision_detection.spawn_player_collision_effect()

func on_touching_wall():
	if (!is_defeated):
		movement.flip_movement()

func on_touching_ledge():
	if (!is_defeated):
		movement.flip_movement()
