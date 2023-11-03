extends Node

class_name PlayerCollisions

@export var hub : PlayerHub

func is_moving_against_a_wall():
	var horizontal_movement : Vector2 = (Vector2.RIGHT * hub.movement.current_horizontal_velocity * get_physics_process_delta_time())
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(horizontal_movement, true, hub.char_body.safe_margin)
	return (hub.char_body.is_on_wall() and collide_result != null and collide_result.get_normal().y == 0 and (hub.movement.get_facing_value() * collide_result.get_normal().x < 0))

func is_facing_a_wall():
	var horizontal_movement : Vector2 = (Vector2.RIGHT * hub.movement.get_facing_value() * hub.movement.top_speed * get_physics_process_delta_time())
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(horizontal_movement, true, hub.char_body.safe_margin)
	return (collide_result != null and collide_result != null and collide_result.get_normal().y == 0 and (hub.movement.get_facing_value() * collide_result.get_normal().x < 0))
