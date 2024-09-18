extends Node

class_name EnemyPlayerDetection

@export var enemy : Enemy

@export var player_detection_distance : float = 5

@export var enemy_sightline_distance : float = 14

@export var enemy_short_sightline_distance : float = 7

@export var player_jumping_threshold : float = -32

@export var front_sightline_raycast : RayCast2D

@export var back_sightline_raycast : RayCast2D

@export var use_short_sightline_distance : bool = false

@export var use_back_sightline : bool = false

signal player_approach

signal player_retreat

signal player_enter_sightline

signal player_stay_sightline

signal player_exit_sightline

signal player_jump

var player_ref : PlayerHub = null

var is_player_nearby : bool = false

var is_player_in_sightline : bool = false

var did_player_jump : bool = false

var is_player_in_midair : bool = false

func _physics_process(_delta):
	check_player_detection_radius()
	check_enemy_sightline()
	check_player_jump()
	check_player_midair()

func get_player_position():
	return player_ref.char_body.global_position

func get_distance_to_player():
	if (player_ref != null):
		return enemy.body.global_position.distance_to(player_ref.char_body.global_position)

func get_direction_to_player():
	if (player_ref != null):
		var x_diff = (player_ref.char_body.global_position.x - enemy.body.global_position.x)
		if (x_diff != 0):
			return (1.0 if x_diff > 0 else -1.0)
	return 0.0

func damage_player():
	if (player_ref != null):
		return player_ref.damage.take_damage(get_direction_to_player())
	return false

func check_player_parry():
	if (player_ref != null):
		return player_ref.damage.is_player_parrying()
	return false

func check_player_guarding():
	if (player_ref != null):
		return (player_ref.damage.is_player_guarding() and ((enemy.movement.get_facing_value() * player_ref.movement.get_facing_value()) < 0))
	return false

func check_player_detection_radius():
	if (player_ref != null):
		var player_distance : float = get_distance_to_player()
		if (player_distance >= 0 and player_distance <= player_detection_distance):
			if (!is_player_nearby):
				player_approach.emit()
			is_player_nearby = true
		else:
			if (is_player_nearby):
				player_retreat.emit()
			is_player_nearby = false

func check_enemy_sightline():
	front_sightline_raycast.target_position.x = (enemy.movement.get_facing_value() * (enemy_short_sightline_distance if use_short_sightline_distance else enemy_sightline_distance))
	front_sightline_raycast.force_raycast_update()
	
	if (use_back_sightline):
		back_sightline_raycast.target_position.x = -front_sightline_raycast.target_position.x
		back_sightline_raycast.force_raycast_update()
	
	if (front_sightline_raycast.is_colliding() and front_sightline_raycast.get_collider().has_meta("Tag") and front_sightline_raycast.get_collider().get_meta("Tag") == "Player"):
		if (!is_player_in_sightline):
			player_enter_sightline.emit()
		else:
			player_stay_sightline.emit()
		is_player_in_sightline = true
	elif (use_back_sightline and back_sightline_raycast.is_colliding() and back_sightline_raycast.get_collider().has_meta("Tag") and back_sightline_raycast.get_collider().get_meta("Tag") == "Player"):
		if (!is_player_in_sightline):
			player_enter_sightline.emit()
		else:
			player_stay_sightline.emit()
		is_player_in_sightline = true
	else:
		if (is_player_in_sightline):
			player_exit_sightline.emit()
		is_player_in_sightline = false

func check_player_jump():
	if (enemy.visibility_notifier.is_on_screen() and player_ref != null):
		if (player_ref.state_machine.current_state.name == "Jumping" and (!player_ref.char_body.is_on_floor()) and player_ref.char_body.velocity.y < player_jumping_threshold):
			if (!did_player_jump):
				player_jump.emit()
			did_player_jump = true
		else:
			did_player_jump = false

func check_player_midair():
	if (enemy.visibility_notifier.is_on_screen() and player_ref != null):
		is_player_in_midair = !player_ref.char_body.is_on_floor()
		return
	is_player_in_midair = false
