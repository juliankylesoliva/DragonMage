extends Enemy

@export var jump_speed : float = 10

@export var rising_gravity_scale : float = 2

@export var max_fall_speed : float = 8

@export var jump_sound_name : String = "enemy_dragoon_jump"

@export var dropped_shades_scene : PackedScene

@export var enable_wings : bool = false

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

var did_player_land : bool = false

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if (enable_helmet):
		immunity_list.append("STOMP")
	movement.set_physics_process(false)
	movement.set_process(false)
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

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
		
		if (enable_wings and !did_player_land and !player_detection.is_player_in_midair and !did_player_land):
			did_player_land = true
		
		if (enable_wings and current_fall_speed >= 0 and player_detection.is_player_in_midair and !did_player_land):
			body.velocity.y = 0
			sprite.play("WingedFloat")
		elif (enable_wings and current_fall_speed >= 0 and !player_detection.is_player_in_midair and did_player_land):
			sprite.play("WingedFall")
		else:
			pass
		
		if (current_fall_speed > max_fall_speed):
			body.velocity.y = max_fall_speed
	else:
		did_player_land = false

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	sprite.play("WingedIdle" if enable_wings else "Idle")

func deactivate_enemy():
	movement.set_physics_process(false)
	movement.set_process(false)
	sprite.play("WingedIdle" if enable_wings else "Idle")
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_defeat():
	play_damage_sound()
	sprite.play("WingedDefeat" if enable_wings else "Defeat")

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		sprite.play("WingedIdle" if enable_wings else "Idle")
		movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_player_jump():
	if (!is_defeated):
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
	if (!is_defeated and body.velocity.y < 0):
		sprite.play("WingedJump" if enable_wings else "Jump")

func on_touching_ground():
	if (!is_defeated):
		sprite.play("WingedIdle" if enable_wings else "Idle")
