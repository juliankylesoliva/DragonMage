extends State

class_name WallVaultingState

func state_process(_delta):
	hub.jumping.wall_popup_update(_delta)
	
	if (hub.form.can_change_form()):
		set_next_state(state_machine.get_state_by_name("FormChanging"))
	elif (hub.jumping.can_wall_vault()):
		hub.jumping.start_wall_vault()
		set_next_state(state_machine.get_state_by_name("Jumping"))
	elif (hub.jumping.is_wall_popup_canceled()):
		hub.jumping.cancel_wall_climb()
		set_next_state(state_machine.get_state_by_name("Falling"))

func on_exit():
	hub.jumping.end_wall_popup()
