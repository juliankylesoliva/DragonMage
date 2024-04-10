extends Node

class_name PlayerBuffers

@export var hub : PlayerHub

## Allows a player to press the form change button early and still have their input be registered within a small window of time.
@export var form_change_buffer_time : float = 0.1
var form_change_buffer_time_left : float = 0

## Allows a player to press the jump button early and still have their input be registered within a small window of time.
@export var jump_buffer_time : float = 0.15
var jump_buffer_time_left : float = 0

## Allows a player to press crouch early while jumping and still have their fast fall input be registered within a small window of time.
@export var fast_fall_buffer_time : float = 0.1
var fast_fall_buffer_time_left : float = 0

@export var fairy_ability_buffer_time : float = 0.25
var fairy_ability_buffer_time_left : float = 0

## Allows a player to press the attack button early and still have their input be registered within a small window of time.
@export var attack_buffer_time : float = 0.25
var attack_buffer_time_left : float = 0

## Allows a player to conserve their increased speed by performing certain actions.
@export var speed_preservation_buffer_time : float = 0.5
var speed_preservation_buffer_time_left : float = 0
var highest_speed : float = 0

@export var speed_preservation_particles : GPUParticles2D

## Allows a player to jump within a small window of time if they had just ran off of a ledge.
@export var coyote_time : float = 0.2
var coyote_time_left : float = 0
var prev_is_on_floor : bool = false

## Used for preserving the player's glide time should a glide be activated right before a wall jump.
@export var early_glide_buffer_time : float = 0.25

func _ready():
	prev_is_on_floor = hub.char_body.is_on_floor()

func _input(event):
	if (event.is_action_pressed("Jump")):
		refresh_jump_buffer()
	if (event.is_action_pressed("Crouch") and !hub.char_body.is_on_floor()):
		refresh_fast_fall_buffer()
	if (event.is_action_pressed("Fairy Ability")):
		refresh_fairy_ability_buffer()
	if (event.is_action_pressed("Attack")):
		refresh_attack_buffer()
	if (event.is_action_pressed("Change Form")):
		refresh_form_change_buffer()

func _process(delta):
	check_jump_buffer(delta)
	check_fast_fall_buffer(delta)
	check_attack_buffer(delta)
	check_form_change_buffer(delta)
	check_speed_preservation_buffer(delta)
	check_coyote_time(delta)

func check_form_change_buffer(delta : float):
	if (is_form_change_buffer_active()):
		form_change_buffer_time_left = move_toward(form_change_buffer_time_left, 0, delta)

func is_form_change_buffer_active():
	return form_change_buffer_time_left > 0

func reset_form_change_buffer():
	form_change_buffer_time_left = 0

func refresh_form_change_buffer():
	form_change_buffer_time_left = form_change_buffer_time

func check_jump_buffer(delta : float):
	if (is_jump_buffer_active()):
		jump_buffer_time_left = move_toward(jump_buffer_time_left, 0, delta)

func is_jump_buffer_active():
	return jump_buffer_time_left > 0

func reset_jump_buffer():
	jump_buffer_time_left = 0

func refresh_jump_buffer():
	jump_buffer_time_left = jump_buffer_time

func check_fast_fall_buffer(delta : float):
	if (is_fast_fall_buffer_active() and !hub.char_body.is_on_floor()):
		fast_fall_buffer_time_left = move_toward(fast_fall_buffer_time_left, 0, delta)
	else:
		if (fast_fall_buffer_time_left > 0):
			fast_fall_buffer_time_left = 0

func is_fast_fall_buffer_active():
	return (!hub.char_body.is_on_floor() and fast_fall_buffer_time_left > 0)

func reset_fast_fall_buffer():
	fast_fall_buffer_time_left = 0

func refresh_fast_fall_buffer():
	fast_fall_buffer_time_left = fast_fall_buffer_time

func check_attack_buffer(delta : float):
	if (is_attack_buffer_active()):
		attack_buffer_time_left = move_toward(attack_buffer_time_left, 0, delta)

func is_attack_buffer_active():
	return attack_buffer_time_left > 0

func reset_attack_buffer():
	attack_buffer_time_left = 0

func refresh_attack_buffer():
	attack_buffer_time_left = attack_buffer_time

func check_fairy_ability_buffer(delta : float):
	if (is_fairy_ability_buffer_active()):
		fairy_ability_buffer_time_left = move_toward(fairy_ability_buffer_time_left, 0, delta)

func is_fairy_ability_buffer_active():
	return fairy_ability_buffer_time_left > 0

func reset_fairy_ability_buffer():
	fairy_ability_buffer_time_left = 0

func refresh_fairy_ability_buffer():
	fairy_ability_buffer_time_left = fairy_ability_buffer_time

func check_speed_preservation_buffer(delta):
	var current_horizontal_speed = abs(hub.movement.current_horizontal_velocity)
	
	if (current_horizontal_speed >= highest_speed):
		highest_speed = current_horizontal_speed
		refresh_speed_preservation_buffer()
	else:
		if (hub.state_machine.current_state.name != "FormChanging"):
			if (is_speed_preservation_buffer_active() and (hub.char_body.is_on_floor() or hub.char_body.is_on_wall() or hub.char_body.velocity.x == 0 or hub.state_machine.current_state.name == "WallSliding" or hub.state_machine.current_state.name == "WallClimbing" or hub.state_machine.current_state.name == "WallVaulting")):
				speed_preservation_buffer_time_left = move_toward(speed_preservation_buffer_time_left, 0, delta)
			if (!is_speed_preservation_buffer_active() or hub.movement.is_turning() or (hub.get_input_vector().x == 0 and hub.state_machine.current_state.name != "WallSliding" and hub.state_machine.current_state.name != "WallClimbing" and hub.state_machine.current_state.name != "WallVaulting" and !hub.jumping.is_wall_jump_lock_timer_active())):
				highest_speed = current_horizontal_speed
	
	speed_preservation_particles.emitting = ((highest_speed > hub.movement.top_speed) and is_speed_preservation_buffer_active() and !hub.is_deactivated and !hub.damage.is_player_defeated)
	if (speed_preservation_particles.emitting):
		speed_preservation_particles.process_material.direction.x = -hub.movement.get_facing_value()
		speed_preservation_particles.process_material.initial_velocity_min = highest_speed
		speed_preservation_particles.process_material.initial_velocity_max = highest_speed

func is_speed_preservation_buffer_active():
	return speed_preservation_buffer_time_left > 0

func reset_speed_preservation_buffer():
	speed_preservation_buffer_time_left = 0

func refresh_speed_preservation_buffer():
	speed_preservation_buffer_time_left = speed_preservation_buffer_time

func check_coyote_time(delta : float):
	if (!hub.char_body.is_on_floor() and prev_is_on_floor and coyote_time_left <= 0 and hub.char_body.velocity.y >= 0):
		coyote_time_left = coyote_time
	elif ((hub.char_body.is_on_floor() and !prev_is_on_floor) or (hub.char_body.is_on_floor() and prev_is_on_floor)):
		coyote_time_left = 0
	else:
		pass
	
	if (coyote_time_left > 0):
		coyote_time_left = move_toward(coyote_time_left, 0, delta)
	
	prev_is_on_floor = hub.char_body.is_on_floor()

func is_coyote_time_active():
	return coyote_time_left > 0
