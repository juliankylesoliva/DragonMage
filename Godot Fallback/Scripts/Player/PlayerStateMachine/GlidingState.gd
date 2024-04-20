extends State

class_name GlidingState

@export var glide_particles : GPUParticles2D

var is_throwing : bool = false

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	hub.jumping.glide_update(_delta)
	
	glide_particles.process_material.direction.x = -hub.get_input_vector().x
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	if (!hub.char_sprite.is_playing() and hub.char_sprite.animation == "MagliThrowAir"):
		is_throwing = false
		hub.animation.set_animation("MagliGlide")
	
	if (hub.is_deactivated):
		set_next_state(state_machine.get_state_by_name("Deactivated"))
	elif (hub.force_stand):
		set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.fairy.is_using_fairy_ability() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.stomp.is_stomping_enemy()):
		hub.stomp.do_stomp_jump()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.can_wall_slide()):
		set_next_state(state_machine.get_state_by_name("WallSliding"))
	elif (hub.jumping.is_glide_canceled()):
		if (hub.jumping.enable_crouch_jumping and Input.is_action_pressed("Crouch")):
				hub.movement.check_crouch_state()
		set_next_state(state_machine.get_state_by_name("Falling"))
	elif (hub.damage.is_player_defeated):
		set_next_state(state_machine.get_state_by_name("Defeated"))
	elif (hub.damage.is_player_damaged()):
		set_next_state(state_machine.get_state_by_name("Damaged"))
	else:
		pass

func on_enter():
	is_throwing = hub.char_sprite.animation.contains("MagliThrow")
	hub.jumping.start_glide()
	hub.animation.set_animation("MagliThrowAir" if is_throwing else "MagliGlide")
	hub.animation.set_animation_frame(1 if is_throwing else 0)
	glide_particles.emitting = true

func on_exit():
	if (!hub.stomp.is_stomping_enemy()):
		hub.jumping.cancel_glide()
	glide_particles.emitting = false

func _on_magic_blast_magic_blast_thrown():
	if (state_machine.current_state == self):
		is_throwing = true
		hub.animation.set_animation("MagliThrowAir")
		hub.animation.set_animation_speed(1)
