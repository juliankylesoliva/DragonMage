extends Node

class_name PlayerCollisions

@export var hub : PlayerHub

@export var ground_check_offset : float = 32

@export var uncrouched_y_offset : float = 8
@export var crouched_y_offset : float = 18
@export var uncrouched_height : float = 48
@export var crouched_height : float = 28

@export var ceiling_nudge_check_depth : float = 32
@export var ledge_nudge_check_depth : float = 24
@export var ledge_nudge_easing : float = 0.99
@export var max_nudge_distance : float = 8

@export var wall_raycast_collision_threshold : int = 2
@export var intangible_wall_raycast_collision_threshold : int = 1
@export var capsule_curve_offset : float = 6

@export var max_upward_slope_correction_iterations : float = 16

func _process(_delta):
	collider_crouch_update()

func is_moving_against_a_wall():
	var total_collisions : int = 0
	var direction : float = (1 if hub.char_body.velocity.x > 0 else -1 if hub.char_body.velocity.x < 0 else hub.get_input_vector().x)
	
	if (direction > 0):
		hub.raycast_wall_top_r.force_raycast_update()
		hub.raycast_wall_mid_r.force_raycast_update()
		hub.raycast_wall_bot_r.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_r.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_top_r) and hub.raycast_wall_top_r.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if hub.raycast_wall_mid_r.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_mid_r) and hub.raycast_wall_mid_r.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_r.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_bot_r) and hub.raycast_wall_bot_r.get_collision_normal().y == 0 else 0)
	elif (direction < 0):
		hub.raycast_wall_top_l.force_raycast_update()
		hub.raycast_wall_mid_l.force_raycast_update()
		hub.raycast_wall_bot_l.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_l.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_top_l) and hub.raycast_wall_top_l.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if hub.raycast_wall_mid_l.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_mid_l) and hub.raycast_wall_mid_l.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_l.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_bot_l) and hub.raycast_wall_bot_l.get_collision_normal().y == 0 else 0)
	else:
		pass
	
	return (total_collisions >= wall_raycast_collision_threshold)

func is_facing_a_wall():
	var total_collisions : int = 0
	
	if (hub.movement.get_facing_value() > 0):
		hub.raycast_wall_top_r.force_raycast_update()
		hub.raycast_wall_mid_r.force_raycast_update()
		hub.raycast_wall_bot_r.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_r.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_top_r) and hub.raycast_wall_top_r.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if hub.raycast_wall_mid_r.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_mid_r) and hub.raycast_wall_mid_r.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_r.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_bot_r) and hub.raycast_wall_bot_r.get_collision_normal().y == 0 else 0)
	elif (hub.movement.get_facing_value() < 0):
		hub.raycast_wall_top_l.force_raycast_update()
		hub.raycast_wall_mid_l.force_raycast_update()
		hub.raycast_wall_bot_l.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_l.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_top_l) and hub.raycast_wall_top_l.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if hub.raycast_wall_mid_l.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_mid_l) and hub.raycast_wall_mid_l.get_collision_normal().y == 0 else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_l.is_colliding() and !is_raycast_in_semisolid(hub.raycast_wall_bot_l) and hub.raycast_wall_bot_l.get_collision_normal().y == 0 else 0)
	else:
		pass
	
	return (total_collisions >= wall_raycast_collision_threshold)

func is_moving_against_an_intangible_wall():
	var total_collisions : int = 0
	var direction : float = (1 if hub.char_body.velocity.x > 0 else -1 if hub.char_body.velocity.x < 0 else hub.get_input_vector().x)
	
	if (direction > 0):
		hub.raycast_wall_top_r.force_raycast_update()
		hub.raycast_wall_mid_r.force_raycast_update()
		hub.raycast_wall_bot_r.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_r.is_colliding() and hub.raycast_wall_top_r.get_collision_normal().y == 0 and hub.raycast_wall_top_r.get_collider().has_meta("Tag") and hub.raycast_wall_top_r.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if hub.raycast_wall_mid_r.is_colliding() and hub.raycast_wall_mid_r.get_collision_normal().y == 0 and hub.raycast_wall_mid_r.get_collider().has_meta("Tag") and hub.raycast_wall_mid_r.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_r.is_colliding() and hub.raycast_wall_bot_r.get_collision_normal().y == 0 and hub.raycast_wall_bot_r.get_collider().has_meta("Tag") and hub.raycast_wall_bot_r.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
	elif (direction < 0):
		hub.raycast_wall_top_l.force_raycast_update()
		hub.raycast_wall_mid_l.force_raycast_update()
		hub.raycast_wall_bot_l.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_l.is_colliding() and hub.raycast_wall_top_l.get_collision_normal().y == 0 and hub.raycast_wall_top_l.get_collider().has_meta("Tag") and hub.raycast_wall_top_l.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if hub.raycast_wall_mid_l.is_colliding() and hub.raycast_wall_mid_l.get_collision_normal().y == 0 and hub.raycast_wall_mid_l.get_collider().has_meta("Tag") and hub.raycast_wall_mid_l.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_l.is_colliding() and hub.raycast_wall_bot_l.get_collision_normal().y == 0 and hub.raycast_wall_bot_l.get_collider().has_meta("Tag") and hub.raycast_wall_bot_l.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
	else:
		pass
	
	return (total_collisions >= intangible_wall_raycast_collision_threshold)

func is_facing_an_intangible_wall():
	var total_collisions : int = 0
	
	if (hub.movement.get_facing_value() > 0):
		hub.raycast_wall_top_r.force_raycast_update()
		hub.raycast_wall_mid_r.force_raycast_update()
		hub.raycast_wall_bot_r.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_r.is_colliding() and hub.raycast_wall_top_r.get_collision_normal().y == 0 and hub.raycast_wall_top_r.get_collider().has_meta("Tag") and hub.raycast_wall_top_r.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if hub.raycast_wall_mid_r.is_colliding() and hub.raycast_wall_mid_r.get_collision_normal().y == 0 and hub.raycast_wall_mid_r.get_collider().has_meta("Tag") and hub.raycast_wall_mid_r.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_r.is_colliding() and hub.raycast_wall_bot_r.get_collision_normal().y == 0 and hub.raycast_wall_bot_r.get_collider().has_meta("Tag") and hub.raycast_wall_bot_r.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
	elif (hub.movement.get_facing_value() < 0):
		hub.raycast_wall_top_l.force_raycast_update()
		hub.raycast_wall_mid_l.force_raycast_update()
		hub.raycast_wall_bot_l.force_raycast_update()
		
		total_collisions += (1 if hub.raycast_wall_top_l.is_colliding() and hub.raycast_wall_top_l.get_collision_normal().y == 0 and hub.raycast_wall_top_l.get_collider().has_meta("Tag") and hub.raycast_wall_top_l.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if hub.raycast_wall_mid_l.is_colliding() and hub.raycast_wall_mid_l.get_collision_normal().y == 0 and hub.raycast_wall_mid_l.get_collider().has_meta("Tag") and hub.raycast_wall_mid_l.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
		total_collisions += (1 if !hub.char_body.is_on_floor() and hub.raycast_wall_bot_l.is_colliding() and hub.raycast_wall_bot_l.get_collision_normal().y == 0 and hub.raycast_wall_bot_l.get_collider().has_meta("Tag") and hub.raycast_wall_bot_l.get_collider().get_meta("Tag") == "IntangibleWall" else 0)
	else:
		pass
	
	return (total_collisions >= intangible_wall_raycast_collision_threshold)

func is_raycast_in_semisolid(ray : RayCast2D):
	if (ray.is_colliding()):
		var target = ray.get_collider()
		if (target.has_method("shape_find_owner")):
			var shape_id = ray.get_collider_shape()
			var owner_id = target.shape_find_owner(shape_id)
			var shape = target.shape_owner_get_owner(owner_id)
			return shape.one_way_collision
	return false

func is_on_a_moving_platform():
	return (hub.char_body.is_on_floor() and hub.char_body.get_platform_velocity() != Vector2.ZERO)

func is_near_a_ledge(ray_num : int = 0):
	return (hub.char_body.is_on_floor() and get_distance_to_ground(ray_num) > hub.char_body.floor_snap_length)

func is_in_ceiling_when_uncrouched():
	if (!hub.movement.is_crouching):
		return false
	return (get_distance_to_ceiling() <= (uncrouched_height - crouched_height) and !is_raycast_in_semisolid(hub.raycast_um))

func get_distance_to_ground(ray_num : int = 0):
	var raycast_to_use : RayCast2D = (hub.raycast_dm if ray_num == 0 else hub.raycast_dl if ray_num < 0 else hub.raycast_dr)
	var result : float = -1
	raycast_to_use.force_raycast_update()
	if (raycast_to_use.is_colliding()):
		result = abs(raycast_to_use.global_position.y - raycast_to_use.get_collision_point().y)
	else:
		result = 999
	return max(0, result)

func get_ground_point():
	return (hub.raycast_dm.get_collision_point() if hub.raycast_dm.is_colliding() and get_distance_to_ground(0) <= hub.char_body.floor_snap_length else hub.raycast_dm.global_position)

func get_ground_normal():
	return (hub.raycast_dm.get_collision_normal() if hub.raycast_dm.is_colliding() and get_distance_to_ground(0) <= hub.char_body.floor_snap_length else hub.char_body.up_direction)

func get_distance_to_ceiling(ray_num : int = 0):
	var raycast_to_use : RayCast2D = (hub.raycast_um if ray_num == 0 else hub.raycast_ul if ray_num < 0 else hub.raycast_ur)
	var result : float = -1
	if (raycast_to_use.is_colliding()):
		result = abs(raycast_to_use.global_position.y - raycast_to_use.get_collision_point().y)
	else:
		result = abs(raycast_to_use.global_position.y - (raycast_to_use.global_position + raycast_to_use.target_position).y)
	return max(0, result)

func get_ceiling_point():
	return (hub.raycast_um.get_collision_point() if hub.raycast_um.is_colliding() and get_distance_to_ceiling(0) <= hub.char_body.floor_snap_length else hub.raycast_um.global_position)

func get_ceiling_normal():
	return (hub.raycast_um.get_collision_normal() if hub.raycast_um.is_colliding() else -hub.char_body.up_direction)

func collider_crouch_update():
	hub.collision_shape.shape.height = (crouched_height if hub.movement.is_crouching else uncrouched_height)
	hub.collision_shape.position = Vector2(0, crouched_y_offset if hub.movement.is_crouching else uncrouched_y_offset)
	
	var upper_raycasts_y_pos : float = (hub.collision_shape.position.y - (hub.collision_shape.shape.height / 2))
	hub.raycast_ul.position.y = upper_raycasts_y_pos
	hub.raycast_um.position.y = upper_raycasts_y_pos
	hub.raycast_ur.position.y = upper_raycasts_y_pos
	
	hub.raycast_ceiling_l.position.y = (upper_raycasts_y_pos - ledge_nudge_check_depth)
	hub.raycast_ceiling_r.position.y = (upper_raycasts_y_pos - ledge_nudge_check_depth)
	
	hub.raycast_wall_top_l.position.y = (upper_raycasts_y_pos + capsule_curve_offset)
	hub.raycast_wall_top_r.position.y = (upper_raycasts_y_pos + capsule_curve_offset)
	hub.raycast_wall_mid_l.position.y = hub.collision_shape.position.y
	hub.raycast_wall_mid_r.position.y = hub.collision_shape.position.y

func do_ledge_nudge(custom_ease : float = 0):
	if (is_near_a_ledge() and !is_on_a_moving_platform() and get_ground_normal().x == 0):
		var is_left_grounded : bool = (get_distance_to_ground(-1) <= hub.char_body.floor_snap_length)
		var is_middle_grounded : bool = (get_distance_to_ground(0) <= hub.char_body.floor_snap_length)
		var is_right_grounded : bool = (get_distance_to_ground(1) <= hub.char_body.floor_snap_length)
		
		if (!is_middle_grounded and (is_left_grounded or is_right_grounded) and (!is_left_grounded or !is_right_grounded)):
			if (!is_left_grounded and is_right_grounded and hub.get_input_vector().x >= 0):
				var calculated_nudge_distance : float = (((hub.raycast_ledge_r.get_collision_point().x if hub.raycast_ledge_r.is_colliding() else hub.raycast_ledge_r.target_position.x) - hub.raycast_ledge_r.global_position.x) * (ledge_nudge_easing if custom_ease <= 0 else abs(custom_ease)))
				hub.char_body.position.x += (calculated_nudge_distance if calculated_nudge_distance > 0 and calculated_nudge_distance <= max_nudge_distance else max_nudge_distance)
			elif (is_left_grounded and !is_right_grounded and hub.get_input_vector().x <= 0):
				var calculated_nudge_distance = (((hub.raycast_ledge_l.get_collision_point().x if hub.raycast_ledge_l.is_colliding() else hub.raycast_ledge_l.target_position.x) - hub.raycast_ledge_l.global_position.x) * (ledge_nudge_easing if custom_ease <= 0 else abs(custom_ease)))
				hub.char_body.position.x += (calculated_nudge_distance if calculated_nudge_distance < 0 and calculated_nudge_distance >= -max_nudge_distance else -max_nudge_distance)
			else:
				pass

func do_ceiling_nudge():
	if (hub.state_machine.current_state.name == "Jumping" and hub.get_input_vector().x == 0 and (get_ceiling_normal().x == 0 or get_distance_to_ceiling(0) > ceiling_nudge_check_depth)):
		var left_distance : float = get_distance_to_ceiling(-1)
		var middle_distance : float = get_distance_to_ceiling(0)
		var right_distance : float = get_distance_to_ceiling(1)
		
		var raycast_to_use : RayCast2D = null
		var sign_multiplier : float = 0
		
		if (left_distance < middle_distance and left_distance < right_distance and ((middle_distance - left_distance) >= ceiling_nudge_check_depth or (right_distance - left_distance) >= ceiling_nudge_check_depth)):
			raycast_to_use = hub.raycast_ceiling_l
			sign_multiplier = 1
		elif (right_distance < middle_distance and right_distance < left_distance and ((middle_distance - right_distance) >= ceiling_nudge_check_depth or (left_distance - right_distance) >= ceiling_nudge_check_depth)):
			raycast_to_use = hub.raycast_ceiling_r
			sign_multiplier = -1
		else:
			return
		
		if (raycast_to_use != null and sign_multiplier != 0 and raycast_to_use.is_colliding() and !is_raycast_in_semisolid(raycast_to_use)):
			var total_magnitude : float = raycast_to_use.target_position.length()
			var partial_magnitude : float = (raycast_to_use.global_position.distance_to(raycast_to_use.get_collision_point()) if raycast_to_use.is_colliding() else total_magnitude)
			if (partial_magnitude < total_magnitude):
				var calculated_nudge_distance : float = ((total_magnitude - partial_magnitude) * sign_multiplier)
				hub.char_body.position.x += (calculated_nudge_distance if abs(calculated_nudge_distance) <= max_nudge_distance else (max_nudge_distance * sign_multiplier))

func magic_blast_jump_velocity_retention(intended_velocity : Vector2):
	if (hub.jumping.magic_blast_attack.is_blast_jumping and ((hub.char_body.is_on_floor() and intended_velocity.y > hub.jumping.max_fall_speed) or (hub.char_body.is_on_ceiling() and intended_velocity.y < 0) or (hub.char_body.is_on_wall() and is_moving_against_a_wall() and intended_velocity.x != 0))):
		hub.char_body.velocity = intended_velocity

func upward_slope_correction(intended_velocity : Vector2):
	var num_iters : int = 0
	
	while (num_iters < max_upward_slope_correction_iterations and hub.char_body.is_on_floor() and hub.char_body.is_on_wall() and hub.char_body.velocity.x == 0 and intended_velocity.x != hub.char_body.velocity.x and !hub.collisions.is_facing_a_wall() and !hub.collisions.is_moving_against_a_wall()):
		num_iters += 1
		hub.char_body.velocity = intended_velocity
		hub.char_body.global_translate(hub.char_body.up_direction)
		hub.char_body.move_and_slide()
	
	if (num_iters > 0):
		print_debug("Upward slope correction engaged {num} time(s)!".format({"num" : num_iters}))

func turnaround_wall_stop_correction():
	if ((hub.char_body.is_on_wall() or is_near_a_ledge(-hub.get_input_vector().x)) and (hub.get_input_vector().x * hub.char_body.velocity.x) <= 0 and abs(hub.movement.current_horizontal_velocity) > hub.movement.top_speed):
		hub.movement.current_horizontal_velocity = (hub.movement.top_speed if hub.movement.current_horizontal_velocity >= 0 else -hub.movement.top_speed)
		hub.char_body.velocity.x = hub.movement.current_horizontal_velocity
