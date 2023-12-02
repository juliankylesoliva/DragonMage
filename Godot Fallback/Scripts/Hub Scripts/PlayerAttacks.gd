extends Node

class_name PlayerAttacks

@export var hub : PlayerHub

@export var standing_attack_name : String = "MagicBlast"
@export var crouching_attack_name : String = "Dodge"

var attacks_list : Array[Attack]

var current_attack_cooldown_timer : float = 0

var current_attack : Attack = null

func _ready():
	for child in get_children():
		if (child is Attack):
			attacks_list.append(child)
			child.hub = hub
		else:
			push_warning("Invalid Attack! ({name})".format({"name": child.name}))

func _process(delta):
	update_attack_cooldown_timer(delta)

func is_using_attack_state():
	if (!is_attack_cooldown_active() and (current_attack == null or current_attack.current_attack_state == Attack.AttackState.NOTHING) and hub.buffers.is_attack_buffer_active()):
		var selected_attack = get_attack_by_name(crouching_attack_name if hub.movement.is_crouching else standing_attack_name)
		if (selected_attack != null and selected_attack.can_use_attack()):
			hub.buffers.reset_attack_buffer()
			if (selected_attack.uses_attack_state):
				current_attack = selected_attack
				return true
			else:
				selected_attack.use_attack()
	return false

func set_attack_cooldown_timer(time : float):
	current_attack_cooldown_timer = time

func update_attack_cooldown_timer(delta : float):
	if (current_attack_cooldown_timer > 0):
		current_attack_cooldown_timer = move_toward(current_attack_cooldown_timer, 0, delta)

func is_attack_cooldown_active():
	return current_attack_cooldown_timer > 0

func get_attack_by_name(attack_name : String):
	for attack in attacks_list:
		if (attack.name == attack_name):
			return attack
	push_error("Invalid attack name! ({str})".format({"str": attack_name}))
	return null
