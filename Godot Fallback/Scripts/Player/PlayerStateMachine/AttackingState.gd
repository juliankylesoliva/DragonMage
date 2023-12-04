extends State

class_name AttackingState

func state_process(_delta):
	if (hub.attacks.current_attack != null and hub.attacks.current_attack.uses_attack_state):
		hub.attacks.current_attack.attack_state_process(_delta)

func on_enter():
	if (hub.attacks.current_attack != null and hub.attacks.current_attack.uses_attack_state):
		hub.attacks.current_attack.on_attack_state_enter()

func on_exit():
	if (hub.attacks.current_attack != null and hub.attacks.current_attack.uses_attack_state):
		hub.attacks.current_attack.on_attack_state_exit()
	
	if (hub.attacks.current_attack != null):
		hub.attacks.previous_attack = hub.attacks.current_attack
	
	if (next_state != null and next_state.name == state_machine.current_state.name and hub.attacks.queued_attack != null):
		hub.attacks.current_attack = hub.attacks.queued_attack
		hub.attacks.queued_attack = null
	else:
		hub.attacks.current_attack = null
