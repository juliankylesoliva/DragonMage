extends Node

class_name EnemyMovement

@export var enemy : Enemy

@export var initial_move_vector : Vector2

@export var turning_cooldown_time : float = 0

@export var ignore_y_value : bool = true

@export var is_always_facing_player : bool = true

@export var max_distance_from_init_pos : float = -1

signal far_from_home

var initial_position : Vector2 = Vector2.ZERO

var current_move_vector : Vector2 = Vector2.ZERO

var current_turning_cooldown : float = 0

var current_turn_speed : float = 0

var target_move_vector : Vector2 = Vector2.ZERO

var is_far_from_home : bool = false

func _ready():
	initial_position = enemy.body.global_position
	current_move_vector = initial_move_vector

func _physics_process(_delta):
	if (!enemy.is_defeated):
		check_if_facing_player()
		check_distance_from_home()
		update_velocity_vector(_delta)

func _process(delta):
	update_current_turning_cooldown(delta)

func set_move_vector(vector : Vector2):
	current_move_vector = vector
	target_move_vector = vector
	current_turn_speed = 0
	set_facing_direction(vector.x)

func flip_movement(override_cooldown : bool = false):
	if (!override_cooldown and is_turning_cooldown_active()):
		return
	
	if (current_move_vector.x != 0):
		current_move_vector *= -1
		set_facing_direction(current_move_vector.x)
	else:
		set_facing_direction(-get_facing_value())

func turn_movement(speed : float, override_cooldown : bool = false):
	if (!override_cooldown and is_turning_cooldown_active()):
		return
	
	if (current_move_vector.x != 0 or current_move_vector.y != 0):
		target_move_vector = -current_move_vector
		current_turn_speed = speed
		set_facing_direction(-current_move_vector.x)
	else:
		set_facing_direction(-get_facing_value())

func face_towards_player(override_cooldown : bool = false):
	var towards_direction = enemy.player_detection.get_direction_to_player()
	if ((get_facing_value() * towards_direction) < 0):
		flip_movement(override_cooldown)

func face_away_from_player(override_cooldown : bool = false):
	var away_direction = -enemy.player_detection.get_direction_to_player()
	if ((get_facing_value() * away_direction) < 0):
		flip_movement(override_cooldown)

func set_facing_direction(horizontal_direction : float):
	if (horizontal_direction != 0):
		var previous_flip_h = enemy.sprite.flip_h
		enemy.sprite.flip_h = (horizontal_direction < 0)
		if (turning_cooldown_time > 0 and ((previous_flip_h and !enemy.sprite.flip_h) or (!previous_flip_h and enemy.sprite.flip_h))):
			set_turning_cooldown();

func get_facing_value():
	return (-1.0 if enemy.sprite.flip_h else 1.0)

func get_normalized_x_movement():
	if (current_move_vector.x != 0):
		return (-1.0 if current_move_vector.x < 0 else 1.0)
	else:
		return get_facing_value()

func reset_to_initial_position():
	enemy.body.global_position = initial_position

func reset_to_initial_move_vector():
	set_move_vector(initial_move_vector)

func check_distance_from_home():
	if (!enemy.is_defeated):
		var current_distance_from_home : float = initial_position.distance_to(enemy.body.global_position)
		if (current_distance_from_home >= max_distance_from_init_pos and !is_far_from_home):
			is_far_from_home = true
			far_from_home.emit()
		elif (current_distance_from_home < max_distance_from_init_pos):
			is_far_from_home = false
		else:
			pass

func check_if_facing_player():
	if (!enemy.is_defeated and is_always_facing_player):
		face_towards_player()

func update_velocity_vector(delta : float):
	if (current_turn_speed != 0):
		current_move_vector.x = move_toward(current_move_vector.x, target_move_vector.x, current_turn_speed * delta)
		if (!ignore_y_value):
			current_move_vector.y = move_toward(current_move_vector.y, target_move_vector.y, current_turn_speed * delta)
		if (current_move_vector == target_move_vector):
			current_turn_speed = 0
	
	enemy.body.velocity = (Vector2(current_move_vector.x, enemy.body.velocity.y) if ignore_y_value else current_move_vector)
	enemy.body.move_and_slide()

func update_current_turning_cooldown(delta : float):
	if (current_turning_cooldown > 0):
		current_turning_cooldown = move_toward(current_turning_cooldown, 0, delta)

func set_turning_cooldown():
	if (current_turning_cooldown <= 0):
		current_turning_cooldown = turning_cooldown_time

func is_turning_cooldown_active():
	return current_turning_cooldown > 0

func reset_target_speed():
	current_turn_speed = 0
	target_move_vector = Vector2.ZERO
