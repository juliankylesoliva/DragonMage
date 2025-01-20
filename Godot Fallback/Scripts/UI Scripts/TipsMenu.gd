extends MenuTemplate

class_name TipsMenu

@export var category_text_label : RichTextLabel

@export var option_labels : Array[RichTextLabel]

@export var category_names : Array[String]

@export var general_tips : Array[TipEntry]

@export var mage_tips : Array[TipEntry]

@export var dragon_tips : Array[TipEntry]

@export var fun_tips : Array[TipEntry]

@export var tip_subscreen : TipSubscreenMenu

var current_page_index : int = 0

var max_pages : int = 0

func on_menu_activation():
	max_secondary_selections = category_names.size()
	max_pages = (ceilf((get_current_category_entries().size() as float) / option_labels.size()) as int)
	update_page_selections()
	update_cursor()

func on_selection_reset():
	update_cursor()

func on_selection_change():
	update_cursor()
	menu_cursor.play_move_sound()

func on_secondary_selection_change():
	current_page_index = 0
	current_selection = 0
	max_pages = (ceilf((get_current_category_entries().size() as float) / option_labels.size()) as int)
	update_page_selections()
	update_cursor()
	menu_cursor.play_move_sound()

func on_up_pressed():
	decrement_selection()

func on_down_pressed():
	increment_selection()

func on_right_pressed():
	increment_secondary_selection()

func on_left_pressed():
	decrement_secondary_selection()

func on_selection_wraparound(increment : bool = false):
	if (max_pages < 2):
		return
	
	if (increment):
		if (current_page_index < (max_pages - 1) or enable_wraparound):
			current_page_index += 1
			if (current_page_index >= max_pages):
				current_page_index = 0
	else:
		if (current_page_index > 0 or enable_wraparound):
			current_page_index -= 1
			if (current_page_index < 0):
				current_page_index = (max_pages - 1)
	update_page_selections()
	if (!increment):
		current_selection = (max_selections - 1)

func on_selection_confirm():
	tip_subscreen.reset_selection()
	menu_cursor.play_accept_sound()
	self.deactivate_menu()
	tip_subscreen.set_previous_menu(self)
	tip_subscreen.activate_menu()
	menu_cursor.hide()

func on_menu_cancel():
	if (previous_menu != null):
		current_page_index = 0
		reset_selection()
		reset_secondary_selection()
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()

func get_current_category_entries():
	match current_secondary_selection:
		0:
			return general_tips
		1:
			return mage_tips
		2:
			return dragon_tips
		3:
			return fun_tips
		_:
			return general_tips

func update_cursor():
	menu_cursor.global_position = get_label_center(option_labels[current_selection])
	menu_cursor.set_spacing(get_label_width(option_labels[current_selection]))

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x

func update_page_selections():
	category_text_label.text = ("[center]%s" % category_names[current_secondary_selection])
	max_selections = (min(get_current_category_entries().size(), (current_page_index * option_labels.size()) + option_labels.size()) - (current_page_index * option_labels.size()))
	for i in option_labels.size():
		if (i < max_selections):
			option_labels[i].set_visible(true)
			option_labels[i].text = get_current_category_entries()[i + (current_page_index * option_labels.size())].tip_title
		else:
			option_labels[i].set_visible(false)
	if (current_selection >= max_selections):
		current_selection = (max_selections - 1)

func get_selected_tip():
	return get_current_category_entries()[current_selection + (current_page_index * option_labels.size())]
