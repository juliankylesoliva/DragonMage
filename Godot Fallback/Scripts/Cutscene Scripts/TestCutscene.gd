extends CutsceneDirectorBase

@export var player_ref : PlayerHub

func _process(_delta):
	if (textbox.unformatted_text.contains("{player_name}")):
		textbox.update_player_name_format_text(player_ref.form.get_current_form_name())

func lights_camera_action():
	cast_dictionary["MD"].set_visible(true)
	PauseHandler.enable_pausing(false)
	player_ref.set_force_stand(true)
	cast_dictionary["MD"].do_move(-128, 2)
	cast_dictionary["MD"].actor_anim_sprite.play("MagliMove")
	await get_tree().create_timer(0.25).timeout
	cast_dictionary["MD"].do_jump(320)
	cast_dictionary["MD"].actor_anim_sprite.play("MagliJump")
	await cast_dictionary["MD"].actor_falling
	cast_dictionary["MD"].actor_anim_sprite.play("MagliFall")
	await cast_dictionary["MD"].actor_landing
	cast_dictionary["MD"].actor_anim_sprite.play("MagliMove")
	await cast_dictionary["MD"].actor_movement_finished
	cast_dictionary["MD"].actor_anim_sprite.play("MagliStand")
	say_the_lines(0, 2)
	textbox.accept_input_events = true
	await textbox.textbox_finished
	textbox.accept_input_events = false
	cast_dictionary["MD"].do_move(128, 2)
	cast_dictionary["MD"].actor_anim_sprite.play("MagliMove")
	await get_tree().create_timer(0.5).timeout
	cast_dictionary["MD"].do_jump(320)
	cast_dictionary["MD"].actor_anim_sprite.play("MagliJump")
	await get_tree().create_timer(0.25).timeout
	cast_dictionary["MD"].do_shorten_jump(0.1)
	cast_dictionary["MD"].actor_anim_sprite.play("MagliFall")
	await cast_dictionary["MD"].actor_landing
	cast_dictionary["MD"].actor_anim_sprite.play("MagliMove")
	await cast_dictionary["MD"].actor_movement_finished
	cast_dictionary["MD"].actor_anim_sprite.play("MagliStand")
	cast_dictionary["MD"].set_visible(false)
	say_the_lines(3, 4)
	textbox.accept_input_events = true
	await textbox.textbox_finished
	textbox.accept_input_events = false
	await get_tree().process_frame
	PauseHandler.enable_pausing(true)
	player_ref.set_force_stand(false)
