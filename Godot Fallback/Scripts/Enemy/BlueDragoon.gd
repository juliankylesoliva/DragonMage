extends Enemy

@export var jump_speed : float = 10

@export var rising_gravity_scale : float = 2

@export var max_fall_speed : float = 8

@export var jump_sound_name : String = "enemy_dragoon_jump"

@export var dropped_shades_scene : PackedScene

@export var dropped_helmet_scene : PackedScene

@export var enable_wings : bool = false

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

@export var magic_start_flipped : bool = false

@export var magic_jump_modifier : float = 1.25

@export var magic_falling_gravity_modifier : float = 2

@export var magic_fall_speed_modifier : float = 1.5

@export var magic_jump_sound_pitch_modifier : float = 1.25

var did_player_land : bool = false

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if (enable_helmet):
		immunity_list.append("STOMP")
	can_reflect_projectiles = enable_reflector
	jump_speed *= (magic_jump_modifier if enable_magic else 1.0)
	gravity_scale *= (magic_falling_gravity_modifier if enable_magic else 1.0)
	max_fall_speed *= (magic_fall_speed_modifier if enable_magic else 1.0)
	if (enable_magic and magic_start_flipped):
		flip()
	if (enable_magic and enable_helmet):
		allow_upside_down_stomp = true
	movement.set_physics_process(false)
	movement.set_process(false)
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func _physics_process(delta):
	check_defeated_camera_distance()
	
	var current_gravity_scale : float = (gravity_scale if is_defeated or (body.velocity.y * body.up_direction.y) <= 0 else rising_gravity_scale)
	body.velocity.y += (base_gravity * current_gravity_scale * -body.up_direction.y * delta)
	
	if (is_defeated):
		if (!shape.disabled):
			shape.disabled = true
			spawn_shades()
			if (spawn_helmet()):
				spawn_helmet()
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

func spawn_helmet():
	var temp_helmet : Node = dropped_helmet_scene.instantiate()
	body.add_sibling(temp_helmet)
	(temp_helmet as Node2D).global_position = player_detection.front_sightline_raycast.global_position
	(temp_helmet as DragoonShades).setup(self)

func jump():
	if (body.is_on_floor()):
		body.velocity.y = (jump_speed * body.up_direction.y)
		SoundFactory.play_sound_by_name(jump_sound_name, body.global_position, 0, 1 * (magic_jump_sound_pitch_modifier if enable_magic else 1.0), "SFX")

func jump_update():
	if (!body.is_on_floor()):
		var current_fall_speed : float = abs(body.velocity.y)
		if (enable_wings and !did_player_land and !player_detection.is_player_in_midair and !did_player_land):
			did_player_land = true
		
		if (enable_wings and (body.velocity.y * body.up_direction.y) <= 0 and current_fall_speed >= 0 and player_detection.is_player_in_midair and !did_player_land):
			body.velocity.y = 0
			sprite.play("WingedFloatHelmet" if enable_helmet else "WingedFloat")
		elif (enable_wings and (body.velocity.y * body.up_direction.y) <= 0 and current_fall_speed >= 0 and !player_detection.is_player_in_midair and did_player_land):
			sprite.play("WingedFallHelmet" if enable_helmet else "WingedFall")
		else:
			pass
		
		if ((body.velocity.y * body.up_direction.y) <= 0 and current_fall_speed > max_fall_speed):
			body.velocity.y = (max_fall_speed * -body.up_direction.y)
	else:
		did_player_land = false

func flip():
	sprite.flip_v = !sprite.flip_v
	body.up_direction.y *= -1
	collision_detection.raycast_ledge_l.target_position *= -1
	collision_detection.raycast_ledge_r.target_position *= -1
	for child in self.get_children():
		if (child is Node2D):
			(child as Node2D).position.y *= -1

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	if (enable_helmet):
		sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	else:
		sprite.play("WingedIdle" if enable_wings else "Idle")

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
	if (enable_magic and body.up_direction.y > 0):
		flip()

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)

func on_player_retreat():
	if (!is_defeated):
		movement.set_physics_process(false)
		movement.set_process(false)
		if (enable_helmet):
			sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		else:
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
	if (!is_defeated and (body.velocity.y * body.up_direction.y) > 0):
		if (enable_helmet):
			sprite.play("WingedJumpHelmet" if enable_wings else "JumpHelmet")
		else:
			sprite.play("WingedJump" if enable_wings else "Jump")

func on_touching_ground():
	if (!is_defeated):
		if (enable_helmet):
			sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		else:
			sprite.play("WingedIdle" if enable_wings else "Idle")

func on_touching_ceiling():
	if (!is_defeated and enable_magic):
		flip()
