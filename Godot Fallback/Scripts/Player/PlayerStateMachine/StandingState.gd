extends State

class_name StandingState

@export var num_blink_animations : int = 3
@export var min_blink_time : float = 3
@export var max_blink_time : float = 4
var current_blink_timer = 0

var prev_is_crouching = false

var is_headbonking : bool = false

func state_process(_delta):
	var char_name : String = hub.form.get_current_form_name()
	prev_is_crouching = hub.movement.is_crouching
	hub.movement.check_crouch_state()
	hub.movement.do_movement(_delta)
	hub.movement.update_facing_direction()
	hub.collisions.do_ledge_nudge()
	
	if (hub.movement.is_crouching):
		if (!Input.is_action_pressed("Crouch") and hub.collisions.is_in_ceiling_when_uncrouched()):
			hub.animation.set_animation("{name}CrouchHeadbonk".format({"name" : char_name}))
			if (!is_headbonking):
				is_headbonking = true
				
				var effect_instance = EffectFactory.get_effect("HeadbonkFX", hub.collisions.get_ceiling_point())
				effect_instance.rotation = hub.char_body.up_direction.angle_to(hub.collisions.get_ceiling_normal())
				
				var sound_name : String = ("jump_magli_headbonk" if hub.form.is_a_mage() else "jump_draelyn_headbonk")
				SoundFactory.play_sound_by_name(sound_name, hub.char_body.global_position, -2)
		else:
			is_headbonking = false
			hub.animation.set_animation("{name}Crouch".format({"name" : char_name}))
	else:
		if(Input.is_action_just_released("Crouch") or (prev_is_crouching and !hub.movement.is_crouching)):
			hub.animation.set_animation("{name}Stand".format({"name" : char_name}))
		update_blink_timer(_delta)
		if (!hub.char_sprite.is_playing()):
			if (!check_blink_animation()):
				hub.animation.set_animation("{name}Stand".format({"name" : char_name}))
				hub.animation.set_animation_speed(1)
		is_headbonking = false
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.char_body.is_on_floor() and (!hub.collisions.is_facing_a_wall() or (hub.get_input_vector().x * hub.movement.get_facing_value()) < 0) and hub.get_input_vector().x != 0):
		set_next_state(state_machine.get_state_by_name("Running"))
	elif (hub.jumping.can_ground_jump()):
		hub.jumping.start_ground_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (!hub.char_body.is_on_floor()):
		set_next_state((state_machine.get_state_by_name("Falling")))
	elif (!hub.char_body.is_on_floor() and hub.char_body.velocity.y < 0):
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (!hub.char_body.is_on_floor() and hub.char_body.velocity.y >= 0):
		set_next_state((state_machine.get_state_by_name("Falling")))
	elif (hub.char_body.velocity.x != 0):
		set_next_state(state_machine.get_state_by_name("Running"))
	else:
		pass

func on_enter():
	is_headbonking = false
	var char_name : String = hub.form.get_current_form_name()
	var anim_name : String = ("{name}Stand" if !hub.movement.is_crouching else "{name}Crouch")
	hub.jumping.landing_reset()
	hub.animation.set_animation(anim_name.format({"name" : char_name}))
	hub.animation.set_animation_speed(1)

func set_blink_timer():
	current_blink_timer = randf_range(min_blink_time, max_blink_time)

func update_blink_timer(delta):
	if (num_blink_animations <= 0):
		return
	
	current_blink_timer = move_toward(current_blink_timer, 0, delta)

func check_blink_animation():
	if (num_blink_animations <= 0):
		return false
	
	if (current_blink_timer <= 0):
		var blink_anim_num = (randi() % num_blink_animations)
		hub.animation.set_animation("{name}StandBlink{num}".format({"name" : hub.form.get_current_form_name(), "num": blink_anim_num}))
		hub.animation.set_animation_speed(1)
		set_blink_timer()
		return true
	
	return false
