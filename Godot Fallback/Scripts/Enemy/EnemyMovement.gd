extends Node

class_name EnemyMovement

@export var enemy : Enemy

@export var initial_move_vector : Vector2

@export var turning_cooldown_time : float = 0

@export var ignore_y_value : bool = true

@export var is_always_facing_player : bool = true

var initial_position : Vector2 = Vector2.ZERO

var current_move_vector : Vector2 = Vector2.ZERO

var current_turning_cooldown : float = 0

func _ready():
	initial_position = enemy.body.global_position
	current_move_vector = initial_move_vector

func _physics_process(_delta):
	if (!enemy.is_defeated):
		check_if_facing_player()
		update_velocity_vector()

func _process(delta):
	update_current_turning_cooldown(delta)

func set_move_vector(vector : Vector2):
	current_move_vector = vector
	set_facing_direction(vector.x)

func flip_movement(override_cooldown : bool = false):
	if (!override_cooldown and is_turning_cooldown_active()):
		return
	
	if (current_move_vector.x != 0):
		current_move_vector *= -1
		set_facing_direction(current_move_vector.x)
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

func check_if_facing_player():
	if (is_always_facing_player):
		face_towards_player()

func update_velocity_vector():
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
