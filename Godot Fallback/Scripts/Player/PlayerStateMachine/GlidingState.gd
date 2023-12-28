extends State

class_name GlidingState

@export var glide_particles : GPUParticles2D

func state_process(_delta : float):
	hub.movement.do_movement(_delta)
	hub.jumping.glide_update(_delta)
	
	glide_particles.process_material.direction.x = -hub.get_input_vector().x
	
	if (hub.form.cannot_change_form()):
		hub.form.form_change_failed()
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_wall_slide()):
		set_next_state(state_machine.get_state_by_name("WallSliding"))
	elif (hub.jumping.is_glide_canceled()):
		if (hub.jumping.enable_crouch_jumping and Input.is_action_pressed("Crouch")):
				hub.movement.check_crouch_state()
		set_next_state(state_machine.get_state_by_name("Falling"))
	else:
		pass

func on_enter():
	hub.jumping.start_glide()
	hub.animation.set_animation("MagliGlide")
	glide_particles.emitting = true

func on_exit():
	hub.jumping.cancel_glide()
	glide_particles.emitting = false
