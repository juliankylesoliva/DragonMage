extends Enemy

@export var dropped_shades_scene : PackedScene

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	movement.set_physics_process(false)
	movement.set_process(false)

func _physics_process(delta):
	check_defeated_camera_distance()
	body.velocity.y += (base_gravity * gravity_scale * delta)
	if (is_defeated):
		if (!shape.disabled):
			shape.disabled = true
			spawn_shades()
		else:
			body.move_and_slide()

func spawn_shades():
	var temp_shades = dropped_shades_scene.instantiate()
	body.add_sibling(temp_shades)
	(temp_shades as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_shades as DragoonShades).setup(self)

func activate_enemy():
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	sprite.play("Walk")

func deactivate_enemy():
	movement.set_physics_process(false)
	movement.set_process(false)
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
