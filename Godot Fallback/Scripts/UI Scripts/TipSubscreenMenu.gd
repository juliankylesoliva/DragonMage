extends MenuTemplate

class_name TipSubscreenMenu

@export var tip_title_label : RichTextLabel

@export var tip_desc_label : ButtonPromptTextLabel

@export var tips_top_menu : TipsMenu

var selected_tip : TipEntry = null

func on_menu_activation():
	selected_tip = tips_top_menu.get_selected_tip()
	max_selections = selected_tip.tip_description.size()
	tip_title_label.text = ("[left]%s" % selected_tip.tip_title)
	tip_desc_label.set_raw_text("[left]%s" % selected_tip.tip_description[current_selection])

func on_selection_change():
	update_description()
	menu_cursor.play_move_sound()

func on_right_pressed():
	increment_selection()

func on_left_pressed():
	decrement_selection()

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()
		menu_cursor.show()

func update_description():
	tip_desc_label.text = ("[left]%s" % selected_tip.tip_description[current_selection])
