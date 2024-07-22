extends MenuTemplate

class_name CreditsMenu

@export var credit_page_label : RichTextLabel

@export_multiline var credit_text_pages : Array[String]

func on_menu_activation():
	max_selections = credit_text_pages.size()
	update_text()

func on_selection_reset():
	update_text()

func on_selection_change():
	update_text()
	menu_cursor.play_move_sound()

func on_left_pressed():
	decrement_selection()

func on_right_pressed():
	increment_selection()

func update_text():
	credit_page_label.text = credit_text_pages[current_selection]

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()
		menu_cursor.show()
