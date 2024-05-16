extends Attack

class_name FairyGuardAttack

@export var min_magic_cost : float = 5

@export var magic_drain_rate : float = 12

@export var guard_startup_duration : float = 0.1

@export var min_guard_hold_duration : float = 0.1

@export var blockstun_magic_cost : float = 10

@export var blockstun_duration : float = 0.25

@export var blockstun_knockback : float = 128

@export var guard_release_endlag_duration : float = 0.2

@export var parry_window_duration : float = 0.05

@export var parry_pose_duration : float = 0.2

@export var parry_magic_reward : float = 30

@export var guard_offset_from_char : Vector2 = Vector2.ZERO

@export var fairy_easing : float = 0.5

@export var invincibility_shield_scene : PackedScene

@export var invincibility_duration : float = 10

@export_range(0, 1) var invincibility_flashing_threshold : float = 0.25

@export var invincibility_fairy_rotation_rate : float = PI

@export var invincibility_fairy_rotation_radius : float = 32

var is_button_released : bool = false

var is_jump_cancelling : bool = false

var is_invincibility_active : bool = false

var startup_time_left : float = 0

var blockstun_time_left : float = 0

var min_guard_time_left : float = 0

var guard_release_time_left : float = 0

var parry_pose_time_left : float = 0

var did_player_parry : bool = false

var shield_instance : AnimatedSprite2D = null

var current_invincibility_rotation : float = 0

func _process(delta):
	if (is_invincibility_active and shield_instance != null):
		update_fairy_invincibility_rotation(delta)
		hub.fairy.move_magic_toward(0, (hub.fairy.max_magic / invincibility_duration) * delta)
		
		if (!shield_instance.is_playing()):
			shield_instance.play("Loop")
		
		if (hub.fairy.get_current_magic_portion() <= invincibility_flashing_threshold):
			shield_instance.play("Disappearing")
		
		if (hub.fairy.is_magic_empty()):
			hub.fairy.fairy_ref.set_enable_idle_motion(true)
			hub.fairy.fairy_ref.sprite.set_animation("FaesonIdle")
			is_invincibility_active = false
			shield_instance.queue_free()

func attack_state_condition():
	return !hub.fairy.is_magic_full()

func can_use_attack():
	if (is_invincibility_active):
		return false
	
	if (attack_state_condition()):
		var state_name : String = hub.state_machine.current_state.name
		return (!is_invincibility_active and hub.fairy.current_magic >= min_magic_cost and !hub.fairy.is_magic_full() and hub.char_body.is_on_floor() and !hub.damage.is_player_damaged() and state_name != "Attacking" and (hub.attacks.current_attack == null or hub.attacks.current_attack.name != self.name) and !hub.fairy.is_fairy_ability_cooldown_active())
	else:
		return (hub.fairy.is_magic_full() and !is_invincibility_active and shield_instance == null)

func use_attack():
	if (shield_instance == null):
		hub.fairy.fairy_ref.set_enable_idle_motion(false)
		hub.fairy.fairy_ref.sprite.set_animation("FaesonGuard")
		hub.audio.play_sound("ability_guard_invincibility")
		is_invincibility_active = true
		var temp_instance : Node = invincibility_shield_scene.instantiate()
		shield_instance = (temp_instance as AnimatedSprite2D)
		hub.char_body.add_child(shield_instance)
		(shield_instance as Node2D).global_position = hub.char_body.global_position
		hub.temper.set_starting_temper_level()

func on_attack_state_enter():
	startup_init()

func attack_state_process(_delta : float):
	if (hub.is_deactivated):
		end_guard()
	elif (current_attack_state == AttackState.STARTUP):
		startup_update(_delta)
		pass
	elif (current_attack_state == AttackState.ACTIVE):
		active_update(_delta)
		pass
	elif (current_attack_state == AttackState.ENDLAG):
		endlag_update(_delta)
		pass
	else:
		pass

func on_attack_state_exit():
	is_button_released = false
	is_jump_cancelling = false
	is_invincibility_active = false
	startup_time_left = 0
	blockstun_time_left = 0
	min_guard_time_left = 0
	guard_release_time_left = 0
	parry_pose_time_left = 0
	did_player_parry = false

func startup_init():
	current_attack_state = AttackState.STARTUP
	hub.movement.reset_crouch_state()
	hub.buffers.reset_speed_preservation_buffer()
	hub.movement.reset_current_horizontal_velocity()
	hub.char_body.velocity.x = 0
	hub.animation.set_animation("{name}Guard".format({"name" : hub.form.get_current_form_name()}))
	hub.animation.set_animation_frame(1)
	hub.fairy.fairy_ref.set_enable_idle_motion(false)
	hub.fairy.fairy_ref.sprite.set_animation("FaesonGuard")
	hub.audio.play_sound("ability_guard_activate")
	hub.fairy.change_current_magic_by(-min_magic_cost)
	startup_time_left = guard_startup_duration

func startup_update(delta : float):
	hub.camera.fairy_guard_camera_update(delta)
	hub.movement.set_facing_direction(hub.get_input_vector().x)
	update_fairy_position()
	if (startup_time_left > 0 and !hub.damage.is_player_defeated and  !hub.damage.is_player_damaged()):
		check_button_release()
		startup_time_left = move_toward(startup_time_left, 0, delta)
	elif (hub.damage.is_player_defeated or hub.damage.is_player_damaged()):
		end_guard()
	else:
		active_init()

func active_init():
	current_attack_state = AttackState.ACTIVE
	min_guard_time_left = min_guard_hold_duration
	hub.fairy.fairy_ref.sigil_sprite.set_animation("Guard")
	hub.fairy.fairy_ref.sigil_sprite.set_visible(true)

func active_update(delta : float):
	hub.camera.fairy_guard_camera_update(delta)
	hub.movement.set_facing_direction(hub.get_input_vector().x)
	update_fairy_position()
	if (((min_guard_time_left > 0 or blockstun_time_left > 0) and !hub.damage.is_player_defeated and !hub.damage.is_player_damaged()) or (!hub.damage.is_player_defeated and !hub.damage.is_player_damaged() and !is_jump_cancelling and !hub.fairy.is_magic_empty() and !is_button_released)):
		check_button_release()
		if (min_guard_time_left > 0):
			min_guard_time_left = move_toward(min_guard_time_left, 0, delta)
		elif (blockstun_time_left > 0):
			if (!hub.collisions.is_near_a_ledge(-hub.movement.get_facing_value())):
				hub.char_body.velocity.x = (pow(blockstun_time_left / blockstun_duration, 2) * abs(blockstun_knockback) * -hub.movement.get_facing_value())
			blockstun_time_left = move_toward(blockstun_time_left, 0, delta)
			if (blockstun_time_left <= 0):
				hub.char_body.velocity.x = 0
				hub.animation.set_animation("{name}Guard".format({"name" : hub.form.get_current_form_name()}))
				hub.animation.set_animation_frame(1)
			else:
				var intended_velocity : Vector2 = hub.char_body.velocity
				hub.char_body.move_and_slide()
				hub.collisions.upward_slope_correction(intended_velocity)
				if (hub.collisions.is_near_a_ledge()):
					hub.collisions.do_ledge_nudge()
					hub.char_body.velocity.x = 0
		elif (hub.buffers.is_jump_buffer_active()):
			is_jump_cancelling = true
		else:
			hub.fairy.move_magic_toward(0, magic_drain_rate * delta)
	elif (hub.damage.is_player_defeated or hub.damage.is_player_damaged()):
		end_guard()
	elif (is_jump_cancelling):
		hub.buffers.refresh_jump_buffer()
		end_guard()
	else:
		endlag_init()

func endlag_init():
	current_attack_state = AttackState.ENDLAG
	hub.animation.set_animation("{name}GuardRelease".format({"name" : hub.form.get_current_form_name()}))
	hub.fairy.fairy_ref.sprite.set_animation("FaesonGuardRelease")
	hub.audio.play_sound("ability_guard_release")
	hub.fairy.fairy_ref.sigil_sprite.set_visible(false)
	guard_release_time_left = guard_release_endlag_duration

func endlag_update(delta : float):
	hub.camera.fairy_guard_camera_update(delta)
	update_fairy_position()
	if (guard_release_time_left > 0 and !hub.damage.is_player_defeated and !hub.damage.is_player_damaged()):
		guard_release_time_left = move_toward(guard_release_time_left, 0, delta)
	elif (parry_pose_time_left > 0):
		parry_pose_time_left = move_toward(parry_pose_time_left, 0, delta)
	else:
		end_guard()

func end_guard():
	current_attack_state = AttackState.NOTHING
	
	hub.fairy.fairy_ref.set_enable_idle_motion(true)
	hub.fairy.fairy_ref.sprite.set_animation("FaesonIdle")
	hub.fairy.fairy_ref.sigil_sprite.set_visible(false)
	
	hub.fairy.set_fairy_ability_cooldown_timer()
	
	if (hub.is_deactivated):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Deactivated"))
	elif (hub.damage.is_player_defeated):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Damaged"))
	elif (is_jump_cancelling and hub.buffers.is_jump_buffer_active()):
		hub.jumping.start_ground_jump()
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))
	elif (hub.get_input_vector().x != 0):
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Running"))
	else:
		hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Standing"))

func can_parry():
	return (current_attack_state == AttackState.ENDLAG and !did_player_parry and guard_release_time_left > (guard_release_endlag_duration - parry_window_duration))

func check_button_release():
	if (!is_button_released):
			is_button_released = !Input.is_action_pressed("Fairy Ability")

func update_fairy_position():
	if (hub.fairy.fairy_ref != null):
		var target_position : Vector2 = (hub.collision_shape.global_position + (guard_offset_from_char * hub.movement.get_facing_value()))
		hub.fairy.fairy_ref.global_position += (fairy_easing * (target_position - hub.fairy.fairy_ref.global_position))

func update_fairy_invincibility_rotation(delta : float):
	if (hub.fairy.fairy_ref != null and is_invincibility_active):
		var target_position : Vector2 = Vector2(cos(current_invincibility_rotation), sin(current_invincibility_rotation))
		target_position *= invincibility_fairy_rotation_radius
		target_position += hub.char_body.global_position
		hub.fairy.fairy_ref.global_position += (fairy_easing * (target_position - hub.fairy.fairy_ref.global_position))
		current_invincibility_rotation += (invincibility_fairy_rotation_rate * delta)
		if (current_invincibility_rotation >= TAU):
			current_invincibility_rotation -= TAU

func do_blockstun():
	hub.fairy.change_current_magic_by(-blockstun_magic_cost)
	hub.audio.play_sound("damage_player_guarding")
	EffectFactory.get_effect("GuardShieldImpact", (hub.collision_shape.global_position + (guard_offset_from_char * hub.movement.get_facing_value())))
	hub.animation.set_animation("{name}Guard".format({"name" : hub.form.get_current_form_name()}))
	hub.animation.set_animation_frame(0)
	min_guard_time_left = 0
	blockstun_time_left = blockstun_duration

func do_parry():
	did_player_parry = true
	hub.fairy.change_current_magic_by(parry_magic_reward)
	hub.audio.play_sound("attack_parry")
	hub.animation.set_animation("{name}Parry".format({"name" : hub.form.get_current_form_name()}))
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(1)
	guard_release_time_left = 0
	parry_pose_time_left = parry_pose_duration
