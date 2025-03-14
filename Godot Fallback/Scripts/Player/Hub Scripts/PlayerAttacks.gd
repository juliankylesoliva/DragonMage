extends Node

class_name PlayerAttacks

@export var hub : PlayerHub

@export var global_attack_cooldown_time : float = 0.25

@export var standing_attack_name : String = "MagicBlast"
@export var crouching_attack_name : String = "Dodge"

var attacks_list : Array[Attack]

var current_attack_cooldown_timer : float = 0

var current_attack : Attack = null

var previous_attack : Attack = null

var queued_attack : Attack = null

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
	if (!is_attack_cooldown_active() and (current_attack == null or current_attack.current_attack_state == Attack.AttackState.NOTHING) and (hub.buffers.is_attack_buffer_active() or hub.is_action_pressed("Attack"))):
		var selected_attack = get_attack_by_name(crouching_attack_name if hub.movement.is_crouching else standing_attack_name)
		if (selected_attack != null and check_input_type(selected_attack) and selected_attack.can_use_attack()):
			hub.buffers.reset_attack_buffer()
			if (selected_attack.attack_state_condition()):
				current_attack = selected_attack
				return true
			else:
				selected_attack.use_attack()
	return false

func set_queued_attack(next : Attack):
	if (hub.state_machine.current_state.name == "Attacking"):
		queued_attack = next

func set_attack_cooldown_timer(time : float = 0):
	if (current_attack_cooldown_timer <= 0):
		current_attack_cooldown_timer = (time if time > 0 else global_attack_cooldown_time)

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

func check_input_type(attack : Attack):
	return ((attack.input_type == Attack.AttackInputType.PRESS and hub.buffers.is_attack_buffer_active()) or (attack.input_type == Attack.AttackInputType.HOLD and hub.is_action_pressed("Attack")))
