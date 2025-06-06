extends MenuTemplate

class_name OptionsMenu

@export var option_labels : Array[RichTextLabel]

@export_multiline var option_descriptions : Array[String]

@export var options_description_label : RichTextLabel

@export var gameplay_options_subscreen : MenuTemplate

@export var audio_options_subscreen : MenuTemplate

@export var bindings_subscreen : MenuTemplate

func on_menu_activation():
	max_selections = option_labels.size()
	update_cursor()
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
			if (gameplay_options_subscreen != null):
				gameplay_options_subscreen.reset_selection()
				menu_cursor.play_accept_sound()
				self.deactivate_menu()
				gameplay_options_subscreen.set_previous_menu(self)
				gameplay_options_subscreen.activate_menu()
		1:
			if (audio_options_subscreen != null):
				audio_options_subscreen.reset_selection()
				menu_cursor.play_accept_sound()
				self.deactivate_menu()
				audio_options_subscreen.set_previous_menu(self)
				audio_options_subscreen.activate_menu()
		2:
			if (bindings_subscreen != null):
				bindings_subscreen.reset_selection()
				self.deactivate_menu()
				bindings_subscreen.set_previous_menu(self)
				bindings_subscreen.activate_menu()
				menu_cursor.hide()
		_:
			pass
	menu_cursor.play_accept_sound()

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x
