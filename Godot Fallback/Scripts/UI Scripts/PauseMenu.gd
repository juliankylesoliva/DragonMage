extends Node2D

class_name PauseMenu

@export var menu_cursor : MenuCursor

@export var selection_labels : Array[RichTextLabel]

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
	
	var up_pressed : bool = Input.is_action_just_pressed("Move Up")
	var down_pressed : bool = Input.is_action_just_pressed("Move Down")
	
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

func check_menu_selection():
	if (is_input_allowed and Input.is_action_just_pressed("Jump")):
		match current_selection:
			0:
				do_restart()
			1:
				do_title_screen()
			2:
				get_tree().quit()
			_:
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
	get_tree().change_scene_to_file(title_scene_path)
