extends Enemy

@export var jump_speed : float = 10

@export var rising_gravity_scale : float = 2

@export var max_fall_speed : float = 8

@export var jump_sound_name : String = "enemy_dragoon_jump"

@export var dropped_shades_scene : PackedScene

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	movement.set_physics_process(false)
	movement.set_process(false)

func _physics_process(delta):
	check_defeated_camera_distance()
	
	var current_gravity_scale : float = (gravity_scale if is_defeated or body.velocity.y >= 0 else rising_gravity_scale)
	body.velocity.y += (base_gravity * current_gravity_scale * delta)
	
	if (is_defeated):
		if (!shape.disabled):
			shape.disabled = true
			spawn_shades()
		else:
			body.move_and_slide()
	else:
		jump_update()

func respawn_enemy():
	super.respawn_enemy()
	shape.disabled = false

func spawn_shades():
	var temp_shades : Node = dropped_shades_scene.instantiate()
	body.add_sibling(temp_shades)
	(temp_shades as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_shades as DragoonShades).setup(self)

func jump():
	if (body.is_on_floor()):
		body.velocity.y = -jump_speed
		SoundFactory.play_sound_by_name(jump_sound_name, body.global_position, 0, 1, "SFX")

func jump_update():
	if (!body.is_on_floor()):
		var current_fall_speed : float = body.velocity.y
		if (current_fall_speed > max_fall_speed):
			body.velocity.y = max_fall_speed

func activate_enemy():
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	sprite.play("Idle")

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

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		sprite.play("Idle")

func on_player_jump():
	jump()

func on_player_collision():
	if (!is_defeated):
		if (player_detection.check_player_parry()):
			defeat_enemy("PARRY")
		elif (player_detection.damage_player()):
			collision_detection.play_player_collision_sound()
			collision_detection.spawn_player_collision_effect()
		else:
			pass

func on_leaving_ground():
	if (!is_defeated):
		sprite.play("Jump")

func on_touching_ground():
	if (!is_defeated):
		sprite.play("Idle")
