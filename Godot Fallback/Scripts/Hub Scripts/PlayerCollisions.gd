extends Node

class_name PlayerCollisions

@export var hub : PlayerHub

@export var ground_check_offset : float = 32

@export var uncrouched_y_offset : float = 8
@export var crouched_y_offset : float = 18
@export var uncrouched_height : float = 48
@export var crouched_height : float = 28

func _process(_delta):
	collider_crouch_update()

func is_moving_against_a_wall():
	var horizontal_movement : Vector2 = (Vector2.RIGHT * hub.movement.current_horizontal_velocity * get_physics_process_delta_time())
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(horizontal_movement, true, hub.char_body.safe_margin)
	return (hub.char_body.is_on_wall() and collide_result != null and collide_result.get_normal().y == 0 and (hub.movement.current_horizontal_velocity * collide_result.get_normal().x < 0))

func is_facing_a_wall():
	var horizontal_movement : Vector2 = (Vector2.RIGHT * hub.movement.get_facing_value() * hub.movement.top_speed * get_physics_process_delta_time())
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(horizontal_movement, true, hub.char_body.safe_margin)
	return (collide_result != null and collide_result.get_normal().y == 0 and (hub.movement.get_facing_value() * collide_result.get_normal().x < 0))

func is_in_ceiling_when_uncrouched():
	if (!hub.movement.is_crouching):
		return false
	
	var test_movement : Vector2 = (Vector2.UP * ground_check_offset)
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(test_movement, true, hub.char_body.safe_margin)
	return (collide_result != null)

func get_distance_to_ground():
	var result : float = -1
	if (hub.raycast_2d.is_colliding()):
		result = (hub.char_body.position.distance_to(hub.raycast_2d.get_collision_point())) - ground_check_offset
	else:
		result = (hub.char_body.position.distance_to(hub.raycast_2d.target_position)) - ground_check_offset
	return max(0, result)

func collider_crouch_update():
	hub.collision_shape.shape.height = (crouched_height if hub.movement.is_crouching else uncrouched_height)
	hub.collision_shape.position = Vector2(0, crouched_y_offset if hub.movement.is_crouching else uncrouched_y_offset)
