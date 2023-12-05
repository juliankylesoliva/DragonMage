extends State

class_name WallClimbingState

func state_process(_delta):
	hub.animation.set_animation_speed(hub.jumping.get_climbing_animation_speed())
	hub.jumping.wall_climb_update(_delta)
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.attacks.is_using_attack_state() and hub.attacks.current_attack != null):
		set_next_state(state_machine.get_state_by_name("Attacking"))
	elif (hub.jumping.can_start_wall_popup() and Input.is_action_pressed("Technical")):
		hub.jumping.do_ledge_snap()
		if (Input.is_action_pressed("Crouch")):
			var selected_attack : Attack = hub.attacks.get_attack_by_name(hub.attacks.crouching_attack_name)
			if (selected_attack != null):
				hub.attacks.current_attack = selected_attack
				set_next_state(state_machine.get_state_by_name("Attacking"))
		else:
			set_next_state(state_machine.get_state_by_name("Running"))
	elif (hub.jumping.can_start_wall_popup()):
		hub.jumping.start_wall_popup()
		set_next_state(state_machine.get_state_by_name("WallVaulting"))
	elif (hub.jumping.is_wall_climb_canceled()):
		hub.jumping.cancel_wall_climb()
		set_next_state(state_machine.get_state_by_name("Falling"))
	else:
		pass

func on_enter():
	hub.jumping.start_wall_climb()
	hub.animation.set_animation("DraelynWallClimb")
	hub.animation.set_animation_frame(0)
	hub.animation.set_animation_speed(hub.jumping.get_climbing_animation_speed())

func on_exit():
	hub.jumping.end_wall_climb()
	hub.animation.set_animation_speed(1)
