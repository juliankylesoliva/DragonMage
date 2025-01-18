extends MenuTemplate

class_name PauseMenu

@export var pause_top_node : Node2D

@export var selection_labels : Array[RichTextLabel]

@export var form_select_prompt_label : ButtonPromptTextLabel

@export_multiline var default_prompt_text : String

@export_multiline var form_restart_text : String

@export var magli_name_sprite_path : String = "res://Sprites/UI/MagliNameSprite.png"

@export var draelyn_name_sprite_path : String = "res://Sprites/UI/DraelynNameSprite.png"

@export var options_subscreen : MenuTemplate

@export var tips_menu : MenuTemplate

@export var screen_fade : ScreenFade

@export var title_scene_path : String

@export var enable_hiding : bool = false

var is_hiding : bool = false

func _ready():
	PauseHandler.set_unpause_lock(false)
	max_selections = selection_labels.size()
	PauseHandler.game_paused.connect(on_pause)
	PauseHandler.game_unpaused.connect(on_unpause)

func _process(_delta):
	super._process(_delta)
	if (enable_input and !was_menu_just_activated and Input.is_action_just_pressed("Hide Pause Menu")):
		on_hide_pause_menu()

func _physics_process(_delta):
	if (get_tree().is_paused()):
		# check_menu_selection()
		pass

func on_pause():
	reset_selection()
	self.activate_menu()

func on_unpause():
	self.deactivate_menu()

func on_hide_pause_menu():
	toggle_hiding()

func toggle_hiding():
	if (enable_hiding and get_tree().is_paused()):
		is_hiding = !is_hiding
		self.set_visible(!is_hiding)

func on_menu_activation():
	PauseHandler.set_unpause_lock(false)
	pause_top_node.set_visible(true)
	update_prompt_text()
	move_cursor()

func on_menu_deactivation():
	is_hiding = false
	reset_selection()
	move_cursor()

func on_up_pressed():
	decrement_selection()

func on_down_pressed():
	increment_selection()

func on_selection_reset():
	move_cursor()

func on_selection_change():
	move_cursor()
	menu_cursor.play_move_sound()

func on_selection_confirm():
	match current_selection:
		0:
			do_pause_button()
		1:
			PauseHandler.set_unpause_lock(true)
			options_subscreen.reset_selection()
			menu_cursor.play_accept_sound()
			enable_input = false
			pause_top_node.set_visible(false)
			options_subscreen.set_previous_menu(self)
			options_subscreen.activate_menu()
		2:
			PauseHandler.set_unpause_lock(true)
			tips_menu.reset_selection()
			menu_cursor.play_accept_sound()
			enable_input = false
			pause_top_node.set_visible(false)
			tips_menu.set_previous_menu(self)
			tips_menu.activate_menu()
		3:
			do_restart()
		4:
			do_title_screen()
		_:
			pass

func on_menu_cancel():
	do_pause_button()

func on_change_form():
	if (FormSelectionHelper.form_changing_enabled):
		if (FormSelectionHelper.selected_form == FormSelectionHelper.mage_form):
			menu_cursor.play_cancel_sound()
		else:
			menu_cursor.play_accept_sound()
		FormSelectionHelper.toggle_selected_form()
		update_prompt_text()

func move_cursor():
	var selected_label : RichTextLabel = selection_labels[current_selection]
	menu_cursor.global_position = (selected_label.global_position + selected_label.pivot_offset)
	menu_cursor.set_spacing(get_label_width(selection_labels[current_selection]))

func get_label_center(label : RichTextLabel):
	return (label.global_position + label.pivot_offset)

func get_label_width(label : RichTextLabel):
	return label.size.x

func update_prompt_text():
	form_select_prompt_label.raw_text = (form_restart_text.format({"file" : magli_name_sprite_path if FormSelectionHelper.is_mage_selected() else draelyn_name_sprite_path}) if FormSelectionHelper.form_changing_enabled else default_prompt_text)
	form_select_prompt_label.refresh_label_text()

func do_restart():
	PauseHandler.set_unpause_lock(true)
	CheckpointHandler.clear_checkpoint()
	enable_input = false
	if (!OptionsHelper.enable_quick_restart_toggle):
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
	enable_input = false
	if (!OptionsHelper.enable_quick_restart_toggle):
		menu_cursor.do_selection_movement()
		await get_tree().create_timer(1.0).timeout
		screen_fade.set_fade(1, 1, Color.BLACK)
		await get_tree().create_timer(2.0).timeout
	EffectFactory.clear_effects()
	SoundFactory.clear_sounds()
	get_tree().change_scene_to_file(title_scene_path)

func do_pause_button():
	var unpause_event : InputEventAction = InputEventAction.new()
	unpause_event.action = "Pause"
	unpause_event.pressed = true
	Input.parse_input_event(unpause_event)
