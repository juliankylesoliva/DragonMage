extends Resource

class_name PlayerCtrlProperties

@export_subgroup("Running Variables")
@export var acceleration = 25.0
@export var deceleration = 20.0
@export var top_speed = 5.25
@export var turning_speed = 45.0

@export_subgroup("Jumping Variables")
@export var can_change_facing_direction_in_midair = true
@export var enable_speed_hopping = true
@export var speed_hop_slope_boost_threshold : float = 0.4
@export var speed_hop_slope_boost_multiplier : float = 0.5
@export var initial_jump_velocity = 12.0
@export var rising_gravity_scale = 2.2
@export var falling_gravity_scale = 3.8
@export var max_fall_speed = 10.0
@export var air_acceleration = 80.0
@export var air_deceleration = 60.0
@export var air_turning_speed = 70.0

@export_subgroup("Variable Jump Variables")
@export var enable_variable_jumps = true
@export var min_jump_hold_time = 0.05
@export var variable_jump_decay_rate = 95.0

@export_subgroup("Gliding Variables")
@export var enable_gliding = true
@export var min_glide_height = 1.0
@export var glide_fall_speed = 0.75
@export_range(0.0, 5.0) var max_glide_time = 3.0

@export_subgroup("Wall Climb Variables")
@export var enable_wall_climbing = false
@export var min_wall_climb_height = 0.0
@export var min_climbing_speed = 0.0
@export var max_climbing_speed = 0.0
@export var wall_climbing_gravity_scale = 0.0
@export var max_wall_climb_time = 0.0
@export var ledge_snap_distance = 0.0
@export var wall_popup_time = 0.0
@export var min_wall_popup_speed = 0.0
@export var max_wall_popup_speed = 0.0

@export_subgroup("Wall Jump Variables")
@export var enable_wall_jumping = true
@export var min_wall_jump_height = 1.1
@export var wall_slide_speed = 1.8
@export var vertical_wall_jump_velocity = 12.0
@export var horizontal_wall_jump_velocity = 5.25
@export var max_wall_jump_direction_lock_time = 0.3

@export_subgroup("Midair Jump Variables")
@export_range(0, 5) var max_midair_jumps = 0
@export var midair_jump_velocity = 0.0
@export var forward_midair_jump_bonus: Vector2

@export_subgroup("Running Jump Variables")
@export var enable_running_jump = true
@export var running_jump_added_velocity = 1.5

@export_subgroup("Crouching Variables")
@export var enable_crouch_walking = true
@export var crouching_top_speed = 2.625
@export var enable_crouch_jumping = true
@export var enable_super_jumping = false
@export var super_jump_charge_time = 0.0
@export var super_jump_retention_time = 0.0
@export var super_jump_velocity_multiplier = 0.0

@export_subgroup("Fast Falling Variables")
@export var enable_fast_falling : bool = false
@export var fast_fall_threshold : float = 0
@export var fast_falling_speed : float = 0
@export var super_jump_after_fast_fall_time : float = 0
@export var fast_fall_slope_boost_threshold : float = 1
@export var fast_fall_slope_boost_multiplier : float = 0

@export_subgroup("Attack Variables")
@export var standing_attack_name : String = "MagicBlast"
@export var crouching_attack_name : String = "Dodge"
