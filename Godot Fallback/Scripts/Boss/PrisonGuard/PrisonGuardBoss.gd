extends Boss

class_name PrisonGuardBoss

@export var floor_spikes_l : FloorSpikes

@export var floor_spikes_r : FloorSpikes

@export var temper_fruit_l : TemperDragonFruit

@export var temper_fruit_r : TemperDragonFruit

@export var room_side_trigger : Trigger

@export var fireball_projectile_scene : PackedScene

@export var projectile_launch_offset : float = 32

var is_player_on_right_side : bool = false

var is_boss_on_right_side : bool = true

var current_weakness : StringName = "NONE"

var current_defense : int = 1

var current_spike_reference : FloorSpikes

func _ready():
	super._ready()
	room_side_trigger.trigger_exited.connect(on_side_trigger_exited)
	if (textbox != null):
		textbox.textbox_finished.connect(on_dialogue_intro_finished)

func _physics_process(delta):
	check_temper_fruit_spawn()
	update_invulnerability_duration(delta)
	if (textbox.current_state != Textbox.TextboxState.READY and textbox.unformatted_text.contains("{player_name}")):
		textbox.update_player_name_format_text(player_hub.form.get_current_form_name())

func on_activation():
	update_weakness_and_defense()
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
	floor_spikes_l.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
	floor_spikes_r.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)

func on_defeat():
	is_activated = false
	if (clear_timer != null):
		clear_timer.stop_timer()
	if (boss_music_player != null):
		boss_music_player.fade_out()
	if (player_hub.temper.is_forcing_form_change() or player_hub.temper.is_form_locked()):
		player_hub.temper.set_boss_courtesy_temper_level()
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
	floor_spikes_l.force_reset()
	floor_spikes_r.force_reset()
	floor_spikes_l.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
	floor_spikes_r.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)

func damage_boss(_damage_type : StringName, _damage_strength : int, _knockback_vector : Vector2, _is_projectile : bool = false):
	if (current_invulnerability_duration > 0 or current_health <= 0):
		return false
	
	if (current_armor <= 0 and is_knockback_enabled and state_machine.current_state.name == "Stunned" and state_machine.current_state.has_method("apply_knockback")):
		state_machine.current_state.apply_knockback(abs(_knockback_vector.x), 1.0 if _knockback_vector.x >= 0 else -1.0)
		SoundFactory.play_sound_by_name("damage_enemy", body.global_position, 0, 1, "SFX")
		return true
	elif (current_armor > 0 and (_damage_type == current_weakness or current_weakness == "ANY") and _damage_strength >= current_defense):
		current_armor -= 1
		SoundFactory.play_sound_by_name("damage_enemy", body.global_position, 0, 1, "SFX")
		if (current_armor <= 0):
			SoundFactory.play_sound_by_name("object_block_breakable" if current_health > 2 else "object_block_reinforced", body.global_position, 0, 1, "SFX")
		do_post_hit_invulnerability()
		return true
	else:
		return false

func set_current_weakness(damage_type : StringName):
	if (current_weakness != damage_type):
		current_weakness = damage_type

func set_current_defense(defense : int):
	current_defense = defense

func spawn_fireball(cancel_horizontal : bool = false):
	var temp_node : Node = fireball_projectile_scene.instantiate()
	add_sibling(temp_node)
	(temp_node as Node2D).global_position = (global_position + ((Vector2.ZERO if cancel_horizontal else Vector2.RIGHT) * projectile_launch_offset * get_facing_value()))
	if (temp_node is EnemyProjectile):
		var temp_proj : EnemyProjectile = (temp_node as EnemyProjectile)
		temp_proj.boss_setup(self)
		if (cancel_horizontal):
			temp_proj.velocity.x = 0

func update_weakness_and_defense():
	match current_health:
		4:
			set_current_weakness("MAGIC")
			set_current_defense(1)
		3:
			set_current_weakness("FIRE")
			set_current_defense(1)
		2:
			set_current_weakness("MAGIC")
			set_current_defense(2)
		1:
			set_current_weakness("FIRE")
			set_current_defense(2)
		_:
			pass

func set_current_spike_reference(spikes : FloorSpikes):
	current_spike_reference = spikes

func unset_current_spike_reference():
	current_spike_reference = null

func check_temper_fruit_spawn():
	if (player_hub == null):
		return
	
	if (is_activated and player_hub.temper.is_form_locked() and temper_fruit_l.is_despawned() and temper_fruit_r.is_despawned()):
		var chosen_fruit_side : TemperDragonFruit = (temper_fruit_r if !is_player_on_right_side else temper_fruit_l)
		chosen_fruit_side.set_starting_state(-1 if player_hub.form.is_a_mage() else 1)
		chosen_fruit_side.do_respawn(true)

func check_player_collision():
	if (is_activated and is_player_in_collider and current_invulnerability_duration <= 0):
		if (player_hub.damage.take_damage(1 if body.global_position.x < player_hub.char_body.global_position.x else -1)):
			EffectFactory.get_effect("EnemyContactImpact", player_hub.char_body.global_position)
			SoundFactory.play_sound_by_name("enemy_contact_impact", player_hub.char_body.global_position, 0, 1, "SFX")

func on_side_trigger_exited():
	is_player_on_right_side = (player_hub.char_body.global_position.x > room_side_trigger.global_position.x)

func on_dialogue_intro_finished():
	if (is_activated):
		player_hub.set_force_stand(false)
		state_machine.set_process_mode(PROCESS_MODE_INHERIT)
		if (boss_music_player != null):
			boss_music_player.restart_music()
		if (clear_timer != null):
			clear_timer.start_timer()
		await get_tree().process_frame # prevents pausing on the same frame
		PauseHandler.enable_pausing(true)
		textbox.textbox_finished.disconnect(on_dialogue_intro_finished)

func on_dialogue_defeat_finished():
	player_hub.set_force_stand(false)
	release_camera_past_boss_room()
	(boss_room_boundary_tilemap.get_child(1) as TileMapLayer).enabled = false
	(boss_room_boundary_tilemap.get_child(3) as TileMapLayer).enabled = false
	state_machine.set_process_mode(PROCESS_MODE_DISABLED)
	if (normal_level_music_player != null):
		normal_level_music_player.restart_music()
	if (clear_timer != null):
		clear_timer.start_timer()
	await get_tree().process_frame # prevents pausing on the same frame
	PauseHandler.enable_pausing(true)
	textbox.textbox_finished.disconnect(on_dialogue_defeat_finished)
