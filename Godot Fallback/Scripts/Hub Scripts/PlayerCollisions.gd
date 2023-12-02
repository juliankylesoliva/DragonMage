extends Node

class_name PlayerCollisions

@export var hub : PlayerHub

@export var ground_check_offset : float = 32

@export var uncrouched_y_offset : float = 8
@export var crouched_y_offset : float = 18
@export var uncrouched_height : float = 48
@export var crouched_height : float = 28

@export var ledge_nudge_easing : float = 0.99

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

func is_near_a_ledge():
	return (hub.char_body.is_on_floor() and (get_distance_to_ground(hub.movement.get_facing_value()) > hub.char_body.floor_snap_length or get_distance_to_ground() > hub.char_body.floor_snap_length or get_distance_to_ground(-hub.movement.get_facing_value()) > hub.char_body.floor_snap_length))

func is_in_ceiling_when_uncrouched():
	if (!hub.movement.is_crouching):
		return false
	
	var test_movement : Vector2 = (Vector2.UP * ground_check_offset)
	var collide_result : KinematicCollision2D = hub.char_body.move_and_collide(test_movement, true, hub.char_body.safe_margin)
	return (collide_result != null)

func get_distance_to_ground(ray_num : int = 0):
	var raycast_to_use : RayCast2D = (hub.raycast_dm if ray_num == 0 else hub.raycast_dl if ray_num < 0 else hub.raycast_dr)
	var result : float = -1
	if (raycast_to_use.is_colliding()):
		result = (hub.char_body.position.distance_to(raycast_to_use.get_collision_point())) - ground_check_offset
	else:
		result = (hub.char_body.position.distance_to(raycast_to_use.target_position)) - ground_check_offset
	return max(0, result)

func collider_crouch_update():
	hub.collision_shape.shape.height = (crouched_height if hub.movement.is_crouching else uncrouched_height)
	hub.collision_shape.position = Vector2(0, crouched_y_offset if hub.movement.is_crouching else uncrouched_y_offset)

func do_ledge_nudge():
	if (is_near_a_ledge()):
		var is_left_grounded : bool = (get_distance_to_ground(-1) <= hub.char_body.floor_snap_length)
		var is_right_grounded : bool = (get_distance_to_ground(1) <= hub.char_body.floor_snap_length)
		
		if ((is_left_grounded or is_right_grounded) and (!is_left_grounded or !is_right_grounded)):
			if (!is_left_grounded and is_right_grounded):
				hub.char_body.position.x += (((hub.raycast_ledge_r.get_collision_point().x if hub.raycast_ledge_r.is_colliding() else hub.raycast_ledge_r.target_position.x) - hub.raycast_ledge_r.global_position.x) * ledge_nudge_easing)
			elif (is_left_grounded and !is_right_grounded):
				hub.char_body.position.x += (((hub.raycast_ledge_l.get_collision_point().x if hub.raycast_ledge_l.is_colliding() else hub.raycast_ledge_l.target_position.x) - hub.raycast_ledge_l.global_position.x) * ledge_nudge_easing)
			else:
				pass
