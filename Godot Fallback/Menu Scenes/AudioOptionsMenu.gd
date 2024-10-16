extends MenuTemplate

class_name AudioOptionsMenu

@export var option_labels : Array[RichTextLabel]

@export var master_volume_value_label : RichTextLabel

@export var music_volume_value_label : RichTextLabel

@export var sfx_volume_value_label : RichTextLabel

@export var up_down_hold_repeat_interval : float = 0.1

@export var left_right_hold_repeat_interval : float = 0.01

func on_menu_activation():
	max_selections = option_labels.size()
	update_text()

func on_selection_reset():
	update_cursor()

func on_selection_change():
	update_cursor()
	menu_cursor.play_move_sound()

func update_cursor():
	menu_cursor.global_position = get_label_center(option_labels[current_selection])
	menu_cursor.set_spacing(get_label_width(option_labels[current_selection]))

func on_up_pressed():
	direction_hold_repeat_interval = up_down_hold_repeat_interval
	decrement_selection()

func on_down_pressed():
	direction_hold_repeat_interval = up_down_hold_repeat_interval
	increment_selection()

func on_left_pressed():
	var do_play_sound : bool = false
	direction_hold_repeat_interval = left_right_hold_repeat_interval
	match current_selection:
		0:
			do_play_sound = (OptionsHelper.master_volume > OptionsHelper.MIN_VOLUME)
			OptionsHelper.decrease_master_volume()
		1:
			do_play_sound = (OptionsHelper.music_volume > OptionsHelper.MIN_VOLUME)
			OptionsHelper.decrease_music_volume()
		2:
			do_play_sound = (OptionsHelper.sfx_volume > OptionsHelper.MIN_VOLUME)
			OptionsHelper.decrease_sfx_volume()
		_:
			pass
	if (do_play_sound and !is_holding_a_direction):
		menu_cursor.play_move_sound()
	update_text()

func on_right_pressed():
	var do_play_sound : bool = false
	direction_hold_repeat_interval = left_right_hold_repeat_interval
	match current_selection:
		0:
			do_play_sound = (OptionsHelper.master_volume < OptionsHelper.MAX_VOLUME)
			OptionsHelper.increase_master_volume()
		1:
			do_play_sound = (OptionsHelper.music_volume < OptionsHelper.MAX_VOLUME)
			OptionsHelper.increase_music_volume()
		2:
			do_play_sound = (OptionsHelper.sfx_volume < OptionsHelper.MAX_VOLUME)
			OptionsHelper.increase_sfx_volume()
		_:
			pass
	if (do_play_sound and !is_holding_a_direction):
		menu_cursor.play_move_sound()
	update_text()

func on_selection_confirm():
	menu_cursor.play_accept_sound()

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()

func update_text():
	master_volume_value_label.text = OptionsHelper.get_master_volume_text()
	music_volume_value_label.text = OptionsHelper.get_music_volume_text()
	sfx_volume_value_label.text = OptionsHelper.get_sfx_volume_text()

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x
