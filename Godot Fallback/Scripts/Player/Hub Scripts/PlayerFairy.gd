extends Node

class_name PlayerFairy

@export var hub : PlayerHub

@export var is_using_fairy : bool = false

@export var enable_abilities : bool = true

@export var fairy_follower_scene : PackedScene

@export var fairy_target_node : Node2D

@export var fairy_target_offset : float = 32

@export var global_fairy_ability_cooldown_time : float = 0.5

@export_range(0, 100) var starting_magic : float = 25

@export_range(1, 100) var max_magic : float = 100

@export var magic_danger_increase_rate : float = 0.833

@export var starting_magic_consolation_bonus : float = 25

@export var starting_magic_consolation_cadence : int = 3

var fairy_ref : FairyFollow

var fairy_ability_list : Array[Attack]

var current_selected_ability_index : int = -1

var current_magic : float = 0

var current_fairy_ability_cooldown_timer : float = 0

func _ready():
	if (is_using_fairy):
		var node_temp : Node = fairy_follower_scene.instantiate()
		call_deferred("add_sibling", node_temp)
		fairy_ref = (node_temp as FairyFollow)
		fairy_ref.set_home_position_target(fairy_target_node)
		
		if (enable_abilities):
			for child in get_children():
				if (child is Attack):
					fairy_ability_list.append(child)
					child.hub = hub
				else:
					push_warning("Invalid Ability! ({name})".format({"name": child.name}))
			
			if (fairy_ability_list.size() > 0):
				current_selected_ability_index = 0
			
			reset_starting_magic()

func _process(delta):
	update_fairy_ability_cooldown_timer(delta)
	do_magic_danger_increase(delta)

func _physics_process(_delta):
	if (is_using_fairy and fairy_ref != null):
		fairy_ref.set_facing_direction(hub.movement.get_facing_value())
		update_target_node_position()

func reset_fairy():
	if (is_using_fairy and fairy_ref != null):
		fairy_ref.set_enable_idle_motion(true)
		fairy_ref.sprite.play("FaesonIdle")

func update_target_node_position():
	fairy_target_node.position.x = (fairy_target_offset * -hub.movement.get_facing_value())

func get_selected_ability():
	if (enable_abilities):
		return fairy_ability_list[current_selected_ability_index]
	return null

func is_using_fairy_ability():
	if (is_using_fairy and enable_abilities and !is_fairy_ability_cooldown_active() and (hub.attacks.current_attack == null or hub.attacks.current_attack.current_attack_state == Attack.AttackState.NOTHING) and Input.is_action_pressed("Fairy Ability")):
		var selected_attack = fairy_ability_list[current_selected_ability_index]
		if (selected_attack != null and check_input_type(selected_attack) and selected_attack.can_use_attack()):
			hub.buffers.reset_fairy_ability_buffer()
			if (selected_attack.attack_state_condition()):
				hub.attacks.current_attack = selected_attack
				return true
			else:
				selected_attack.use_attack()
	return false

func is_magic_full():
	return current_magic >= max_magic

func is_magic_empty():
	return current_magic <= 0

func change_current_magic_by(amount : float):
	set_current_magic(current_magic + amount)

func set_current_magic(num : float):
	if (num > max_magic):
		current_magic = max_magic
	elif (num < 0):
		current_magic = 0
	else:
		current_magic = num

func get_current_magic_portion():
	return (current_magic / max_magic)

func move_magic_toward(to : float, delta : float):
	current_magic = move_toward(current_magic, to, delta)

func cut_magic_in_half():
	current_magic *= 0.5

func reset_starting_magic():
	current_magic = starting_magic
	change_current_magic_by(starting_magic_consolation_bonus * (CheckpointHandler.death_counter / starting_magic_consolation_cadence))

func set_fairy_ability_cooldown_timer(time : float = 0):
	if (current_fairy_ability_cooldown_timer <= 0):
		current_fairy_ability_cooldown_timer = (time if time > 0 else global_fairy_ability_cooldown_time)

func update_fairy_ability_cooldown_timer(delta : float):
	if (enable_abilities):
		if (current_fairy_ability_cooldown_timer > 0):
			current_fairy_ability_cooldown_timer = move_toward(current_fairy_ability_cooldown_timer, 0, delta)

func is_fairy_ability_cooldown_active():
	return current_fairy_ability_cooldown_timer > 0

func check_input_type(attack : Attack):
	return ((attack.input_type == Attack.AttackInputType.PRESS and hub.buffers.is_fairy_ability_buffer_active()) or (attack.input_type == Attack.AttackInputType.HOLD and Input.is_action_pressed("Fairy Ability")))

func do_magic_danger_increase(delta : float):
	if (is_using_fairy and enable_abilities and !hub.damage.is_player_defeated and hub.temper.is_form_locked()):
		move_magic_toward(max_magic, magic_danger_increase_rate * get_current_magic_portion() * hub.movement.get_speed_portion() * delta)
