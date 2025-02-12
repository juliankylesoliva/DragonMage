extends MenuTemplate

class_name LevelSelectMenu

@export var level_info_list : Array[LevelInfo]

@export var screen_fade : ScreenFade

@export var level_name_label : RichTextLabel

@export var level_description_label : RichTextLabel

@export var level_ctrl_prompt : ButtonPromptTextLabel

@export_multiline var default_level_ctrl_text : String

@export_multiline var form_level_ctrl_text : String

@export var magli_name_sprite_path : String = "res://Sprites/UI/MagliNameSprite.png"

@export var draelyn_name_sprite_path : String = "res://Sprites/UI/DraelynNameSprite.png"

func _ready():
	max_selections = level_info_list.size()
	current_selection = clampi(NextLevelHelper.next_level_menu_index, 0, level_info_list.size() - 1)
	max_secondary_selections = level_info_list[current_selection].story_description.size()
	update_level_select_text(level_info_list[current_selection])

func on_menu_activation():
	max_selections = level_info_list.size()
	menu_cursor.global_position = get_label_center(level_name_label)
	menu_cursor.set_spacing(get_label_width(level_name_label))

func on_selection_confirm():
	menu_cursor.do_selection_movement()
	start_game()

func on_menu_cancel():
	if (previous_menu != null):
		self.deactivate_menu()
		previous_menu.activate_menu()
		previous_menu = null
		menu_cursor.play_cancel_sound()

func on_change_form():
	if (level_info_list[current_selection].form_changing_enabled):
		if (FormSelectionHelper.selected_form == FormSelectionHelper.mage_form):
			menu_cursor.play_cancel_sound()
		else:
			menu_cursor.play_accept_sound()
		FormSelectionHelper.toggle_selected_form()
		update_level_select_text(level_info_list[current_selection])

func on_left_pressed():
	decrement_selection()
	reset_secondary_selection()

func on_right_pressed():
	increment_selection()
	reset_secondary_selection()

func on_up_pressed():
	decrement_secondary_selection()

func on_down_pressed():
	increment_secondary_selection()

func on_selection_reset():
	update_level_select_text(level_info_list[current_selection])
	max_secondary_selections = level_info_list[current_selection].story_description.size()

func on_selection_change():
	reset_secondary_selection()
	max_secondary_selections = level_info_list[current_selection].story_description.size()
	update_level_select_text(level_info_list[current_selection])
	menu_cursor.play_move_sound()

func on_secondary_selection_change():
	update_level_select_text(level_info_list[current_selection])
	menu_cursor.play_move_sound()

func update_level_select_text(info : LevelInfo):
	level_name_label.text = info.name_header
	level_description_label.text = info.story_description[current_secondary_selection]
	level_ctrl_prompt.raw_text = (form_level_ctrl_text.format({"file" : magli_name_sprite_path if FormSelectionHelper.is_mage_selected() else draelyn_name_sprite_path}) if info.form_changing_enabled else default_level_ctrl_text)
	level_ctrl_prompt.refresh_label_text()
	FormSelectionHelper.form_changing_enabled = info.form_changing_enabled

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x

func start_game():
	if (!enable_input):
		return
	
	NextLevelHelper.set_next_level_menu_index(current_selection)
	
	enable_input = false
	
	await get_tree().create_timer(1.0).timeout
	
	screen_fade.set_fade(1, 1, Color.BLACK)
	
	#await get_tree().create_timer(2.0).timeout
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(switch_to_selected_level)
	timer.start(2.0)

func switch_to_selected_level():
	get_tree().change_scene_to_file(level_info_list[current_selection].level_scene_path)
