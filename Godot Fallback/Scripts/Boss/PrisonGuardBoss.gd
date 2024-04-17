extends Boss

@export var floor_spikes_l : FloorSpikes

@export var floor_spikes_r : FloorSpikes

@export var temper_fruit_l : TemperDragonFruit

@export var temper_fruit_r : TemperDragonFruit

@export var room_side_trigger : Trigger

var is_player_on_right_side : bool = false

func _ready():
	super._ready()
	room_side_trigger.trigger_exited.connect(on_side_trigger_exited)

func _physics_process(delta):
	check_temper_fruit_spawn()
	update_invulnerability_duration(delta)
	match current_health:
		4:
			phase_one_process(delta)
		3:
			phase_two_process(delta)
		2:
			phase_three_process(delta)
		1:
			phase_four_process(delta)
		_:
			pass

func phase_one_process(_delta : float):
	pass

func phase_two_process(_delta : float):
	pass

func phase_three_process(_delta : float):
	pass

func phase_four_process(_delta : float):
	pass

func on_activation():
	floor_spikes_l.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
	floor_spikes_r.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)

func damage_boss(_damage_type : StringName):
	if (current_invulnerability_duration > 0):
		return

func check_temper_fruit_spawn():
	if (player_hub == null):
		return
	
	if (is_activated and player_hub.temper.is_form_locked() and temper_fruit_l.is_despawned() and temper_fruit_r.is_despawned()):
		var chosen_fruit_side : TemperDragonFruit = (temper_fruit_r if !is_player_on_right_side else temper_fruit_l)
		chosen_fruit_side.set_starting_state(-1 if player_hub.form.is_a_mage() else 1)
		chosen_fruit_side.do_respawn(true)

func on_side_trigger_exited():
	is_player_on_right_side = (player_hub.char_body.global_position.x > room_side_trigger.global_position.x)
