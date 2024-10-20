extends Enemy

@export var dropped_shades_scene : PackedScene

@export var enable_wings : bool = false

@export var winged_turnaround_speed : float = 128

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
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
		else:
			body.move_and_slide()

func respawn_enemy():
	super.respawn_enemy()
	shape.disabled = false

func spawn_shades():
	var temp_shades = dropped_shades_scene.instantiate()
	body.add_sibling(temp_shades)
	(temp_shades as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_shades as DragoonShades).setup(self)

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	sprite.set_visible(true)
	sprite.play("Fly" if enable_wings else "Walk")

func deactivate_enemy():
	movement.set_physics_process(false)
	movement.set_process(false)
	sprite.play("WingedIdle" if enable_wings else "Idle")
	sprite.set_visible(false)
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_defeat():
	play_damage_sound()
	sprite.play("WingedDefeat" if enable_wings else "Defeat")

func on_far_from_home():
	if (!is_defeated and enable_wings):
		movement.turn_movement(winged_turnaround_speed)

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)
		sprite.set_visible(true)
		sprite.play("Fly" if enable_wings else "Walk")

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		sprite.play("WingedIdle" if enable_wings else "Idle")
		sprite.set_visible(false)
		movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_player_collision():
	if (!is_defeated):
		if (player_detection.check_player_parry()):
			defeat_enemy("PARRY")
		elif (player_detection.check_player_guarding()):
			movement.face_away_from_player()
		elif (player_detection.damage_player()):
			movement.face_away_from_player()
			collision_detection.play_player_collision_sound()
			collision_detection.spawn_player_collision_effect()
		else:
			pass

func on_touching_wall():
	if (!is_defeated):
		movement.flip_movement()

func on_touching_ledge():
	if (!is_defeated):
		movement.flip_movement()
