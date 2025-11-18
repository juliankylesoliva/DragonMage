extends Enemy

@export var move_speed : float = 96

@export var min_distance_from_player : float = 128

@export var reflector_sprite : AnimatedSprite2D

@export var magic_particles : CPUParticles2D

@export var enable_wings : bool = false

@export var winged_turnaround_speed : float = 128

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

@export var magic_speed_modifier : float = 2

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	movement.ignore_y_value = !enable_wings
	if (enable_helmet):
		immunity_list.append("STOMP")
	can_reflect_projectiles = enable_reflector
	reflector_sprite.set_visible(enable_reflector)
	if (enable_magic):
		move_speed *= magic_speed_modifier
		if (enable_wings):
			winged_turnaround_speed *= (magic_speed_modifier * magic_speed_modifier)
		sprite.set_speed_scale(magic_speed_modifier)
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
			#spawn_shades()
			#if (enable_helmet):
				#spawn_helmet()
		else:
			body.move_and_slide()
	else:
		is_intangible = (movement.current_move_vector.x == 0)

func respawn_enemy():
	super.respawn_enemy()
	shape.disabled = false

func mark_as_defeated():
	super.mark_as_defeated()
	reflector_sprite.set_visible(false)
	magic_particles.set_emitting(false)
	shape.disabled = true

func activate_enemy():
	movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
	movement.set_physics_process(true)
	movement.set_process(true)
	movement.set_facing_direction(-1)
	movement.reset_to_initial_position()
	movement.reset_to_initial_move_vector()
	movement.is_always_facing_player = true
	#if (enable_helmet):
	#	sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	#else:
	#	sprite.play("WingedIdle" if enable_wings else "Idle")

func deactivate_enemy():
	movement.is_always_facing_player = true
	movement.set_physics_process(false)
	movement.set_process(false)
	#if (enable_helmet):
	#	sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
	#else:
	#	sprite.play("WingedIdle" if enable_wings else "Idle")
	movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_defeat():
	play_damage_sound()
	#sprite.play("WingedDefeat" if enable_wings else "Defeat")
	reflector_sprite.set_visible(false)
	magic_particles.set_emitting(false)

func on_player_approach():
	if (!is_defeated):
		movement.set_process_mode(Node.PROCESS_MODE_INHERIT)
		movement.set_physics_process(true)
		movement.set_process(true)
		movement.reset_to_initial_move_vector()
		movement.is_always_facing_player = true

func on_player_retreat():
	if (!is_defeated):
		movement.is_always_facing_player = true
		movement.set_facing_direction(-1)
		movement.reset_to_initial_move_vector()
		movement.set_physics_process(false)
		movement.set_process(false)
		#if (enable_helmet):
		#	sprite.play("WingedIdleHelmet" if enable_wings else "IdleHelmet")
		#else:
		#	sprite.play("WingedIdle" if enable_wings else "Idle")
		movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func on_turned_away():
	if (!is_defeated and visibility_notifier.is_on_screen() and movement.current_move_vector.x == 0 and player_detection.get_horizontal_distance_to_player() >= min_distance_from_player):
		movement.is_always_facing_player = false
		movement.face_towards_player()
		var horizontal_vector : Vector2 = (Vector2.RIGHT * movement.get_facing_value() * move_speed)
		var vertical_vector : Vector2 = (min(move_speed, player_detection.get_vertical_distance_to_player()) * (Vector2.ZERO if !enable_wings else Vector2.UP if player_detection.get_player_position().y < body.global_position.y else Vector2.DOWN if player_detection.get_player_position().y > body.global_position.y else Vector2.ZERO))
		movement.set_move_vector(horizontal_vector + vertical_vector)
		#if (enable_helmet):
		#	sprite.play("WingedChaseHelmet" if enable_wings else "WalkHelmet")
		#else:
		#	sprite.play("WingedChase" if enable_wings else "Walk")

func on_looking_away():
	if (!is_defeated and visibility_notifier.is_on_screen() and player_detection.get_horizontal_distance_to_player() >= min_distance_from_player):
		movement.is_always_facing_player = false
		var horizontal_vector : Vector2 = (Vector2.RIGHT * movement.get_facing_value() * move_speed)
		var vertical_vector : Vector2 = (min(move_speed, player_detection.get_vertical_distance_to_player()) * (Vector2.ZERO if !enable_wings else Vector2.UP if player_detection.get_player_position().y < body.global_position.y else Vector2.DOWN if player_detection.get_player_position().y > body.global_position.y else Vector2.ZERO))
		movement.set_move_vector(horizontal_vector + vertical_vector)
		#if (enable_helmet):
		#	sprite.play("WingedChaseHelmet" if enable_wings else "WalkHelmet")
		#else:
		#	sprite.play("WingedChase" if enable_wings else "Walk")

func on_turned_towards():
	if (!is_defeated and visibility_notifier.is_on_screen() and movement.current_move_vector.x != 0):
		movement.set_move_vector(Vector2.ZERO)
		movement.is_always_facing_player = true
		# hiding animation

func on_looking_towards():
	if (!is_defeated and visibility_notifier.is_on_screen() and movement.current_move_vector.x != 0):
		movement.set_move_vector(Vector2.ZERO)
		movement.is_always_facing_player = true
		# hiding animation

func on_touching_wall():
	if (!is_defeated and !enable_wings):
		movement.set_move_vector(Vector2.ZERO)
		movement.is_always_facing_player = true
		# hiding animation

func on_touching_ledge():
	if (!is_defeated and !enable_wings):
		movement.set_move_vector(Vector2.ZERO)
		movement.is_always_facing_player = true
		# hiding animation

func on_player_collision():
	if (movement.current_move_vector.x != 0 and !is_defeated):
		if (player_detection.check_player_parry()):
			defeat_enemy("PARRY")
		elif (player_detection.check_player_guarding()):
			movement.face_away_from_player()
		elif (player_detection.damage_player()):
			movement.set_move_vector(Vector2.ZERO)
			movement.is_always_facing_player = true
			# hiding animation
			collision_detection.play_player_collision_sound()
			collision_detection.spawn_player_collision_effect()
		else:
			pass
