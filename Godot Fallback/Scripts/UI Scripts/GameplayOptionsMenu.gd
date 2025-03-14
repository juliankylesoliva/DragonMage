extends MenuTemplate

class_name GameplayOptionsMenu

@export var option_labels : Array[RichTextLabel]

@export var glide_toggle_state_label : RichTextLabel

@export var crouch_toggle_state_label : RichTextLabel

@export var quick_restart_toggle_state_label : RichTextLabel

@export var clear_timer_toggle_state_label : RichTextLabel

@export_multiline var option_descriptions : Array[String]

@export var options_description_label : RichTextLabel

func on_menu_activation():
	max_selections = option_labels.size()
	update_text()
	update_description_text()

func on_selection_reset():
	update_cursor()
	update_description_text()

func on_selection_change():
	update_cursor()
	update_description_text()
	menu_cursor.play_move_sound()

func update_cursor():
	menu_cursor.global_position = get_label_center(option_labels[current_selection])
	menu_cursor.set_spacing(get_label_width(option_labels[current_selection]))

func update_description_text():
	options_description_label.text = option_descriptions[current_selection]

func on_up_pressed():
	decrement_selection()

func on_down_pressed():
	increment_selection()

func on_selection_confirm():
	match current_selection:
		0:
			OptionsHelper.switch_glide_toggle()
			update_text()
		1:
			OptionsHelper.switch_crouch_toggle()
			update_text()
		2:
			OptionsHelper.switch_quick_restart_toggle()
			update_text()
		3:
			OptionsHelper.switch_clear_timer_toggle()
			update_text()
		_:
			pass
	menu_cursor.play_accept_sound()

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()

func update_text():
	glide_toggle_state_label.text = ("ON" if OptionsHelper.enable_glide_toggle else "OFF")
	crouch_toggle_state_label.text = ("ON" if OptionsHelper.enable_crouch_toggle else "OFF")
	quick_restart_toggle_state_label.text = ("ON" if OptionsHelper.enable_quick_restart_toggle else "OFF")
	clear_timer_toggle_state_label.text = ("ON" if OptionsHelper.enable_clear_timer_toggle else "OFF")

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x
