extends Node

class_name PlayerCollisions

@export var hub : PlayerHub

@export var ground_check_offset : float = 32

func is_moving_against_a_wall():
	var horizontal_movement : Vector2 = (Vector2.RIGHT * hub.movement.current_horizontal_velocity * get_physics_process_delta_time())
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(horizontal_movement, true, hub.char_body.safe_margin)
	return (hub.char_body.is_on_wall() and collide_result != null and collide_result.get_normal().y == 0 and (hub.movement.get_facing_value() * collide_result.get_normal().x < 0))

func is_facing_a_wall():
	var horizontal_movement : Vector2 = (Vector2.RIGHT * hub.movement.get_facing_value() * hub.movement.top_speed * get_physics_process_delta_time())
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(horizontal_movement, true, hub.char_body.safe_margin)
	return (collide_result != null and collide_result != null and collide_result.get_normal().y == 0 and (hub.movement.get_facing_value() * collide_result.get_normal().x < 0))

func get_distance_to_ground():
	var result : float = -1
	if (hub.raycast_2d.is_colliding()):
		result = (hub.char_body.position.distance_to(hub.raycast_2d.get_collision_point())) - ground_check_offset
	else:
		result = (hub.char_body.position.distance_to(hub.raycast_2d.target_position)) - ground_check_offset
	return max(0, result)
