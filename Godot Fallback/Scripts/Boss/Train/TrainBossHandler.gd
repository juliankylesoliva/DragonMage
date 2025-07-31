extends Boss

class_name TrainBossHandler

@export var exit_gate_sprite : Sprite2D

@export var starting_train : TrainHazard

@export var dummy_warps : Array[WarpTrigger]

@export var phase_2_room : Room

@export var phase_3_room : Room

@export var invulnerability_time_decrease_per_phase : float = 0.5

@export_multiline var mid_battle_text_1 : Array[String]

@export_multiline var mid_battle_text_2 : Array[String]

@export_multiline var pre_defeat_text : Array[String]

func _ready():
	super._ready()
	if (textbox != null):
		textbox.textbox_finished.connect(on_dialogue_intro_finished)

func _physics_process(delta):
	update_invulnerability_duration(delta)
	if (textbox.current_state != Textbox.TextboxState.READY and textbox.unformatted_text.contains("{player_name}")):
		textbox.update_player_name_format_text(player_hub.form.get_current_form_name())

func on_activation():
	exit_gate_sprite.set_visible(true)
	player_hub.set_respawn_position(boss_room.get_room_entrance_coordinates(1))
	if (player_hub.temper.is_forcing_form_change() or player_hub.temper.is_form_locked()):
		player_hub.temper.set_boss_courtesy_temper_level()
	if (textbox != null):
		if (introduction_text.size() > 0):
			PauseHandler.enable_pausing(false)
			player_hub.set_force_stand(true)
			textbox.accept_input_events = true
			if (clear_timer != null):
				clear_timer.stop_timer()
			for text in introduction_text:
				textbox.queue_text(text)
		else:
			on_dialogue_intro_finished()

func on_defeat():
	is_activated = false
	if (clear_timer != null):
		clear_timer.stop_timer()
	if (boss_music_player != null):
		boss_music_player.fade_out()
	if (textbox != null):
		if (defeat_text.size() > 0):
			PauseHandler.enable_pausing(false)
			player_hub.set_force_stand(true)
			textbox.accept_input_events = true
			textbox.textbox_finished.connect(on_dialogue_defeat_finished)
			for text in defeat_text:
				textbox.queue_text(text)
		else:
			on_dialogue_defeat_finished()

func damage_boss(_damage_type : StringName, _damage_strength : int, _knockback_vector : Vector2, _is_projectile : bool = false):
	if (current_invulnerability_duration > 0 or current_health <= 0):
		return false
	
	if (current_armor > 0):
		if (_damage_type == "PARRY"):
			current_armor = 0
		else:
			current_armor -= 1
		do_post_hit_invulnerability()
		return true
	elif (current_health > 0):
		current_health -= 1
		if (current_health > 0):
			post_hit_invulnerability_duration -= invulnerability_time_decrease_per_phase 
			do_mid_battle_dialogue()
		else:
			do_pre_defeat_dialogue()
		return true
	else:
		return false

func on_dialogue_intro_finished():
	if (is_activated):
		player_hub.set_force_stand(false)
		if (state_machine != null):
			state_machine.set_process_mode(PROCESS_MODE_INHERIT)
		if (boss_music_player != null):
			boss_music_player.restart_music()
		if (clear_timer != null):
			clear_timer.start_timer()
		starting_train.initialize_train()
		await get_tree().process_frame # prevents pausing on the same frame
		PauseHandler.enable_pausing(true)
		textbox.textbox_finished.disconnect(on_dialogue_intro_finished)

func on_dialogue_defeat_finished():
	player_hub.set_force_stand(false)
	if (state_machine != null):
		state_machine.set_process_mode(PROCESS_MODE_DISABLED)
	if (clear_timer != null):
		clear_timer.start_timer()
	await get_tree().process_frame # prevents pausing on the same frame
	PauseHandler.enable_pausing(true)
	textbox.textbox_finished.disconnect(on_dialogue_defeat_finished)

func do_mid_battle_dialogue():
	if (clear_timer != null):
		clear_timer.stop_timer()
	if (player_hub.temper.is_forcing_form_change() or player_hub.temper.is_form_locked()):
		player_hub.temper.set_boss_courtesy_temper_level()
	if (textbox != null):
		var mid_battle_text : Array[String] = (mid_battle_text_1 if current_health >= 2 else mid_battle_text_2)
		if (mid_battle_text.size() > 0):
			PauseHandler.enable_pausing(false)
			player_hub.set_force_stand(true)
			textbox.accept_input_events = true
			textbox.textbox_finished.connect(on_mid_battle_dialogue_finished)
			for text in mid_battle_text:
				textbox.queue_text(text)
		else:
			on_mid_battle_dialogue_finished()

func on_mid_battle_dialogue_finished():
	player_hub.set_force_stand(false)
	if (clear_timer != null):
		clear_timer.start_timer()
	
	var warp : WarpTrigger = dummy_warps[dummy_warps.size() - current_health - 1]
	warp._on_body_entered(player_hub.char_body as Node)
	
	var room : Room = (phase_2_room if current_health >= 2 else phase_3_room)
	player_hub.set_respawn_position(room.get_room_entrance_coordinates(1))
	
	current_armor = armor
	
	await get_tree().process_frame # prevents pausing on the same frame
	PauseHandler.enable_pausing(true)
	textbox.textbox_finished.disconnect(on_mid_battle_dialogue_finished)

func do_pre_defeat_dialogue():
	if (clear_timer != null):
		clear_timer.stop_timer()
	if (boss_music_player != null):
		boss_music_player.fade_out()
	if (player_hub.temper.is_forcing_form_change() or player_hub.temper.is_form_locked()):
		player_hub.temper.set_boss_courtesy_temper_level()
	if (textbox != null):
		if (pre_defeat_text.size() > 0):
			PauseHandler.enable_pausing(false)
			player_hub.set_force_stand(true)
			textbox.accept_input_events = true
			textbox.textbox_finished.connect(on_pre_defeat_dialogue_finished)
			for text in pre_defeat_text:
				textbox.queue_text(text)
		else:
			on_mid_battle_dialogue_finished()

func on_pre_defeat_dialogue_finished():
	var warp : WarpTrigger = dummy_warps[dummy_warps.size() - current_health - 1]
	warp._on_body_entered(player_hub.char_body as Node)
	if (player_hub.form.is_a_mage()):
		player_hub.form.change_mode(PlayerForm.CharacterMode.DRAGON)
	player_hub.temper.change_temper_by(player_hub.temper.max_segments)
	player_hub.temper.disable_temper_rebound = true
	player_hub.fairy.set_current_magic(0)
	textbox.textbox_finished.disconnect(on_pre_defeat_dialogue_finished)
