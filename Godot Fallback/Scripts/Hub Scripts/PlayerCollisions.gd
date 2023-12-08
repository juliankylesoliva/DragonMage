extends Node

class_name PlayerCollisions

@export var hub : PlayerHub

@export var ground_check_offset : float = 32

@export var uncrouched_y_offset : float = 8
@export var crouched_y_offset : float = 18
@export var uncrouched_height : float = 48
@export var crouched_height : float = 28

@export var ledge_nudge_check_depth : float = 24
@export var ledge_nudge_easing : float = 0.99

@export_flags_2d_physics var intangible_wall_layer

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

func is_near_a_ledge(ray_num : int = 0):
	return (hub.char_body.is_on_floor() and get_distance_to_ground(ray_num) > hub.char_body.floor_snap_length)

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
		result = (raycast_to_use.global_position.distance_to(raycast_to_use.get_collision_point()))
	else:
		result = 999
	return max(0, result)

func get_ground_point():
	return (hub.raycast_dm.get_collision_point() if hub.raycast_dm.is_colliding() and get_distance_to_ground(0) <= hub.char_body.floor_snap_length else hub.raycast_dm.global_position)

func get_distance_to_ceiling(ray_num : int = 0):
	var raycast_to_use : RayCast2D = (hub.raycast_um if ray_num == 0 else hub.raycast_ul if ray_num < 0 else hub.raycast_ur)
	var result : float = -1
	if (raycast_to_use.is_colliding()):
		result = (raycast_to_use.global_position.distance_to(raycast_to_use.get_collision_point()))
	else:
		result = (raycast_to_use.global_position.distance_to(raycast_to_use.global_position + raycast_to_use.target_position))
	return max(0, result)

func collider_crouch_update():
	hub.collision_shape.shape.height = (crouched_height if hub.movement.is_crouching else uncrouched_height)
	hub.collision_shape.position = Vector2(0, crouched_y_offset if hub.movement.is_crouching else uncrouched_y_offset)
	
	var upper_raycasts_y_pos : float = (hub.collision_shape.position.y - (hub.collision_shape.shape.height / 2))
	hub.raycast_ul.position.y = upper_raycasts_y_pos
	hub.raycast_um.position.y = upper_raycasts_y_pos
	hub.raycast_ur.position.y = upper_raycasts_y_pos
	hub.raycast_ceiling_l.position.y = (upper_raycasts_y_pos - ledge_nudge_check_depth)
	hub.raycast_ceiling_r.position.y = (upper_raycasts_y_pos - ledge_nudge_check_depth)

func do_ledge_nudge():
	if (is_near_a_ledge()):
		var is_left_grounded : bool = (get_distance_to_ground(-1) <= hub.char_body.floor_snap_length)
		var is_middle_grounded : bool = (get_distance_to_ground(0) <= hub.char_body.floor_snap_length)
		var is_right_grounded : bool = (get_distance_to_ground(1) <= hub.char_body.floor_snap_length)
		
		if (!is_middle_grounded and (is_left_grounded or is_right_grounded) and (!is_left_grounded or !is_right_grounded)):
			if (!is_left_grounded and is_right_grounded):
				hub.char_body.position.x += (((hub.raycast_ledge_r.get_collision_point().x if hub.raycast_ledge_r.is_colliding() else hub.raycast_ledge_r.target_position.x) - hub.raycast_ledge_r.global_position.x) * ledge_nudge_easing)
			elif (is_left_grounded and !is_right_grounded):
				hub.char_body.position.x += (((hub.raycast_ledge_l.get_collision_point().x if hub.raycast_ledge_l.is_colliding() else hub.raycast_ledge_l.target_position.x) - hub.raycast_ledge_l.global_position.x) * ledge_nudge_easing)
			else:
				pass

func do_ceiling_nudge():
	if (hub.state_machine.current_state.name == "Jumping" and hub.get_input_vector().x == 0):
		var left_distance : float = get_distance_to_ceiling(-1)
		var middle_distance : float = get_distance_to_ceiling(0)
		var right_distance : float = get_distance_to_ceiling(1)
		
		var raycast_to_use : RayCast2D = null
		var sign_multiplier : float = 0
		
		if (left_distance < middle_distance and left_distance < right_distance):
			raycast_to_use = hub.raycast_ceiling_l
			sign_multiplier = 1
		elif (right_distance < middle_distance and right_distance < left_distance):
			raycast_to_use = hub.raycast_ceiling_r
			sign_multiplier = -1
		else:
			return
		
		if (raycast_to_use != null and sign_multiplier != 0 and raycast_to_use.is_colliding()):
			var total_magnitude : float = raycast_to_use.target_position.length()
			var partial_magnitude : float = (raycast_to_use.global_position.distance_to(raycast_to_use.get_collision_point()) if raycast_to_use.is_colliding() else total_magnitude)
			if (partial_magnitude < total_magnitude):
				hub.char_body.position.x += ((total_magnitude - partial_magnitude) * sign_multiplier)
