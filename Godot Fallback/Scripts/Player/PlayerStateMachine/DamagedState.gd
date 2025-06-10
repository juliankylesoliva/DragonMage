extends State

class_name DamagedState

enum DamageWarpState {NONE, RISING, FALLING}

@export var damage_warp_launch_speed : float = 512

@export var damage_warp_falling_offscreen_offset : float = 192

@export var damage_warp_camera_vertical_offset : float = 32

var current_damage_warp_state : DamageWarpState = DamageWarpState.NONE

var saved_collision_layer : int = 0

var saved_collision_mask : int = 0

var was_damage_warping : bool = false

func state_process(_delta):
	if (hub.damage.current_hitstun_timer > 0 and !hub.damage.is_damage_warping):
		knockback_damage_process(_delta)
	else:
		if (hub.damage.current_hitstun_timer < hub.damage.hitstun_time and !was_damage_warping and hub.damage.is_damage_warping and current_damage_warp_state == DamageWarpState.NONE):
			hub.damage.reset_hitstun_timer()
			on_enter()
		damage_warp_process(_delta)

func on_enter():
	hub.jumping.landing_reset()
	if (hub.movement.is_crouching and !hub.collisions.is_in_ceiling_when_uncrouched()):
		hub.movement.reset_crouch_state()
	if (!hub.temper.is_form_locked()):
		hub.temper.change_temper_by((hub.damage.mage_temper_damage if hub.form.current_mode == PlayerForm.CharacterMode.MAGE else hub.damage.dragon_temper_damage) * (1 if state_machine.previous_state.name != "FormChanging" else hub.temper.total_segments))
	hub.movement.reset_current_horizontal_velocity()
	hub.buffers.reset_speed_preservation_buffer()
	hub.jumping.reset_super_jump_timers()
	hub.audio.play_sound("damage_player")
	
	if (hub.damage.current_hitstun_timer > 0 and !hub.damage.is_damage_warping):
		can_update_camera_x_pos = false
		can_update_camera_y_pos = true
		hub.jumping.switch_to_falling_gravity()
		hub.damage.do_knockback()
	else:
		can_update_camera_x_pos = false
		can_update_camera_y_pos = false
		hub.jumping.switch_to_zero_gravity()
		current_damage_warp_state = DamageWarpState.RISING
		saved_collision_layer = hub.char_body.collision_layer
		saved_collision_mask = hub.char_body.collision_mask
		hub.char_body.collision_layer = 0
		hub.char_body.collision_mask = 0
		hub.char_body.velocity = (Vector2.UP * damage_warp_launch_speed)
	
	hub.animation.set_animation("{name}Damage".format({"name" : hub.form.get_current_form_name()}))
	hub.animation.set_animation_speed(1)

func on_exit():
	if (!hub.char_body.is_on_floor() and !was_damage_warping):
		hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
	hub.damage.do_iframes()
	was_damage_warping = false

func knockback_damage_process(_delta):
	hub.damage.update_knockback(_delta)
	hub.damage.update_hitstun_timer(_delta)
	hub.camera.damaged_horizontal_camera_update(_delta)
	
	if (!hub.damage.is_player_damaged() or hub.is_deactivated):
		hub.damage.reset_hitstun_timer()
		if (hub.temper.is_forcing_form_change()):
			set_next_state(state_machine.get_state_by_name("FormChanging"))
		elif (hub.char_body.is_on_floor()):
			set_next_state(state_machine.get_state_by_name("Standing"))
		else:
			set_next_state(state_machine.get_state_by_name("Falling"))

func damage_warp_process(_delta):
	hub.char_body.move_and_slide()
	
	match current_damage_warp_state:
		DamageWarpState.RISING:
			if (!hub.visibility.is_on_screen()):
				hub.char_body.velocity *= -1
				hub.camera.snap_camera_to_position(hub.current_respawn_position + (Vector2.RIGHT * hub.camera.base_x_lookahead * hub.movement.get_facing_value()) + (Vector2.DOWN * damage_warp_camera_vertical_offset))
				hub.char_body.global_position.x = hub.current_respawn_position.x
				hub.char_body.global_position.y = (hub.current_respawn_position.y - damage_warp_falling_offscreen_offset)
				if (hub.fairy.fairy_ref != null):
					hub.fairy.fairy_ref.snap_to_target_node()
				current_damage_warp_state = DamageWarpState.FALLING
		DamageWarpState.FALLING:
			if (hub.char_body.global_position.y >= hub.current_respawn_position.y):
				hub.char_body.global_position.y = hub.current_respawn_position.y
				hub.camera.reset_x_lookahead()
				hub.char_body.collision_layer = saved_collision_layer
				hub.char_body.collision_mask = saved_collision_mask
				hub.char_body.move_and_slide()
				hub.char_body.velocity = Vector2.ZERO
				hub.jumping.landing_reset()
				current_damage_warp_state = DamageWarpState.NONE
				was_damage_warping = true
				hub.damage.reset_damage_warp()
				
				var effect_instance : AnimatedSprite2D = EffectFactory.get_effect("LandingDust", hub.collisions.get_ground_point())
				effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.char_body.get_floor_normal())
		
				var walk_sound : String = ("jump_magli_landing" if hub.form.is_a_mage() else "jump_draelyn_landing")
				SoundFactory.play_sound_by_name(walk_sound, hub.char_body.global_position, 0, 1, "SFX")
				
				if (hub.temper.is_forcing_form_change()):
					set_next_state(state_machine.get_state_by_name("FormChanging"))
				elif (hub.char_body.is_on_floor()):
					set_next_state(state_machine.get_state_by_name("Standing"))
				else:
					set_next_state(state_machine.get_state_by_name("Falling"))
		_:
			pass
