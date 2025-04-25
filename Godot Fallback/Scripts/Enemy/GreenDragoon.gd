extends Enemy

@export var dropped_shades_scene : PackedScene

@export var dropped_helmet_scene : PackedScene

@export var reflector_sprite : AnimatedSprite2D

@export var flip_initial_movement : bool = false

@export var enable_wings : bool = false

@export var winged_turnaround_speed : float = 128

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

@export var magic_speed_modifier : float = 2

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if (flip_initial_movement):
		movement.initial_move_vector *= -1
	if (enable_helmet):
		immunity_list.append("STOMP")
	can_reflect_projectiles = enable_reflector
	reflector_sprite.set_visible(enable_reflector)
	if (enable_magic):
		movement.initial_move_vector *= magic_speed_modifier
		if (enable_wings):
			winged_turnaround_speed *= (magic_speed_modifier * magic_speed_modifier)
		sprite.set_speed_scale(magic_speed_modifier)
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

func respawn_enemy():
	super.respawn_enemy()
	shape.disabled = false

func spawn_shades():
	var temp_shades = dropped_shades_scene.instantiate()
	body.add_sibling(temp_shades)
	(temp_shades as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_shades as DragoonShades).setup(self)

func spawn_helmet():
	var temp_helmet = dropped_helmet_scene.instantiate()
	body.add_sibling(temp_helmet)
	(temp_helmet as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_helmet as DragoonShades).setup(self)

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	sprite.set_visible(true)
	if (enable_helmet):
		sprite.play("FlyHelmet" if enable_wings else "WalkHelmet")
	else:
		sprite.play("Fly" if enable_wings else "Walk")

func deactivate_enemy():
	movement.set_physics_process(false)
	movement.set_process(false)
	if (enable_helmet):
		sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	else:
		sprite.play("WingedIdle" if enable_wings else "Idle")
	sprite.set_visible(false)
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_defeat():
	play_damage_sound()
	sprite.play("WingedDefeat" if enable_wings else "Defeat")
	reflector_sprite.set_visible(false)

func on_far_from_home():
	if (!is_defeated and enable_wings):
		movement.turn_movement(winged_turnaround_speed)

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)
		sprite.set_visible(true)
		if (enable_helmet):
			sprite.play("FlyHelmet" if enable_wings else "WalkHelmet")
		else:
			sprite.play("Fly" if enable_wings else "Walk")

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		if (enable_helmet):
			sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		else:
			sprite.play("WingedIdle" if enable_wings else "Idle")
		sprite.set_visible(false)
		movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_player_collision():
	if (!is_defeated):
		if (player_detection.check_player_stomping()):
			pass
		elif (player_detection.check_player_parry()):
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
