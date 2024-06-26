extends Node

class_name TitleMenuSystem

@export var level_info_list : Array[LevelInfo]

@export var menu_cursor : MenuCursor

@export var screen_fade : ScreenFade

@export var start_label : RichTextLabel

@export var options_label : RichTextLabel

@export var credits_label : RichTextLabel

@export var exit_label : RichTextLabel

@export var level_name_label : RichTextLabel

@export var level_description_label : RichTextLabel

@export var level_ctrl_prompt : ButtonPromptTextLabel

@export_multiline var default_level_ctrl_text : String

@export_multiline var form_level_ctrl_text : String

@export var magli_name_sprite_path : String = "res://Sprites/UI/MagliNameSprite.png"

@export var draelyn_name_sprite_path : String = "res://Sprites/UI/DraelynNameSprite.png"

@export var credit_page_label : RichTextLabel

@export var top_menu_screen : Node2D

@export var level_select_subscreen : Node2D

@export var credits_subscreen : Node2D

@export_multiline var credit_text_pages : Array[String]

var is_input_allowed : bool = true

var current_menu_selection : int = 0

var current_level_selection : int = 0

var current_level_desc_page : int = 0

var current_credits_page : int = 0

func _ready():
	PauseHandler.enable_pausing(false)
	top_menu_screen.set_visible(true)
	level_select_subscreen.set_visible(false)
	credits_subscreen.set_visible(false)
	current_level_selection = clampi(NextLevelHelper.next_level_menu_index, 0, level_info_list.size() - 1)
	update_cursor_position()
	update_level_select_text(level_info_list[current_level_selection])

func _physics_process(_delta):
	move_menu_cursor()
	update_credits_subscreen()
	do_level_selection()
	do_top_menu_selection()
	return_to_top_menu()

func is_in_subscreen():
	return (!top_menu_screen.visible and (level_select_subscreen.visible or credits_subscreen.visible))

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x

func move_menu_cursor():
	if (!is_input_allowed or is_in_subscreen()):
		return
	
	var up_pressed : bool = Input.is_action_just_pressed("Menu Up")
	var down_pressed : bool = Input.is_action_just_pressed("Menu Down")
	
	if ((up_pressed and !down_pressed) or (!up_pressed and down_pressed)):
		if (up_pressed):
			current_menu_selection -= 1
			if (current_menu_selection < 0):
				current_menu_selection = 3
		else:
			current_menu_selection += 1
			if (current_menu_selection > 3):
				current_menu_selection = 0
		menu_cursor.play_move_sound()
		update_cursor_position()

func update_cursor_position():
	match current_menu_selection:
		0:
			menu_cursor.global_position = get_label_center(start_label)
			menu_cursor.set_spacing(get_label_width(start_label))
		1:
			menu_cursor.global_position = get_label_center(options_label)
			menu_cursor.set_spacing(get_label_width(options_label))
		2:
			menu_cursor.global_position = get_label_center(credits_label)
			menu_cursor.set_spacing(get_label_width(credits_label))
		3:
			menu_cursor.global_position = get_label_center(exit_label)
			menu_cursor.set_spacing(get_label_width(exit_label))
		_:
			pass

func do_top_menu_selection():
	if (is_input_allowed and !is_in_subscreen() and Input.is_action_just_pressed("Menu Confirm")):
		match current_menu_selection:
			0:
				current_level_desc_page = 0
				menu_cursor.play_accept_sound()
				top_menu_screen.set_visible(false)
				level_select_subscreen.set_visible(true)
				menu_cursor.global_position = get_label_center(level_name_label)
				menu_cursor.set_spacing(get_label_width(level_name_label))
			1:
				pass
			2:
				current_credits_page = 0
				credit_page_label.text = credit_text_pages[current_credits_page]
				menu_cursor.play_accept_sound()
				top_menu_screen.set_visible(false)
				credits_subscreen.set_visible(true)
				menu_cursor.set_visible(false)
			3:
				get_tree().quit()
			_:
				pass

func do_level_selection():
	if (is_input_allowed and is_in_subscreen() and level_select_subscreen.visible):
		var left_pressed : bool = Input.is_action_just_pressed("Menu Left")
		var right_pressed : bool = Input.is_action_just_pressed("Menu Right")
		var up_pressed : bool = Input.is_action_just_pressed("Menu Up")
		var down_pressed : bool = Input.is_action_just_pressed("Menu Down")
		if (Input.is_action_just_pressed("Menu Confirm")):
			menu_cursor.do_selection_movement()
			start_game()
		elif (level_info_list[current_level_selection].form_changing_enabled and Input.is_action_just_pressed("Change Form")):
			if (FormSelectionHelper.selected_form == FormSelectionHelper.mage_form):
				menu_cursor.play_cancel_sound()
			else:
				menu_cursor.play_accept_sound()
			FormSelectionHelper.toggle_selected_form()
			update_level_select_text(level_info_list[current_level_selection])
		elif ((left_pressed or right_pressed) and !(left_pressed and right_pressed)):
			if (left_pressed):
				if (current_level_selection > 0):
					current_level_selection -= 1
				else:
					current_level_selection = (level_info_list.size() - 1)
				current_level_desc_page = 0
			elif (right_pressed):
				if (current_level_selection < (level_info_list.size() - 1)):
					current_level_selection += 1
				else:
					current_level_selection = 0
				current_level_desc_page = 0
			else:
				pass
			menu_cursor.play_move_sound()
			update_level_select_text(level_info_list[current_level_selection])
		elif ((up_pressed or down_pressed) and !(up_pressed and down_pressed)):
			if (up_pressed):
				if (current_level_desc_page > 0):
					current_level_desc_page -= 1
					menu_cursor.play_move_sound()
			elif (down_pressed):
				if (current_level_desc_page < (level_info_list[current_level_selection].story_description.size() - 1)):
					current_level_desc_page += 1
					menu_cursor.play_move_sound()
			else:
				pass
			update_level_select_text(level_info_list[current_level_selection])
		else:
			pass

func update_credits_subscreen():
	if (is_input_allowed and is_in_subscreen() and credits_subscreen.visible):
		var left_pressed : bool = Input.is_action_just_pressed("Menu Left")
		var right_pressed : bool = Input.is_action_just_pressed("Menu Right")
		if ((left_pressed or right_pressed) and !(left_pressed and right_pressed)):
			if (left_pressed):
				if (current_credits_page > 0):
					current_credits_page -= 1
				else:
					current_credits_page = (credit_text_pages.size() - 1)
			elif(right_pressed):
				if (current_credits_page < (credit_text_pages.size() - 1)):
					current_credits_page += 1
				else:
					current_credits_page = 0
			else:
				pass
			
			credit_page_label.text = credit_text_pages[current_credits_page]
			menu_cursor.play_move_sound()

func update_level_select_text(info : LevelInfo):
	level_name_label.text = info.name_header
	level_description_label.text = info.story_description[current_level_desc_page]
	level_ctrl_prompt.raw_text = (form_level_ctrl_text.format({"file" : magli_name_sprite_path if FormSelectionHelper.is_mage_selected() else draelyn_name_sprite_path}) if info.form_changing_enabled else default_level_ctrl_text)
	level_ctrl_prompt.refresh_label_text()
	FormSelectionHelper.form_changing_enabled = info.form_changing_enabled

func return_to_top_menu():
	if (is_input_allowed and is_in_subscreen() and Input.is_action_just_pressed("Menu Cancel")):
		menu_cursor.play_cancel_sound()
		level_select_subscreen.set_visible(false)
		credits_subscreen.set_visible(false)
		top_menu_screen.set_visible(true)
		menu_cursor.set_visible(true)
		update_cursor_position()

func start_game():
	if (!is_input_allowed):
		return
	
	NextLevelHelper.set_next_level_menu_index(current_level_selection)
	
	is_input_allowed = false
	
	await get_tree().create_timer(1.0).timeout
	
	screen_fade.set_fade(1, 1, Color.BLACK)
	
	await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file(level_info_list[current_level_selection].level_scene_path)
