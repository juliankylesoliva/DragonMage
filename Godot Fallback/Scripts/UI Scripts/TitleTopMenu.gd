extends MenuTemplate

class_name TitleTopMenu

@export var menu_labels : Array[RichTextLabel]

@export var level_select_subscreen : MenuTemplate

@export var options_subscreen : MenuTemplate

@export var credits_subscreen : MenuTemplate

func _ready():
	PauseHandler.enable_pausing(false)
	self.activate_menu()
	level_select_subscreen.deactivate_menu()
	options_subscreen.deactivate_menu()
	credits_subscreen.deactivate_menu()
	update_cursor()

func on_menu_activation():
	max_selections = menu_labels.size()
	update_cursor()

func on_selection_change():
	update_cursor()
	menu_cursor.play_move_sound()

func on_up_pressed():
	decrement_selection()

func on_down_pressed():
	increment_selection()

func on_selection_confirm():
	match current_selection:
		0:
			menu_cursor.play_accept_sound()
			self.deactivate_menu()
			level_select_subscreen.set_previous_menu(self)
			level_select_subscreen.activate_menu()
		1:
			options_subscreen.reset_selection()
			menu_cursor.play_accept_sound()
			self.deactivate_menu()
			options_subscreen.set_previous_menu(self)
			options_subscreen.activate_menu()
		2:
			credits_subscreen.reset_selection()
			menu_cursor.play_accept_sound()
			self.deactivate_menu()
			credits_subscreen.set_previous_menu(self)
			credits_subscreen.activate_menu()
			menu_cursor.hide()
		3:
			get_tree().quit()
		_:
			pass
	menu_cursor.play_accept_sound()

func update_cursor():
	menu_cursor.global_position = get_label_center(menu_labels[current_selection])
	menu_cursor.set_spacing(get_label_width(menu_labels[current_selection]))

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x
