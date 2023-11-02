extends Node

class_name PlayerJumping

@export var hub : PlayerHub

@export_group("Standard Jump Parameters")

## Affects how fast this character initially jumps from the ground.
@export var initial_jump_velocity : float = 12

## Affects how strong gravity is on this character while rising.
@export var rising_gravity_scale : float = 2.2

## Affects how strong gravity is on this character while falling.
@export var falling_gravity_scale : float = 3.8

## This character's terminal velocity while falling.
@export var max_fall_speed : float = 10

@export_group("Variable Jump Parameters")

## When enabled, this character's jump height is determined by how long the jump button is held down.
@export var enable_variable_jumps : bool = true

## Used to set a minimum jump height or allow the player to hold the jump button after a bounce.
@export var min_jump_hold_time : float = 0.05

## Affects how quickly this character's vertical velocity goes to zero when the jump button is released.
@export var variable_jump_decay_rate : float = 95

var current_min_jump_hold_timer : float = 0

var is_jump_held : bool = false

@export_group("Running Jump Parameters")

## When enabled, this character's jump velocity will increase by a small amount depending on their horizontal speed.
@export var enable_running_jump : bool = true

## The amount of added jump velocity at top speed.
@export var running_jump_added_velocity : float = 1.5

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity_scale : float = 1

func _ready():
	current_gravity_scale = falling_gravity_scale

func update_min_jump_hold_timer(delta : float):
	current_min_jump_hold_timer = move_toward(current_min_jump_hold_timer, min_jump_hold_time, delta)

func reset_min_jump_hold_timer():
	current_min_jump_hold_timer = 0

func max_out_min_jump_hold_timer():
	current_min_jump_hold_timer = min_jump_hold_time

func set_is_jump_held():
	is_jump_held = true

func unset_is_jump_held():
	is_jump_held = false

func can_ground_jump():
	return (hub.buffers.is_jump_buffer_active() and (hub.char_body.is_on_floor() or hub.buffers.is_coyote_time_active()))

func start_ground_jump():
	hub.buffers.reset_jump_buffer()
	set_is_jump_held()
	switch_to_rising_gravity()
	
	reset_min_jump_hold_timer()
	
	var horizontal_result = abs(hub.char_body.velocity.x)
	
	var running_jump_result = (min((horizontal_result / hub.movement.top_speed), 1) * running_jump_added_velocity if enable_running_jump else 0)
	
	hub.animation.set_animation("MagliJump")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(0)
	
	hub.char_body.velocity.x = (horizontal_result * hub.movement.get_facing_value())
	hub.char_body.velocity.y = -(initial_jump_velocity + running_jump_result)

func ground_jump_update(delta : float):
	if (hub.char_body.velocity.y < 0):
		hub.char_body.velocity.y += get_gravity_delta(delta)
		
		if (current_min_jump_hold_timer >= min_jump_hold_time and is_jump_held and Input.get_action_strength("Jump") == 0):
			unset_is_jump_held()
		
		if ((is_jump_held or current_min_jump_hold_timer < min_jump_hold_time) and hub.char_body.is_on_ceiling()):
			unset_is_jump_held()
			max_out_min_jump_hold_timer()
			hub.char_body.velocity.x = (min(abs(hub.char_body.velocity.x), hub.movement.top_speed) * hub.movement.get_facing_value())
			hub.char_body.velocity.y = 0
		
		if (enable_variable_jumps and !is_jump_held && current_min_jump_hold_timer >= min_jump_hold_time):
			hub.char_body.velocity.y = move_toward(hub.char_body.velocity.y, 0, variable_jump_decay_rate * delta)
		
		update_min_jump_hold_timer(delta)

func falling_update(delta : float):
	hub.char_body.velocity.y += get_gravity_delta(delta)
	if (hub.char_body.velocity.y > max_fall_speed):
		hub.char_body.velocity.y = max_fall_speed

func get_gravity_delta(delta : float):
	return (base_gravity * current_gravity_scale * delta)

func switch_to_rising_gravity():
	current_gravity_scale = rising_gravity_scale

func switch_to_falling_gravity():
	current_gravity_scale = falling_gravity_scale
