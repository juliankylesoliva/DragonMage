extends Node

class_name PlayerForm

enum CharacterMode {MAGE, DRAGON}

@export var hub : PlayerHub

@export var enable_form_changing : bool = true

@export var mage_properties : PlayerCtrlProperties
@export var dragon_properties : PlayerCtrlProperties

@export var mage_name : String = "Magli"
@export var dragon_name : String = "Draelyn"

@export var starting_mode : CharacterMode = CharacterMode.MAGE

@export var form_change_time : float = 0.25
@export var form_change_cooldown_time : float = 0.1
@export var form_change_animation_time : float = 0.533

var current_mode : CharacterMode = CharacterMode.MAGE

var current_form_change_timer : float = 0
var current_form_change_cooldown_timer : float = 0

func _ready():
	change_mode(starting_mode)

func _process(delta):
	update_form_change_cooldown_timer(delta)
	update_form_change_timer(delta)

func is_changing_form():
	return (current_form_change_timer > 0)

func is_form_change_cooldown_active():
	return (current_form_change_cooldown_timer > 0)

func can_change_form():
	return (enable_form_changing and !is_form_change_cooldown_active() and !hub.attacks.is_attack_cooldown_active() and hub.state_machine.current_state.name != "FormChanging" and hub.state_machine.current_state.name != "Attacking" and hub.buffers.is_form_change_buffer_active())

func cannot_change_form():
	return false

func do_form_change():
	hub.animation.set_animation("{name1}To{name2}".format({"name1" : get_current_form_name(), "name2" : get_opposite_form_name()}))
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(form_change_animation_time / form_change_time)
	
	change_mode(CharacterMode.DRAGON if current_mode == CharacterMode.MAGE else CharacterMode.MAGE)

func form_change_failed():
	pass

func set_ctrl_properties(p : PlayerCtrlProperties):
	hub.movement.acceleration = p.acceleration
	hub.movement.deceleration = p.deceleration
	hub.movement.top_speed = p.top_speed
	hub.movement.turning_speed = p.turning_speed
	
	hub.movement.can_change_facing_direction_in_midair = p.can_change_facing_direction_in_midair
	hub.jumping.enable_speed_hopping = p.enable_speed_hopping
	hub.jumping.speed_hop_slope_boost_threshold = p.speed_hop_slope_boost_threshold
	hub.jumping.speed_hop_slope_boost_multiplier = p.speed_hop_slope_boost_multiplier
	hub.jumping.initial_jump_velocity = p.initial_jump_velocity
	hub.jumping.rising_gravity_scale = p.rising_gravity_scale
	hub.jumping.falling_gravity_scale = p.falling_gravity_scale
	hub.jumping.max_fall_speed = p.max_fall_speed
	hub.movement.air_acceleration = p.air_acceleration
	hub.movement.air_deceleration = p.air_deceleration
	hub.movement.air_turning_speed = p.air_turning_speed
	
	hub.jumping.enable_variable_jumps = p.enable_variable_jumps
	hub.jumping.min_jump_hold_time = p.min_jump_hold_time
	hub.jumping.variable_jump_decay_rate = p.variable_jump_decay_rate
	
	hub.jumping.max_out_min_jump_hold_timer()
	
	hub.jumping.enable_gliding = p.enable_gliding
	hub.jumping.min_glide_height = p.min_glide_height
	hub.jumping.glide_fall_speed = p.glide_fall_speed
	hub.jumping.max_glide_time = p.max_glide_time
	
	if (hub.jumping.enable_gliding and hub.jumping.current_glide_time > hub.buffers.early_glide_buffer_time and hub.jumping.max_glide_time > 0):
		hub.jumping.current_glide_time = hub.jumping.max_glide_time
	
	hub.jumping.enable_wall_climbing = p.enable_wall_climbing
	hub.jumping.min_wall_climb_height = p.min_wall_climb_height
	hub.jumping.min_climbing_speed = p.min_climbing_speed
	hub.jumping.max_climbing_speed = p.max_climbing_speed
	hub.jumping.wall_climbing_gravity_scale = p.wall_climbing_gravity_scale
	hub.jumping.max_wall_climb_time = p.max_wall_climb_time
	hub.jumping.ledge_snap_distance = p.ledge_snap_distance
	hub.jumping.wall_popup_time = p.wall_popup_time
	hub.jumping.min_wall_popup_speed = p.min_wall_popup_speed
	hub.jumping.max_wall_popup_speed = p.max_wall_popup_speed
	
	if (hub.jumping.enable_wall_climbing):
		if (hub.jumping.current_wall_climb_time > 0 and hub.jumping.max_wall_climb_time):
			hub.jumping.current_wall_climb_time = hub.jumping.max_wall_climb_time
		if (hub.jumping.stored_wall_climb_speed > 0):
			hub.jumping.stored_wall_climb_speed = 0
		if (hub.jumping.wall_popup_time_left > 0):
			hub.jumping.wall_popup_time_left = 0
	
	hub.jumping.enable_wall_jumping = p.enable_wall_jumping
	hub.jumping.min_wall_jump_height = p.min_wall_jump_height
	hub.jumping.wall_slide_speed = p.wall_slide_speed
	hub.jumping.vertical_wall_jump_velocity = p.vertical_wall_jump_velocity
	hub.jumping.horizontal_wall_jump_velocity = p.horizontal_wall_jump_velocity
	hub.jumping.max_wall_jump_direction_lock_time = p.max_wall_jump_direction_lock_time
	
	hub.jumping.max_midair_jumps = p.max_midair_jumps
	hub.jumping.midair_jump_velocity = p.midair_jump_velocity
	hub.jumping.forward_midair_jump_bonus = p.forward_midair_jump_bonus
	
	hub.jumping.enable_running_jump = p.enable_running_jump
	hub.jumping.running_jump_added_velocity = p.running_jump_added_velocity
	
	hub.movement.enable_crouch_walking = p.enable_crouch_walking
	hub.movement.crouching_top_speed = p.crouching_top_speed
	hub.jumping.enable_crouch_jumping = p.enable_crouch_jumping
	
	if (!hub.jumping.enable_crouch_jumping and hub.movement.is_crouching and !hub.char_body.is_on_floor()):
		hub.movement.reset_crouch_state()
	
	hub.jumping.enable_super_jumping = p.enable_super_jumping
	hub.jumping.super_jump_charge_time = p.super_jump_charge_time
	hub.jumping.super_jump_retention_time = p.super_jump_retention_time
	hub.jumping.super_jump_velocity_multiplier = p.super_jump_velocity_multiplier
	
	if (!hub.jumping.enable_super_jumping):
		hub.jumping.reset_super_jump_timers()
	
	hub.jumping.enable_fast_falling = p.enable_fast_falling
	hub.jumping.fast_fall_threshold = p.fast_fall_threshold
	hub.jumping.fast_falling_speed = p.fast_falling_speed
	hub.jumping.super_jump_after_fast_fall_time = p.super_jump_after_fast_fall_time
	hub.jumping.fast_fall_slope_boost_threshold = p.fast_fall_slope_boost_threshold
	hub.jumping.fast_fall_slope_boost_multiplier = p.fast_fall_slope_boost_multiplier
	
	hub.attacks.standing_attack_name = p.standing_attack_name
	hub.attacks.crouching_attack_name = p.crouching_attack_name

func change_mode(mode : CharacterMode):
	set_ctrl_properties(mage_properties if mode == CharacterMode.MAGE else dragon_properties)
	current_mode = mode

func start_form_change_timer():
	if (!is_changing_form()):
		current_form_change_timer = form_change_time

func update_form_change_timer(delta : float):
	if (current_form_change_timer > 0):
		current_form_change_timer = move_toward(current_form_change_timer, 0, delta)

func start_form_change_cooldown_timer():
	if (!is_form_change_cooldown_active()):
		current_form_change_cooldown_timer = form_change_cooldown_time

func update_form_change_cooldown_timer(delta : float):
	if (current_form_change_cooldown_timer > 0):
		current_form_change_cooldown_timer = move_toward(current_form_change_cooldown_timer, 0, delta)

func get_current_form_name():
	return mage_name if current_mode == CharacterMode.MAGE else dragon_name

func get_opposite_form_name():
	return dragon_name if current_mode == CharacterMode.MAGE else mage_name
