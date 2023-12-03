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
	hub.attacks.current_attack = null
