extends Node

class_name PlayerJumping

@export var hub : PlayerHub

@export var magic_blast_attack : MagicBlastAttack = null

@export_group("Standard Jump Parameters")

## Allows the player to preserve their speed by jumping as soon as they land.
@export var enable_speed_hopping : bool = true

## The minimum slope angle (in radians) needed to trigger a speed hop from landing on a downward slope.
@export var speed_hop_slope_boost_threshold : float = 0.4

## Adjusts the amount of speed hop velocity added from landing on a downward slope.
@export var speed_hop_slope_boost_multiplier : float = 0.5

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

@export_group("Gliding Variables")

@export var enable_gliding : bool = true

@export var min_glide_height : float = 1

@export var glide_fall_speed : float = 0.75

@export_range(0.0, 5.0) var max_glide_time : float = 5

@export var enable_glide_toggle : bool = false

var current_glide_time : float = 0

@export_group("Wall Climb Variables")

@export var enable_wall_climbing : bool = false

@export var min_wall_climb_height : float = 0

@export var min_climbing_speed : float = 0

@export var max_climbing_speed : float = 0

@export var wall_climbing_gravity_scale : float = 0

@export var max_wall_climb_time : float = 0

@export var ledge_snap_distance : float = 0

@export var wall_popup_time : float = 0

@export var min_wall_popup_speed : float = 0

@export var max_wall_popup_speed : float = 0

@export var min_climbing_animation_speed : float = 0.5

var current_wall_climb_time : float = 0

var stored_wall_climb_speed : float = 0

var wall_popup_time_left : float = 0

@export_group("Wall Jump Variables")

@export var enable_wall_jumping : bool = true

@export var min_wall_jump_height : float = 1

@export var wall_slide_speed : float = 1.8

@export var max_wall_slide_speed : float = 8.5

@export var wall_slide_gravity_scale : float = 3

@export var vertical_wall_jump_velocity : float = 12

@export var min_vertical_wall_jump_velocity : float = 1

@export var horizontal_wall_jump_velocity : float = 5.25

@export var max_wall_jump_direction_lock_time : float = 0.3

@export var max_wall_jumps : int = 3

@export_range(0, 1) var wall_jump_height_decay_rate : float = 0.5

var current_wall_jumps : int = 0

@export_group("Misc Wall Variables")

@export var wall_release_time : float = 0.25

@export_group("Midair Jump Parameters")

@export var midair_jump_particles : CPUParticles2D

@export_color_no_alpha var forward_midair_jump_color : Color = Color.WHITE

@export_color_no_alpha var neutral_midair_jump_color : Color = Color.WHITE

@export_color_no_alpha var backward_midair_jump_color : Color = Color.WHITE

@export var forward_midair_jump_texture : Texture2D

@export var neutral_midair_jump_texture : Texture2D

@export var backward_midair_jump_texture : Texture2D

@export var midair_jump_particle_multiplier : int = 3

@export_range(0, 5) var max_midair_jumps : int = 0

@export var midair_jump_velocity : float = 0

@export var forward_midair_jump_bonus : Vector2 = Vector2.ZERO

var current_midair_jumps : int = 0

@export_group("Running Jump Parameters")

## When enabled, this character's jump velocity will increase by a small amount depending on their horizontal speed.
@export var enable_running_jump : bool = true

## The amount of added jump velocity at top speed.
@export var running_jump_added_velocity : float = 1.5

@export_group("Crouch-related Variables")

@export var enable_crouch_jumping : bool = true

@export var enable_super_jumping : bool = false

@export var super_jump_charge_time : float = 0

@export var super_jump_retention_time : float = 0

@export var super_jump_velocity_multiplier : float = 0

@export var super_jump_particles : CPUParticles2D

var current_super_jump_charge_timer : float = 0

var current_super_jump_retention_timer : float = 0

@export_group("Fast Falling Variables")

@export var enable_fast_falling : bool = false

@export var fast_fall_threshold : float = -32

@export var fast_falling_speed : float = 0

@export var super_jump_after_fast_fall_time : float = 0

@export var fast_fall_slope_boost_threshold : float = 1

@export var fast_fall_slope_boost_multiplier : float = 0

var is_fast_falling : bool = false

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity_scale : float = 1

var current_wall_jump_direction_lock_time : float = 0

var current_wall_release_timer : float = 0

func _ready():
	current_gravity_scale = falling_gravity_scale

func _process(delta):
	update_super_jump_charge_timer(delta)
	update_super_jump_retention_timer(delta)

func update_min_jump_hold_timer(delta : float):
	current_min_jump_hold_timer = move_toward(current_min_jump_hold_timer, min_jump_hold_time, delta)
	if (current_min_jump_hold_timer == 0):
		is_jump_held = false

func reset_min_jump_hold_timer():
	current_min_jump_hold_timer = 0

func max_out_min_jump_hold_timer():
	current_min_jump_hold_timer = min_jump_hold_time

func set_is_jump_held():
	is_jump_held = true

func unset_is_jump_held():
	is_jump_held = false

func is_wall_jump_lock_timer_active():
	return current_wall_jump_direction_lock_time > 0

func activate_wall_jump_lock_timer():
	current_wall_jump_direction_lock_time = max_wall_jump_direction_lock_time

func reset_wall_jump_lock_timer():
	current_wall_jump_direction_lock_time = 0

func update_wall_jump_lock_timer(delta):
	if (hub.state_machine.current_state.name != "FormChanging" and is_wall_jump_lock_timer_active() and hub.char_body.velocity.y > 0):
		current_wall_jump_direction_lock_time = move_toward(current_wall_jump_direction_lock_time, 0, delta)

func reset_wall_release_timer():
	current_wall_release_timer = 0

func update_wall_release_timer(delta):
	if (hub.get_input_vector().x == -hub.movement.get_facing_value() and (hub.state_machine.current_state.name == "WallSliding" or hub.state_machine.current_state.name == "WallClimbing")):
		current_wall_release_timer = move_toward(current_wall_release_timer, wall_release_time, delta)
	else:
		reset_wall_release_timer()

func is_super_jump_ready():
	return (current_super_jump_retention_timer > 0)

func update_super_jump_charge_timer(delta : float):
	if (hub.movement.is_crouching and hub.get_input_vector().x == 0 and ((!hub.movement.enable_crouch_toggle and hub.is_action_pressed("Crouch")) or hub.movement.enable_crouch_toggle) and hub.char_body.is_on_floor() and hub.state_machine.current_state.name == "Standing"):
		if (current_super_jump_charge_timer < super_jump_charge_time and current_super_jump_retention_timer <= 0):
			current_super_jump_charge_timer = move_toward(current_super_jump_charge_timer, super_jump_charge_time, delta)
			if (current_super_jump_charge_timer >= super_jump_charge_time):
				super_jump_particles.emitting = true
				SoundFactory.play_sound_by_name("jump_draelyn_charged", hub.char_body.global_position, 0, 1, "SFX")
				current_super_jump_retention_timer = super_jump_retention_time
	else:
		if (current_super_jump_retention_timer <= 0):
			super_jump_particles.emitting = false
			current_super_jump_charge_timer = 0

func update_super_jump_retention_timer(delta : float):
	if (current_super_jump_retention_timer > 0):
		if (current_super_jump_retention_timer >= super_jump_retention_time and hub.movement.is_crouching and ((!hub.movement.enable_crouch_toggle and hub.is_action_pressed("Crouch")) or hub.movement.enable_crouch_toggle) and hub.char_body.is_on_floor() and (hub.state_machine.current_state.name == "Standing" or hub.state_machine.current_state.name == "Running")):
			current_super_jump_retention_timer = super_jump_retention_time
		else:
			current_super_jump_retention_timer = move_toward(current_super_jump_retention_timer, 0, delta)
			if (current_super_jump_retention_timer <= 0):
				super_jump_particles.emitting = false

func charge_super_jump_with_fast_fall():
	current_super_jump_charge_timer = super_jump_charge_time
	current_super_jump_retention_timer = super_jump_after_fast_fall_time
	super_jump_particles.emitting = true

func reset_super_jump_timers():
	current_super_jump_charge_timer = 0
	current_super_jump_retention_timer = 0
	super_jump_particles.emitting = false

func can_ground_jump():
	return (hub.buffers.is_jump_buffer_active() and (hub.char_body.is_on_floor() or hub.buffers.is_coyote_time_active()) and (!hub.movement.is_crouching or enable_crouch_jumping or !hub.collisions.is_in_ceiling_when_uncrouched()))

func start_ground_jump():
	hub.buffers.reset_jump_buffer()
	hub.buffers.reset_glide_buffer()
	set_is_jump_held()
	switch_to_rising_gravity()
	
	if (!enable_crouch_jumping):
		hub.movement.reset_crouch_state()
	
	landing_reset()
	reset_min_jump_hold_timer()
	reset_fast_fall()
	
	var did_player_speed_hop : bool = (enable_speed_hopping and !hub.movement.is_crouching and (hub.char_body.velocity.x * hub.get_input_vector().x > 0) and hub.buffers.highest_speed > hub.movement.top_speed and hub.buffers.is_speed_preservation_buffer_active())
	var horizontal_result = (maxf(hub.buffers.highest_speed, abs(hub.char_body.velocity.x)) if did_player_speed_hop else abs(hub.char_body.velocity.x))
	
	var running_jump_result = (min((horizontal_result / hub.movement.top_speed), 1) * running_jump_added_velocity if enable_running_jump and !hub.movement.is_crouching else 0)
	var super_jump_result : float = (super_jump_velocity_multiplier if is_super_jump_ready() else 1.0)
	
	var effect_name : String = ("SpeedhopSpark" if did_player_speed_hop else "SuperJumpSpark" if is_super_jump_ready() else "JumpSpark")
	var effect_instance : AnimatedSprite2D = EffectFactory.get_effect(effect_name, hub.collisions.get_ground_point(), 1, hub.movement.get_facing_value() < 0)
	effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.char_body.get_floor_normal())
	
	var sound_name : String = ("jump_magli" if hub.form.is_a_mage() else "jump_draelyn")
	var sound_pitch : float = (1.5 if did_player_speed_hop or is_super_jump_ready() else 1.0)
	hub.audio.play_sound(sound_name, 0, sound_pitch, "SFX")
	
	var char_name : String = hub.form.get_current_form_name()
	var is_throwing : bool = hub.char_sprite.animation.contains("MagliThrow")
	hub.animation.set_animation("MagliThrowAir" if is_throwing else "MagliBoostJump" if hub.jumping.magic_blast_attack.is_blast_jumping and !hub.movement.is_crouching else "{name}Jump".format({"name" : char_name}) if !hub.movement.is_crouching else "{name}CrouchJump".format({"name" : char_name}))
	hub.animation.set_animation_frame(1 if is_throwing else 0)
	hub.animation.set_animation_speed(1)
	
	hub.movement.current_horizontal_velocity = (horizontal_result * hub.movement.get_facing_value())
	hub.char_body.velocity.x = hub.movement.current_horizontal_velocity
	hub.char_body.velocity.y = -((initial_jump_velocity * super_jump_result) + running_jump_result)
	
	if (did_player_speed_hop):
		hub.buffers.refresh_speed_preservation_buffer()
	
	if (is_super_jump_ready()):
		reset_super_jump_timers()

func ground_jump_update(delta : float):
	if (hub.char_body.velocity.y < 0):
		if (can_fast_fall()):
			set_fast_fall()
			hub.char_body.velocity.y = fast_falling_speed
		else:
			hub.char_body.velocity.y += get_gravity_delta(delta)
		
		if (current_min_jump_hold_timer >= min_jump_hold_time and is_jump_held and !hub.is_action_pressed("Jump")):
			unset_is_jump_held()
		
		if ((is_jump_held or current_min_jump_hold_timer < min_jump_hold_time) and hub.char_body.is_on_ceiling()):
			unset_is_jump_held()
			max_out_min_jump_hold_timer()
			if (!magic_blast_attack.is_blast_jumping):
				hub.char_body.velocity.x = (min(abs(hub.char_body.velocity.x), hub.movement.top_speed) * hub.movement.get_facing_value())
				hub.char_body.velocity.y = 0
		
		if (enable_variable_jumps and !is_jump_held && current_min_jump_hold_timer >= min_jump_hold_time):
			hub.char_body.velocity.y = move_toward(hub.char_body.velocity.y, 0, variable_jump_decay_rate * delta)
		
		update_min_jump_hold_timer(delta)

func falling_update(delta : float):
	if (can_fast_fall()):
		set_fast_fall()
		hub.char_body.velocity.y = fast_falling_speed
	else:
		hub.char_body.velocity.y += get_gravity_delta(delta)
	
	var max_fall_speed_to_use = (fast_falling_speed if enable_fast_falling and is_fast_falling else max_fall_speed if magic_blast_attack == null or !magic_blast_attack.is_blast_jumping else magic_blast_attack.blast_jump_max_fall_speed)
	if (hub.char_body.velocity.y > max_fall_speed_to_use):
		hub.char_body.velocity.y = max_fall_speed_to_use

func can_fast_fall():
	return (enable_fast_falling and !is_fast_falling and hub.movement.is_crouching and hub.buffers.is_fast_fall_buffer_active() and fast_falling_speed > max_fall_speed and !hub.char_body.is_on_floor() and hub.char_body.velocity.y >= fast_fall_threshold and hub.char_body.velocity.y < fast_falling_speed)

func can_fast_fall_slope_boost():
	return (enable_fast_falling and is_fast_falling and hub.char_body.is_on_floor() and hub.collisions.get_distance_to_ground() <= hub.char_body.floor_snap_length and hub.char_body.get_floor_angle() > fast_fall_slope_boost_threshold)

func do_fast_fall_slope_boost():
	var flip : bool = ((hub.char_body.get_floor_normal().x * hub.movement.get_facing_value()) <= 0)
	if (flip):
		hub.movement.current_horizontal_velocity *= (-1 if hub.is_action_pressed("Crouch") else 0)
		hub.movement.set_facing_direction(-hub.movement.get_facing_value())
	hub.movement.current_horizontal_velocity += (fast_fall_slope_boost_multiplier * hub.jumping.fast_falling_speed * hub.char_body.get_floor_normal().x)
	hub.char_body.velocity.x = hub.movement.current_horizontal_velocity
	landing_reset()

func can_speed_hop_slope_boost():
	return (enable_speed_hopping and !hub.movement.is_crouching and hub.char_body.is_on_floor() and hub.collisions.get_distance_to_ground() <= hub.char_body.floor_snap_length and hub.char_body.get_floor_angle() > speed_hop_slope_boost_threshold)

func do_speed_hop_slope_boost():
	if ((hub.char_body.get_floor_normal().x * hub.movement.get_facing_value()) > 0 and (hub.char_body.velocity.x * hub.get_input_vector().x) > 0):
		var fall_speed_to_use : float = (max_fall_speed if magic_blast_attack == null or !magic_blast_attack.is_blast_jumping else magic_blast_attack.blast_jump_max_fall_speed)
		hub.buffers.refresh_speed_preservation_buffer()
		hub.buffers.highest_speed += (speed_hop_slope_boost_multiplier * fall_speed_to_use * hub.char_body.get_floor_normal().x * hub.movement.get_facing_value())
	else:
		hub.buffers.highest_speed = move_toward(hub.buffers.highest_speed, min(hub.movement.top_speed, abs(hub.movement.current_horizontal_velocity)), speed_hop_slope_boost_multiplier * hub.jumping.max_fall_speed * abs(hub.char_body.get_floor_normal().x))
		hub.movement.current_horizontal_velocity = (min(hub.movement.current_horizontal_velocity, hub.buffers.highest_speed) if hub.movement.get_facing_value() > 0 else max(hub.movement.current_horizontal_velocity, -hub.buffers.highest_speed))
		hub.char_body.velocity.x = hub.movement.current_horizontal_velocity

func can_glide():
	return (enable_gliding and !hub.buffers.is_coyote_time_active() and hub.char_body.velocity.y >= 0 and current_glide_time <= hub.buffers.early_glide_buffer_time and hub.collisions.get_distance_to_ground() >= min_glide_height and (hub.buffers.is_glide_buffer_active() or hub.is_action_just_pressed("Glide")))

func start_glide():
	hub.buffers.reset_glide_buffer()
	hub.audio.play_sound("jump_magli_glide")
	switch_to_zero_gravity()
	hub.char_body.velocity.y = glide_fall_speed

func glide_update(delta : float):
	hub.char_body.velocity.y = glide_fall_speed
	current_glide_time = move_toward(current_glide_time, max_glide_time, delta)

func is_glide_canceled():
	return ((!enable_glide_toggle and !hub.is_action_pressed("Glide")) or (enable_glide_toggle and hub.is_action_just_pressed("Glide")) or hub.char_body.is_on_floor() or hub.jumping.current_glide_time >= hub.jumping.max_glide_time)

func cancel_glide():
	if (current_glide_time > hub.buffers.early_glide_buffer_time or (!enable_glide_toggle and !hub.is_action_pressed("Glide")) or (enable_glide_toggle and hub.is_action_just_pressed("Glide"))):
		current_glide_time = max_glide_time

func can_midair_jump():
	return (((hub.state_machine.previous_state.name != "WallVaulting") or hub.char_body.velocity.y >= 0 or current_midair_jumps > 0) and (!hub.char_body.is_on_floor() or hub.state_machine.current_state.name == "Jumping") and current_midair_jumps < max_midair_jumps and hub.buffers.is_jump_buffer_active())

func do_midair_jump():
	hub.animation.set_animation("DraelynMidairJump" if !hub.movement.is_crouching else "DraelynMidairCrouchJump")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(1)
	
	hub.audio.play_sound("jump_draelyn_midair", 0, lerp(1.0, 1.3, (current_midair_jumps as float) / ((max_midair_jumps - 1) as float)))
	
	hub.buffers.reset_jump_buffer()
	set_is_jump_held()
	switch_to_rising_gravity()
	hub.char_body.velocity.y = -midair_jump_velocity
	
	if (hub.movement.get_facing_value() * hub.get_input_vector().x > 0):
		var bonus_velocity : Vector2 = Vector2.ZERO
		bonus_velocity.x = (forward_midair_jump_bonus.x * hub.movement.get_facing_value())
		bonus_velocity.y = -abs(forward_midair_jump_bonus.y)
		hub.char_body.velocity += bonus_velocity
		hub.movement.current_horizontal_velocity += bonus_velocity.x
	else:
		hub.buffers.reset_speed_preservation_buffer()
		if (abs(hub.char_body.velocity.x) > hub.movement.top_speed):
			var speed_cap : float = (hub.movement.top_speed * hub.get_input_vector().x)
			hub.char_body.velocity.x = speed_cap
			hub.movement.current_horizontal_velocity = speed_cap
	
	var input_direction : float = hub.get_input_vector().x
	var input_facing_direction : float = (input_direction * hub.movement.get_facing_value())
	midair_jump_particles.amount = (midair_jump_particle_multiplier * (max_midair_jumps - current_midair_jumps))
	midair_jump_particles.texture = (forward_midair_jump_texture if input_facing_direction > 0 else backward_midair_jump_texture if input_facing_direction < 0 else neutral_midair_jump_texture)
	midair_jump_particles.direction.x = -input_direction
	midair_jump_particles.color = (forward_midair_jump_color if input_facing_direction > 0 else backward_midair_jump_color if input_facing_direction < 0 else neutral_midair_jump_color)
	midair_jump_particles.restart()
	midair_jump_particles.emitting = true
	
	current_midair_jumps += 1

func can_wall_slide():
	return (enable_wall_jumping and !hub.movement.is_crouching and hub.collisions.get_distance_to_ground() >= min_wall_jump_height and hub.collisions.is_facing_a_wall() and hub.collisions.is_moving_against_a_wall() and !hub.collisions.is_facing_an_intangible_wall() and !hub.collisions.is_moving_against_an_intangible_wall() and (!hub.is_action_pressed("Jump") or !is_jump_held or hub.char_body.velocity.y >= 0))

func can_wall_slide_from_wall_climb():
	return (enable_wall_jumping and hub.collisions.is_facing_a_wall() and !hub.collisions.is_facing_an_intangible_wall() and !hub.char_body.is_on_floor() and (hub.get_input_vector().x == hub.movement.get_facing_value() or current_wall_release_timer < wall_release_time))

func start_wall_slide():
	hub.movement.reset_crouch_state()
	hub.audio.play_sound("jump_magli_wallslide")
	hub.buffers.refresh_speed_preservation_buffer()
	is_jump_held = false
	switch_to_wall_slide_gravity()
	hub.char_body.velocity.x = 0
	hub.char_body.velocity.y = wall_slide_speed
	hub.movement.current_horizontal_velocity = 0

func wall_slide_update(delta):
	hub.char_body.velocity.y = move_toward(hub.char_body.velocity.y, max_wall_slide_speed, get_gravity_delta(delta))
	hub.movement.current_horizontal_velocity = 0
	hub.char_body.move_and_slide()

func is_wall_slide_canceled():
	return (!hub.collisions.is_facing_a_wall() or hub.collisions.is_facing_an_intangible_wall() or hub.char_body.velocity.y == 0 or (hub.get_input_vector().x == -hub.movement.get_facing_value() and current_wall_release_timer >= wall_release_time) or (hub.jumping.enable_crouch_jumping and !hub.movement.is_crouch_cooldown_active() and hub.is_action_pressed("Crouch")))

func can_wall_jump():
	return (hub.state_machine.current_state.name == "WallSliding" and !is_wall_jump_lock_timer_active() and hub.buffers.is_jump_buffer_active())

func start_wall_jump():
	hub.buffers.reset_jump_buffer()
	hub.buffers.reset_glide_buffer()
	set_is_jump_held()
	switch_to_rising_gravity()
	hub.movement.reset_crouch_state()
	
	reset_min_jump_hold_timer()
	
	var did_player_speed_kick = (enable_speed_hopping and current_wall_jumps < max_wall_jumps and hub.buffers.highest_speed > hub.movement.top_speed and hub.buffers.is_speed_preservation_buffer_active())
	var horizontal_result = (maxf(hub.buffers.highest_speed, abs(horizontal_wall_jump_velocity)) if did_player_speed_kick else abs(horizontal_wall_jump_velocity))
	hub.movement.current_horizontal_velocity = (-horizontal_result if hub.movement.is_facing_right else horizontal_result)
	hub.movement.set_facing_direction(-hub.movement.get_facing_value())
	hub.char_body.velocity.x = hub.movement.current_horizontal_velocity
	hub.char_body.velocity.y = (-max(vertical_wall_jump_velocity * pow(wall_jump_height_decay_rate, 0 if did_player_speed_kick else current_wall_jumps), min_vertical_wall_jump_velocity) if current_wall_jumps < max_wall_jumps else -min_vertical_wall_jump_velocity)
	
	if (current_wall_jumps < max_wall_jumps):
		if (current_wall_jumps == 0):
			current_glide_time = 0
			current_midair_jumps = 0
			wall_popup_time_left = 0
			current_wall_climb_time = 0
		current_wall_jumps += 1
	else:
		hub.buffers.reset_speed_preservation_buffer()
	
	var is_throwing : bool = hub.char_sprite.animation.contains("MagliThrow")
	hub.animation.set_animation("MagliThrowAir" if is_throwing else "MagliJump")
	hub.animation.set_animation_frame(1 if is_throwing else 0)
	hub.animation.set_animation_speed(1)
	
	var effect_name : String = ("FastWallJump" if did_player_speed_kick else "NormalWallJump")
	EffectFactory.get_effect(effect_name, hub.raycast_dm.global_position, 1, hub.movement.get_facing_value() > 0)
	
	SoundFactory.play_sound_by_name("jump_magli_wallkick", hub.char_body.global_position)
	hub.audio.play_sound("jump_magli", 0, 1.5 if did_player_speed_kick else 1.0)
	
	activate_wall_jump_lock_timer()

func can_wall_climb():
	return (enable_wall_climbing and !hub.movement.is_crouching and !is_fast_falling and !hub.char_body.is_on_ceiling() and hub.collisions.get_distance_to_ground() >= min_wall_climb_height and current_wall_climb_time <= 0 and hub.collisions.is_moving_against_a_wall() and !hub.collisions.is_moving_against_an_intangible_wall() and (hub.get_input_vector().x * hub.movement.get_facing_value()) > 0)

func can_wall_climb_from_wall_slide():
	return (enable_wall_climbing and current_wall_climb_time <= 0 and !hub.char_body.is_on_ceiling() and !hub.char_body.is_on_floor() and hub.collisions.is_facing_a_wall() and !hub.collisions.is_facing_an_intangible_wall() and (hub.get_input_vector().x == hub.movement.get_facing_value() or current_wall_release_timer < wall_release_time))

func can_wall_climb_from_fire_tackle():
	return (enable_wall_climbing and current_wall_climb_time <= 0 and !hub.char_body.is_on_ceiling() and !hub.char_body.is_on_floor() and hub.collisions.is_facing_a_wall() and !hub.collisions.is_facing_an_intangible_wall() and (hub.get_input_vector().x * hub.movement.get_facing_value()) > 0)

func start_wall_climb():
	hub.movement.reset_crouch_state()
	hub.movement.reset_current_horizontal_velocity()
	hub.audio.play_sound("jump_draelyn_wallclimb")
	switch_to_wall_climbing_gravity()
	if (stored_wall_climb_speed <= 0):
		hub.buffers.refresh_speed_preservation_buffer()
		stored_wall_climb_speed = min(max(hub.buffers.highest_speed, min_climbing_speed), max_climbing_speed)
		hub.char_body.velocity = (Vector2.UP * stored_wall_climb_speed)

func wall_climb_update(delta : float):
	hub.char_body.velocity.x = 0
	hub.movement.reset_current_horizontal_velocity()
	hub.char_body.move_and_slide()
	current_wall_climb_time = move_toward(current_wall_climb_time, max_wall_climb_time, delta)
	hub.char_body.velocity.y += get_gravity_delta(delta)

func end_wall_climb():
	current_wall_climb_time = max_wall_climb_time

func cancel_wall_climb():
	hub.char_body.velocity = Vector2.ZERO
	switch_to_falling_gravity()

func is_wall_climb_canceled():
	return (current_wall_climb_time <= 0 or hub.char_body.velocity.y >= 0 or hub.char_body.is_on_ceiling() or !hub.collisions.is_facing_a_wall() or hub.collisions.is_facing_an_intangible_wall() or (hub.get_input_vector().x == -hub.movement.get_facing_value() and (current_wall_release_timer >= wall_release_time or (hub.jumping.enable_crouch_jumping and !hub.movement.is_crouch_cooldown_active() and hub.is_action_pressed("Crouch")))))

func can_start_wall_popup():
	return (current_wall_climb_time < max_wall_climb_time and hub.char_body.velocity.y < 0 and !hub.collisions.is_facing_a_wall() and !hub.collisions.is_facing_an_intangible_wall() and (hub.get_input_vector().x * hub.movement.get_facing_value()) >= 0)

func start_wall_popup():
	hub.animation.set_animation("DraelynMidairJump")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(1)
	hub.audio.play_sound("jump_draelyn_wallpopup")
	hub.movement.reset_current_horizontal_velocity()
	hub.movement.reset_crouch_state()
	
	var vertical_result : float = min(max_wall_popup_speed, max(min_wall_popup_speed, -hub.char_body.velocity.y))
	var result_scale : float = (vertical_result / min_wall_popup_speed)
	EffectFactory.get_effect("WallVaultSpark", hub.collisions.get_ground_point(), result_scale, hub.movement.get_facing_value() < 0)
	wall_popup_time_left = wall_popup_time
	switch_to_rising_gravity()
	hub.char_body.velocity = (Vector2.UP * vertical_result)

func can_wall_vault():
	return (wall_popup_time_left > 0 and hub.char_body.velocity.y < 0 and !hub.movement.is_crouching and !hub.collisions.is_moving_against_a_wall() and (hub.get_input_vector().x * hub.movement.get_facing_value()) > 0 and (hub.buffers.is_jump_buffer_active() or (hub.is_action_pressed("Jump") and hub.get_input_vector().y > 0)))

func wall_popup_update(delta : float):
	hub.char_body.velocity.x = 0
	hub.movement.reset_current_horizontal_velocity()
	hub.char_body.move_and_slide()
	wall_popup_time_left = move_toward(wall_popup_time_left, 0, delta)
	hub.char_body.velocity.y += get_gravity_delta(delta)

func start_wall_vault():
	hub.animation.set_animation("DraelynVault")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(1)
	
	EffectFactory.get_effect("WallVaultRing", hub.collision_shape.global_position, stored_wall_climb_speed / min_climbing_speed)
	
	hub.audio.play_sound("jump_draelyn_wallvault")
	
	current_glide_time = 0
	current_midair_jumps = 0
	current_wall_jumps = 0
	
	hub.buffers.reset_jump_buffer()
	is_jump_held = true
	switch_to_rising_gravity()
	
	hub.char_body.velocity = Vector2(stored_wall_climb_speed * hub.get_input_vector().x, -initial_jump_velocity)
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	stored_wall_climb_speed = 0

func end_wall_popup():
	wall_popup_time_left = 0

func is_wall_popup_canceled():
	return (wall_popup_time_left <= 0 or hub.char_body.velocity.y >= 0 or (hub.get_input_vector().x * hub.movement.get_facing_value()) < 0)

func do_ledge_snap():
	var vertical_result = min(max_wall_popup_speed, max(min_wall_popup_speed, -hub.char_body.velocity.y))
	var result_scale : float = (vertical_result / min_wall_popup_speed)
	EffectFactory.get_effect("WallVaultSpark", hub.collisions.get_ground_point(), result_scale, hub.movement.get_facing_value() < 0)
	
	hub.audio.play_sound("jump_draelyn_wallpopup", 0, 1.5)
	hub.char_body.velocity = Vector2(hub.movement.get_facing_value() * ledge_snap_distance, 0)
	var intended_velocity = hub.char_body.velocity
	hub.char_body.move_and_slide()
	hub.collisions.upward_slope_correction(intended_velocity)
	hub.char_body.apply_floor_snap()
	switch_to_falling_gravity()
	hub.char_body.velocity = Vector2(stored_wall_climb_speed * hub.movement.get_facing_value(), 0)
	hub.movement.current_horizontal_velocity = hub.char_body.velocity.x

func landing_reset():
	current_glide_time = 0
	current_wall_climb_time = 0
	stored_wall_climb_speed = 0
	wall_popup_time_left = 0
	current_midair_jumps = 0
	current_wall_jumps = 0

func set_fast_fall():
	hub.buffers.reset_fast_fall_buffer()
	hub.buffers.reset_attack_buffer()
	is_fast_falling = true
	if (!hub.collisions.is_in_ceiling_when_uncrouched()):
		hub.movement.is_crouching = false
	SoundFactory.play_sound_by_name("jump_draelyn_fastfall", hub.char_body.global_position, 0, 1, "SFX")

func reset_fast_fall():
	if (enable_fast_falling):
		hub.sprite_trail.deactivate_trail()
	is_fast_falling = false

func get_climbing_animation_speed():
	return max(-hub.char_body.velocity.y / min_climbing_speed, min_climbing_animation_speed)

func get_gravity_delta(delta : float):
	return (base_gravity * current_gravity_scale * delta)

func switch_to_wall_slide_gravity():
	current_gravity_scale = wall_slide_gravity_scale

func switch_to_wall_climbing_gravity():
	current_gravity_scale = wall_climbing_gravity_scale

func switch_to_rising_gravity():
	current_gravity_scale = rising_gravity_scale

func switch_to_falling_gravity():
	current_gravity_scale = falling_gravity_scale

func switch_to_zero_gravity():
	current_gravity_scale = 0
