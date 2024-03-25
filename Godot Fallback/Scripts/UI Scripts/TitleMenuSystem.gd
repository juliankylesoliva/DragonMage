extends Node

class_name TitleMenuSystem

@export var level_info_list : Array[LevelInfo]

@export var menu_cursor : MenuCursor

@export var screen_fade : ScreenFade

@export var start_label : RichTextLabel

@export var credits_label : RichTextLabel

@export var exit_label : RichTextLabel

@export var level_name_label : RichTextLabel

@export var level_description_label : RichTextLabel

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
	
	var up_pressed : bool = Input.is_action_just_pressed("Move Up")
	var down_pressed : bool = Input.is_action_just_pressed("Move Down")
	
	if ((up_pressed and !down_pressed) or (!up_pressed and down_pressed)):
		if (up_pressed):
			current_menu_selection -= 1
			if (current_menu_selection < 0):
				current_menu_selection = 2
		else:
			current_menu_selection += 1
			if (current_menu_selection > 2):
				current_menu_selection = 0
		menu_cursor.play_move_sound()
		update_cursor_position()

func update_cursor_position():
	match current_menu_selection:
		0:
			menu_cursor.global_position = get_label_center(start_label)
			menu_cursor.set_spacing(get_label_width(start_label))
		1:
			menu_cursor.global_position = get_label_center(credits_label)
			menu_cursor.set_spacing(get_label_width(credits_label))
		2:
			menu_cursor.global_position = get_label_center(exit_label)
			menu_cursor.set_spacing(get_label_width(exit_label))
		_:
			pass

func do_top_menu_selection():
	if (is_input_allowed and !is_in_subscreen() and Input.is_action_just_pressed("Jump")):
		match current_menu_selection:
			0:
				menu_cursor.play_accept_sound()
				top_menu_screen.set_visible(false)
				level_select_subscreen.set_visible(true)
				menu_cursor.global_position = get_label_center(level_name_label)
				menu_cursor.set_spacing(get_label_width(level_name_label))
			1:
				current_credits_page = 0
				credit_page_label.text = credit_text_pages[current_credits_page]
				menu_cursor.play_accept_sound()
				top_menu_screen.set_visible(false)
				credits_subscreen.set_visible(true)
				menu_cursor.set_visible(false)
			2:
				get_tree().quit()
			_:
				pass

func do_level_selection():
	if (is_input_allowed and is_in_subscreen() and level_select_subscreen.visible):
		var left_pressed : bool = Input.is_action_just_pressed("Move Left")
		var right_pressed : bool = Input.is_action_just_pressed("Move Right")
		if (Input.is_action_just_pressed("Jump")):
			menu_cursor.do_selection_movement()
			start_game()
		elif ((left_pressed or right_pressed) and !(left_pressed and right_pressed)):
			if (left_pressed):
				if (current_level_selection > 0):
					current_level_selection -= 1
				else:
					current_level_selection = (level_info_list.size() - 1)
			elif (right_pressed):
				if (current_level_selection < (level_info_list.size() - 1)):
					current_level_selection += 1
				else:
					current_level_selection = 0
			else:
				pass
			menu_cursor.play_move_sound()
			update_level_select_text(level_info_list[current_level_selection])
		else:
			pass

func update_credits_subscreen():
	if (is_input_allowed and is_in_subscreen() and credits_subscreen.visible):
		var left_pressed : bool = Input.is_action_just_pressed("Move Left")
		var right_pressed : bool = Input.is_action_just_pressed("Move Right")
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
	level_description_label.text = info.story_description

func return_to_top_menu():
	if (is_input_allowed and is_in_subscreen() and Input.is_action_just_pressed("Attack")):
		menu_cursor.play_cancel_sound()
		level_select_subscreen.set_visible(false)
		credits_subscreen.set_visible(false)
		top_menu_screen.set_visible(true)
		menu_cursor.set_visible(true)
		update_cursor_position()

func start_game():
	if (!is_input_allowed):
		return
	
	is_input_allowed = false
	
	await get_tree().create_timer(1.0).timeout
	
	screen_fade.set_fade(1, 1, Color.BLACK)
	
	await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file(level_info_list[current_level_selection].level_scene_path)
