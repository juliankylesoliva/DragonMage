extends Node2D

class_name ResultsScreen

@export var results_sfx : AudioStreamPlayer2D

@export var time_tick_sfx_stream : AudioStream

@export var damage_tick_sfx_stream : AudioStream

@export var fragment_tick_sfx_stream : AudioStream

@export var magic_medal_get_sfx_stream : AudioStream

@export var dragon_medal_get_sfx_stream : AudioStream

@export var balance_medal_get_sfx_stream : AudioStream

@export var no_medal_get_sfx_stream : AudioStream

@export var screen_fade : ScreenFade

@export var blue_bg : Sprite2D

@export var orange_bg : Sprite2D

@export var level : Level

@export var clear_timer : ClearTimer

@export var screen_width : float = 512

@export var bg_combine_duration : float = 1

@export var text_header_label : RichTextLabel

@export var clear_time_label : RichTextLabel

@export var clear_time_format : String = "CLEAR TIME\n{minutes}:{seconds}"

@export var time_count_duration : float = 1

@export var damage_taken_label : RichTextLabel

@export var damage_text_format : String = "DAMAGE TAKEN\n{damage}"

@export var damage_count_duration : float = 1

@export var show_fragment_result : bool = true

@export var fragment_ratio_label : RichTextLabel

@export var mage_fragments_label : RichTextLabel

@export var dragon_fragments_label : RichTextLabel

@export var fragment_slider_back : Sprite2D

@export var mage_fragments_slider : TextureProgressBar

@export var dragon_fragments_slider : TextureProgressBar

@export var fragment_slider_front : Sprite2D

@export var min_fragments_label : RichTextLabel

@export var fragment_format : String = "[center]{number}"

@export var fragment_total_format : String = "[center]{total}/{minimum}"

@export var fragment_count_duration : float = 2

@export var medal_message_label : RichTextLabel

@export var medal_sprite : AnimatedSprite2D

@export var medal_format : String = "GOT A {medal} MEDALLION!"

@export var no_medal_message : String = "NO MEDAL EARNED..."

@export_color_no_alpha var mage_message_color : Color

@export_color_no_alpha var dragon_message_color : Color

@export_color_no_alpha var balance_message_color : Color

@export var retry_button_label : RichTextLabel

@export var menu_button_label : RichTextLabel

@export var menu_cursor : MenuCursor

@export var title_scene_path : String

var are_menu_options_selectable : bool = false

var current_menu_selection : int = 0

var previous_menu_selection : int = 0

func _ready():
	set_visible(false)

func _physics_process(_delta):
	follow_camera()
	do_menu()

func follow_camera():
	global_position = get_viewport().get_camera_2d().global_position

func do_menu():
	if (are_menu_options_selectable):
		if (Input.is_action_just_pressed("Move Up") or Input.is_action_just_pressed("Move Down")):
			current_menu_selection = (1 if current_menu_selection == 0 else 0)
		
		if (current_menu_selection != previous_menu_selection):
			menu_cursor.play_move_sound()
			match current_menu_selection:
				0:
					menu_cursor.global_position = (menu_button_label.global_position + menu_button_label.pivot_offset)
				1:
					menu_cursor.global_position = (retry_button_label.global_position + retry_button_label.pivot_offset)
				_:
					current_menu_selection = 0
					menu_cursor.global_position = (menu_button_label.global_position + menu_button_label.pivot_offset)
		
		if (Input.is_action_just_pressed("Jump")):
			are_menu_options_selectable = false
			match current_menu_selection:
				0:
					do_main_menu()
				1:
					do_retry_level()
				_:
					pass
		
		previous_menu_selection = current_menu_selection

func do_main_menu():
	menu_cursor.do_selection_movement()
	await get_tree().create_timer(1.0).timeout
	screen_fade.set_fade(1, 1, Color.BLACK)
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file(title_scene_path)

func do_retry_level():
	menu_cursor.do_selection_movement()
	await get_tree().create_timer(1.0).timeout
	screen_fade.set_fade(1, 1, Color.BLACK)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func do_results_screen():
	await get_tree().create_timer(1.0).timeout
	
	blue_bg.set_visible(true)
	orange_bg.set_visible(true)
	var bg_combine_lerp : float = 0
	while(bg_combine_lerp < 1):
		bg_combine_lerp = move_toward(bg_combine_lerp, 1, get_physics_process_delta_time() / bg_combine_duration)
		blue_bg.position.x = lerp(-screen_width, 0.0, bg_combine_lerp)
		orange_bg.position.x = lerp(screen_width, 0.0, bg_combine_lerp)
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	
	text_header_label.set_visible(true)
	await get_tree().create_timer(1.0).timeout
	
	var previous_whole_value : int = 0
	var current_whole_value : int = 0
	
	clear_time_label.set_visible(true)
	var current_time_value : float = 0
	var target_time_value : float = clear_timer.get_current_time()
	results_sfx.stream = time_tick_sfx_stream
	while (current_time_value < target_time_value):
		current_time_value = move_toward(current_time_value, target_time_value, (target_time_value * get_physics_process_delta_time()) / time_count_duration)
		clear_time_label.text = clear_time_format.format({"minutes" : "%02d" % (floor(current_time_value / 60) as int), "seconds" : "%05.2f" % fmod(current_time_value, 60.0)})
		
		current_whole_value = (current_time_value as int)
		if (current_whole_value != previous_whole_value):
			results_sfx.play()
		previous_whole_value = current_whole_value
		
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	
	damage_taken_label.set_visible(true)
	var current_damage_value : float = 0
	var target_damage_value : float = level.player_ref.damage.damage_taken
	previous_whole_value = 0
	results_sfx.stream = damage_tick_sfx_stream
	while (current_damage_value < target_damage_value):
		current_damage_value = move_toward(current_damage_value, target_damage_value, (target_damage_value * get_physics_process_delta_time()) / damage_count_duration)
		damage_taken_label.text = damage_text_format.format({"damage" : (current_damage_value as int)})
		
		current_whole_value = (current_damage_value as int)
		if (current_whole_value != previous_whole_value):
			results_sfx.play()
		previous_whole_value = current_whole_value
		
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	
	if (show_fragment_result):
		fragment_ratio_label.set_visible(true)
		await get_tree().create_timer(0.5).timeout
		
		mage_fragments_label.set_visible(true)
		dragon_fragments_label.set_visible(true)
		min_fragments_label.set_visible(true)
		fragment_slider_back.set_visible(true)
		mage_fragments_slider.set_visible(true)
		dragon_fragments_slider.set_visible(true)
		fragment_slider_front.set_visible(true)
		
		var current_mage_value : float = 0
		var target_mage_value : float = level.mage_fragments
		
		var current_dragon_value : float = 0
		var target_dragon_value : float = level.dragon_fragments
		
		var current_total_value : float = 0
		var target_total_value : float = level.get_total_fragments()
		
		var slider_denominator : float = (level.min_fragment_req_for_medal if level.get_total_fragments() <= level.min_fragment_req_for_medal else level.get_total_fragments())
		var current_mage_slider_value : float = 0
		var target_mage_slider_value : float = (level.mage_fragments / slider_denominator)
		var current_dragon_slider_value : float = 0
		var target_dragon_slider_value : float = (level.dragon_fragments / slider_denominator)
		
		previous_whole_value = 0
		results_sfx.stream = fragment_tick_sfx_stream
		while(current_mage_value < target_mage_value or current_dragon_value < target_dragon_value or current_total_value < target_total_value):
			var delta : float = get_physics_process_delta_time()
			
			current_mage_value = move_toward(current_mage_value, target_mage_value, (target_mage_value * delta) / fragment_count_duration)
			mage_fragments_label.text = fragment_format.format({"number" : (current_mage_value as int)})
			
			current_dragon_value = move_toward(current_dragon_value, target_dragon_value, (target_dragon_value * delta) / fragment_count_duration)
			dragon_fragments_label.text = fragment_format.format({"number" : (current_dragon_value as int)})
			
			current_total_value = move_toward(current_total_value, target_total_value, (target_total_value * delta) / fragment_count_duration)
			min_fragments_label.text = fragment_total_format.format({"total" : (current_total_value as int), "minimum" : level.min_fragment_req_for_medal})
			
			current_mage_slider_value = move_toward(current_mage_slider_value, target_mage_slider_value, (target_mage_slider_value * delta) / fragment_count_duration)
			mage_fragments_slider.value = current_mage_slider_value
			
			current_dragon_slider_value = move_toward(current_dragon_slider_value, target_dragon_slider_value, (target_dragon_slider_value * delta) / fragment_count_duration)
			dragon_fragments_slider.value = current_dragon_slider_value
			
			current_whole_value = (current_total_value as int)
			if (current_whole_value != previous_whole_value):
				results_sfx.play()
			previous_whole_value = current_whole_value
			
			await get_tree().process_frame
		await get_tree().create_timer(1.0).timeout
		
		medal_message_label.set_visible(true)
		medal_sprite.set_visible(true)
		var medal_type : String = level.get_medal_type()
		medal_message_label.text = (medal_format.format({"medal" : medal_type}) if level.can_get_medal() else no_medal_message)
		match medal_type:
			"MAGIC":
				results_sfx.stream = magic_medal_get_sfx_stream
				medal_message_label.modulate = mage_message_color
			"DRAGON":
				results_sfx.stream = dragon_medal_get_sfx_stream
				medal_message_label.modulate = dragon_message_color
			"BALANCE":
				results_sfx.stream = balance_medal_get_sfx_stream
				medal_message_label.modulate = balance_message_color
			_:
				results_sfx.stream = no_medal_get_sfx_stream
				medal_message_label.modulate = Color.WHITE
		results_sfx.play()
		medal_sprite.animation = medal_type
		await get_tree().create_timer(1.0).timeout
	
	menu_button_label.set_visible(true)
	retry_button_label.set_visible(true)
	menu_cursor.set_visible(true)
	menu_cursor.global_position = (menu_button_label.global_position + menu_button_label.pivot_offset)
	are_menu_options_selectable = true

func on_level_complete():
	set_visible(true)
	set_process_mode(PROCESS_MODE_ALWAYS)
	do_results_screen()
