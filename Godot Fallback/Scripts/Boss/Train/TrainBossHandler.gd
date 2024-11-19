extends Boss

class_name TrainBossHandler

@export var starting_train : TrainHazard

func _ready():
	super._ready()
	if (textbox != null):
		textbox.textbox_finished.connect(on_dialogue_intro_finished)

func _physics_process(delta):
	update_invulnerability_duration(delta)
	if (textbox.current_state != Textbox.TextboxState.READY and textbox.unformatted_text.contains("{player_name}")):
		textbox.update_player_name_format_text(player_hub.form.get_current_form_name())

func on_activation():
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

func damage_boss(_damage_type : StringName, _damage_strength : int, _knockback_vector : Vector2):
	if (current_invulnerability_duration > 0 or current_health <= 0):
		return false
	
	if (current_armor > 0):
		current_armor -= 1
		do_post_hit_invulnerability()
		return true
	elif (current_health > 0):
		current_health -= 1
		# trigger some dialogue + transition
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
