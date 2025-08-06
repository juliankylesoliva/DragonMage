extends Boss

class_name ImpostorBoss

@export var fyerlarm_l : Fyerlarm

@export var fyerlarm_r : Fyerlarm

@export var sword_projectile_scene : PackedScene

@export var fire_bullet_projectile_scene : PackedScene

@export var projectile_launch_offset : float = 48

@export var parry_damage : int = 3

@export_multiline var introduction_text_2 : Array[String]

var first_fyerlarm_hit : bool = false

var second_intro_finished : bool = false

var is_invisible : bool = false

func _ready():
	super._ready()
	if (textbox != null):
		textbox.textbox_finished.connect(on_dialogue_intro_finished)

func _physics_process(delta):
	update_invulnerability_duration(delta)
	if (textbox.current_state != Textbox.TextboxState.READY and textbox.unformatted_text.contains("{player_name}")):
		textbox.update_player_name_format_text(player_hub.form.get_current_form_name())

func on_activation():
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

func on_first_fyerlarm_hit():
	if (player_hub.temper.is_forcing_form_change() or player_hub.temper.is_form_locked()):
		player_hub.temper.set_boss_courtesy_temper_level()
	if (textbox != null):
		if (introduction_text_2.size() > 0):
			PauseHandler.enable_pausing(false)
			player_hub.set_force_stand(true)
			textbox.accept_input_events = true
			textbox.textbox_finished.connect(on_second_dialogue_intro_finished)
			if (clear_timer != null):
				clear_timer.stop_timer()
			for text in introduction_text_2:
				textbox.queue_text(text)
		else:
			on_second_dialogue_intro_finished()

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

func damage_boss(_damage_type : StringName, _damage_strength : int = 0, _knockback_vector : Vector2 = Vector2.ZERO, _is_projectile : bool = false):
	if (current_invulnerability_duration > 0 or current_health <= 0):
		return false
	
	if (current_armor > 0):
		if (_damage_type == "HAZARD"):
			if (first_fyerlarm_hit):
				current_armor -= 1
			else:
				first_fyerlarm_hit = true
			SoundFactory.play_sound_by_name("damage_enemy", body.global_position, 0, 1, "SFX")
			do_post_hit_invulnerability()
			return true
	else:
		if (!is_invisible):
			current_health -= (parry_damage if _damage_type == "PARRY" else 1)
			if (current_health <= 0):
				current_health = 0
				on_defeat()
			SoundFactory.play_sound_by_name("damage_enemy", body.global_position, 0, 1, "SFX")
			do_post_hit_invulnerability()
			return true
	return false

func spawn_sword_projectile(path : Path2D, is_reverse : bool, is_facing_right : bool):
	var temp_node : Node = sword_projectile_scene.instantiate()
	path.add_child(temp_node)
	
	var temp_proj : ImpostorSwordProjectile = (temp_node as ImpostorSwordProjectile)
	temp_proj.start_moving(is_reverse, is_facing_right)
	
	return temp_proj

func spawn_fire_bullet(direction : Vector2):
	var temp_node : Node = fire_bullet_projectile_scene.instantiate()
	add_sibling(temp_node)
	(temp_node as Node2D).global_position = (global_position + (direction.normalized() * projectile_launch_offset))
	if (temp_node is EnemyProjectile):
		var temp_proj : EnemyProjectile = (temp_node as EnemyProjectile)
		temp_proj.boss_setup(self, direction.normalized())

func check_player_collision():
	if (is_activated and is_player_in_collider and current_invulnerability_duration <= 0):
		if (player_hub.damage.take_damage(1 if body.global_position.x < player_hub.char_body.global_position.x else -1)):
			EffectFactory.get_effect("EnemyContactImpact", player_hub.char_body.global_position)
			SoundFactory.play_sound_by_name("enemy_contact_impact", player_hub.char_body.global_position, 0, 1, "SFX")
		elif (player_hub.damage.is_player_parrying()):
			self.damage_boss("PARRY")

func on_dialogue_intro_finished():
	if (is_activated):
		player_hub.set_force_stand(false)
		state_machine.set_process_mode(PROCESS_MODE_INHERIT)
		if (clear_timer != null):
			clear_timer.start_timer()
		await get_tree().process_frame # prevents pausing on the same frame
		PauseHandler.enable_pausing(true)
		textbox.textbox_finished.disconnect(on_dialogue_intro_finished)

func on_second_dialogue_intro_finished():
	if (is_activated):
		player_hub.set_force_stand(false)
		if (clear_timer != null):
			clear_timer.start_timer()
		await get_tree().process_frame # prevents pausing on the same frame
		PauseHandler.enable_pausing(true)
		textbox.textbox_finished.disconnect(on_second_dialogue_intro_finished)
		second_intro_finished = true

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
	self.sprite.set_visible(false)
