extends State

class_name DefeatedState

@export var hitstop_duration : float = 1

@export var vertical_launch : float = 512

@export var defeat_z_index : int = 9

var current_hitstop_timer : float = 0

var saved_collision_layer : int = 0

var saved_collision_mask : int = 0

var saved_z_index : int = 0

var starting_y_pos : float = 0

func state_process(_delta):
	if (current_hitstop_timer < hitstop_duration):
		current_hitstop_timer = move_toward(current_hitstop_timer, hitstop_duration, _delta)
		if (current_hitstop_timer >= hitstop_duration):
			hub.animation.set_animation_speed(1)
			hub.audio.play_sound("player_death")
			hub.char_body.velocity = (Vector2.UP * vertical_launch)
	else:
		if (hub.visibility.is_on_screen() or hub.char_body.velocity.y <= 0 or hub.char_body.global_position.y <= starting_y_pos):
			hub.fairy.fairy_ref.snap_to_target_node()
			hub.char_body.move_and_slide()
			hub.char_body.velocity.y += hub.jumping.get_gravity_delta(_delta)

func on_enter():
	starting_y_pos = hub.char_body.global_position.y
	hub.fairy.fairy_ref.set_enable_idle_motion(false)
	hub.fairy.fairy_ref.snap_to_target_node()
	hub.fairy.fairy_ref.sprite.play("FaesonDefeat")
	hub.buffers.reset_speed_preservation_buffer()
	hub.jumping.reset_super_jump_timers()
	hub.audio.play_sound("player_death_hitstop", -2)
	hub.jumping.switch_to_falling_gravity()
	hub.animation.set_animation("{name}Defeat".format({"name" : hub.form.get_current_form_name()}))
	hub.animation.set_animation_speed(0)
	hub.jumping.magic_blast_attack.destroy_projectile()
	saved_collision_layer = hub.char_body.collision_layer
	saved_collision_mask = hub.char_body.collision_mask
	saved_z_index = hub.char_sprite.z_index
	hub.char_sprite.z_index = defeat_z_index
	hub.fairy.fairy_ref.sprite.z_index = defeat_z_index
	hub.char_body.collision_layer = 0
	hub.char_body.collision_mask = 0
	current_hitstop_timer = 0

func on_exit():
	hub.damage.is_player_defeated = false
	hub.char_body.collision_layer = saved_collision_layer
	hub.char_body.collision_mask = saved_collision_mask
	hub.char_sprite.z_index = saved_z_index
	hub.fairy.fairy_ref.sprite.z_index = saved_z_index
