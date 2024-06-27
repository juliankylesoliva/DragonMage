extends Node2D

class_name PauseMenu

@export var menu_cursor : MenuCursor

@export var selection_labels : Array[RichTextLabel]

@export var form_select_prompt_label : ButtonPromptTextLabel

@export_multiline var form_restart_text : String

@export var magli_name_sprite_path : String = "res://Sprites/UI/MagliNameSprite.png"

@export var draelyn_name_sprite_path : String = "res://Sprites/UI/DraelynNameSprite.png"

@export var screen_fade : ScreenFade

@export var title_scene_path : String

@export var enable_hiding : bool = false

var current_selection : int = 0

var is_input_allowed : bool = true

var is_hiding : bool = false

func _ready():
	PauseHandler.set_unpause_lock(false)

func _physics_process(_delta):
	if (get_tree().is_paused()):
		toggle_hiding()
		self.set_visible(true and !is_hiding)
		check_menu_cursor_movement()
		check_menu_selection()
	else:
		self.set_visible(false)
		is_hiding = false
		current_selection = 0
		move_cursor()

func toggle_hiding():
	if (enable_hiding and get_tree().is_paused() and Input.is_action_just_pressed("Hide Pause Menu")):
		is_hiding = !is_hiding

func move_cursor():
	var selected_label : RichTextLabel = selection_labels[current_selection]
	menu_cursor.global_position = (selected_label.global_position + selected_label.pivot_offset)

func check_menu_cursor_movement():
	if (!is_input_allowed):
		return
	
	var up_pressed : bool = Input.is_action_just_pressed("Menu Up")
	var down_pressed : bool = Input.is_action_just_pressed("Menu Down")
	
	if ((up_pressed or down_pressed) and !(up_pressed and down_pressed)):
		if (up_pressed):
			current_selection -= 1
			if (current_selection < 0):
				current_selection = (selection_labels.size() - 1)
		else:
			current_selection += 1
			if (current_selection >= selection_labels.size()):
				current_selection = 0
		
		move_cursor()
		menu_cursor.play_move_sound()
	
	if (FormSelectionHelper.form_changing_enabled):
		form_select_prompt_label.set_visible(current_selection == 0)
		form_select_prompt_label.raw_text = (form_restart_text.format({"file" : magli_name_sprite_path if FormSelectionHelper.is_mage_selected() else draelyn_name_sprite_path}))
		form_select_prompt_label.refresh_label_text()

func check_menu_selection():
	if (is_input_allowed and Input.is_action_just_pressed("Menu Confirm")):
		match current_selection:
			0:
				do_restart()
			1:
				do_title_screen()
			2:
				get_tree().quit()
			_:
				pass
	elif (FormSelectionHelper.form_changing_enabled and current_selection == 0 and Input.is_action_just_pressed("Change Form")):
		if (FormSelectionHelper.selected_form == FormSelectionHelper.mage_form):
			menu_cursor.play_cancel_sound()
		else:
			menu_cursor.play_accept_sound()
		FormSelectionHelper.toggle_selected_form()
	else:
		pass

func do_restart():
	PauseHandler.set_unpause_lock(true)
	CheckpointHandler.clear_checkpoint()
	is_input_allowed = false
	menu_cursor.do_selection_movement()
	await get_tree().create_timer(1.0).timeout
	screen_fade.set_fade(1, 1, Color.BLACK)
	await get_tree().create_timer(2.0).timeout
	EffectFactory.clear_effects()
	SoundFactory.clear_sounds()
	get_tree().reload_current_scene()

func do_title_screen():
	PauseHandler.set_unpause_lock(true)
	CheckpointHandler.clear_checkpoint()
	is_input_allowed = false
	menu_cursor.do_selection_movement()
	await get_tree().create_timer(1.0).timeout
	screen_fade.set_fade(1, 1, Color.BLACK)
	await get_tree().create_timer(2.0).timeout
	EffectFactory.clear_effects()
	SoundFactory.clear_sounds()
	get_tree().change_scene_to_file(title_scene_path)
