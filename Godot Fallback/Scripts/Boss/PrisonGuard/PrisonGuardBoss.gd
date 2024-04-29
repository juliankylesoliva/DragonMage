extends Boss

class_name PrisonGuardBoss

@export var floor_spikes_l : FloorSpikes

@export var floor_spikes_r : FloorSpikes

@export var temper_fruit_l : TemperDragonFruit

@export var temper_fruit_r : TemperDragonFruit

@export var room_side_trigger : Trigger

var is_player_on_right_side : bool = false

var is_boss_on_right_side : bool = true

var current_weakness : StringName = "NONE"

var current_defense : int = 1

func _ready():
	super._ready()
	room_side_trigger.trigger_exited.connect(on_side_trigger_exited)
	if (textbox != null):
		textbox.textbox_finished.connect(on_dialogue_intro_finished)

func _physics_process(delta):
	check_temper_fruit_spawn()
	update_invulnerability_duration(delta)

func on_activation():
	if (player_hub.temper.is_forcing_form_change() or player_hub.temper.is_form_locked()):
		player_hub.temper.set_boss_courtesy_temper_level()
	if (textbox != null):
		if (introduction_text.size() > 0):
			PauseHandler.enable_pausing(false)
			player_hub.set_force_stand(true)
			textbox.accept_input_events = true
			for text in introduction_text:
				textbox.queue_text(text)
		else:
			on_dialogue_intro_finished()
	floor_spikes_l.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
	floor_spikes_r.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)

func damage_boss(_damage_type : StringName, _damage_strength : int, _knockback_vector : Vector2):
	if (current_invulnerability_duration > 0):
		return false
	
	if (current_armor <= 0 and is_knockback_enabled and state_machine.current_state.name == "Stunned" and state_machine.current_state.has_method("apply_knockback")):
		state_machine.current_state.apply_knockback(_knockback_vector.x, 1.0 if _knockback_vector.x >= 0 else -1.0)
		return true
	elif (current_armor > 0 and _damage_type == current_weakness and _damage_strength >= current_defense):
		current_armor -= 1
		do_post_hit_invulnerability()
		return true
	else:
		return false

func set_current_weakness(damage_type : StringName):
	if (current_weakness != damage_type):
		current_weakness = damage_type

func check_temper_fruit_spawn():
	if (player_hub == null):
		return
	
	if (is_activated and player_hub.temper.is_form_locked() and temper_fruit_l.is_despawned() and temper_fruit_r.is_despawned()):
		var chosen_fruit_side : TemperDragonFruit = (temper_fruit_r if !is_player_on_right_side else temper_fruit_l)
		chosen_fruit_side.set_starting_state(-1 if player_hub.form.is_a_mage() else 1)
		chosen_fruit_side.do_respawn(true)

func on_side_trigger_exited():
	is_player_on_right_side = (player_hub.char_body.global_position.x > room_side_trigger.global_position.x)

func on_dialogue_intro_finished():
	if (is_activated):
		PauseHandler.enable_pausing(true)
		# unfreeze player
		player_hub.set_force_stand(false)
		state_machine.set_process_mode(PROCESS_MODE_INHERIT)
