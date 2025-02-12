extends Node2D

class_name ResultsScreen

@export_group("Sounds")

@export var results_sfx : AudioStreamPlayer

@export var time_tick_sfx_stream : AudioStream

@export var damage_tick_sfx_stream : AudioStream

@export var fragment_tick_sfx_stream : AudioStream

@export var magic_medal_get_sfx_stream : AudioStream

@export var dragon_medal_get_sfx_stream : AudioStream

@export var balance_medal_get_sfx_stream : AudioStream

@export var time_medal_get_sfx_stream : AudioStream

@export var no_medal_get_sfx_stream : AudioStream

@export_group("Effects")

@export var screen_fade : ScreenFade

@export var blue_bg : Sprite2D

@export var orange_bg : Sprite2D

@export var level : Level

@export var clear_timer : ClearTimer

@export var screen_width : float = 512

@export var bg_combine_duration : float = 1

@export var perfect_text : String = "[center][color=#56a842]LEVEL [color=#5941a9]M[color=#f09a59]A[color=#5941a9]S[color=#f09a59]T[color=#5941a9]E[color=#f09a59]R[color=#5941a9]E[color=#f09a59]D[color=white]!"

@export_group("Header")

@export var text_header_label : RichTextLabel

@export_group("Clear Time")

@export var clear_time_label : RichTextLabel

@export var clear_time_format : String = "CLEAR TIME\n{minutes}:{seconds}"

@export var clear_time_format_alt : String = "CLEAR TIME\n{minutes}:{seconds}\n({bonus})"

@export var time_count_duration : float = 1

@export var time_medal_sprite : AnimatedSprite2D

@export_group("Damage Taken")

@export var show_damage_result : bool = true

@export var damage_taken_label : RichTextLabel

@export var damage_text_format : String = "DAMAGE TAKEN\n{damage}"

@export var damage_count_duration : float = 1

@export_group("Fragments")

@export var show_fragment_result : bool = true

@export var fragment_ratio_label : RichTextLabel

@export var mage_fragments_label : RichTextLabel

@export var dragon_fragments_label : RichTextLabel

@export var fragment_slider_back : Sprite2D

@export var mage_fragments_slider : TextureProgressBar

@export var dragon_fragments_slider : TextureProgressBar

@export var fragment_slider_front : Sprite2D

@export var total_fragments_label : RichTextLabel

@export var fragment_format : String = "[center]{number}"

@export var fragment_total_format : String = "[center]{total}/{minimum}"

@export var fragment_count_duration : float = 2

@export var fragment_rating_label : RichTextLabel

@export var rating_format : String = "[center]RATING: {rating}"

@export var rating_chars: int = 7

@export var rating_list : Array[String]

@export_group("Scales")

@export var show_scales_result : bool = true

@export var scales_found_label : RichTextLabel

@export var magical_scale_sprite : AnimatedSprite2D

@export var draconic_scale_sprite : AnimatedSprite2D

@export var balanced_scale_sprite : AnimatedSprite2D

@export_group("Menu")

@export var retry_button_label : RichTextLabel

@export var menu_button_label : RichTextLabel

@export var menu_cursor : MenuCursor

@export var title_scene_path : String

@export_group("Post Level Text")

@export var textbox : Textbox

@export_multiline var post_level_text : Array[String]

var are_menu_options_selectable : bool = false

var current_menu_selection : int = 0

var previous_menu_selection : int = 0

func _ready():
	set_visible(false)

func _physics_process(_delta):
	do_menu()

func do_menu():
	if (are_menu_options_selectable):
		if (Input.is_action_just_pressed("Menu Up") or Input.is_action_just_pressed("Menu Down")):
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
		
		if (Input.is_action_just_pressed("Menu Confirm")):
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
	CheckpointHandler.clear_checkpoint()
	if (!OptionsHelper.enable_quick_restart_toggle or (textbox != null and post_level_text.size() > 0)):
		menu_cursor.do_selection_movement()
		await get_tree().create_timer(1.0).timeout
		screen_fade.set_fade(1, 1, Color.BLACK)
		var timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(on_menu_load_timer)
		if (textbox != null and post_level_text.size() > 0):
			await get_tree().create_timer(2.0).timeout
			textbox.accept_input_events = true
			for text in post_level_text:
				textbox.queue_text(text)
			await textbox.textbox_finished
			#await get_tree().create_timer(0.25).timeout
			timer.start(0.25)
		else:
			timer.timeout.connect(on_menu_load_timer)
			timer.start(2.0)
	else:
		on_menu_load_timer()

func on_menu_load_timer():
	EffectFactory.clear_effects()
	SoundFactory.clear_sounds()
	get_tree().change_scene_to_file(title_scene_path)

func do_retry_level():
	CheckpointHandler.clear_checkpoint()
	if (!OptionsHelper.enable_quick_restart_toggle):
		menu_cursor.do_selection_movement()
		await get_tree().create_timer(1.0).timeout
		screen_fade.set_fade(1, 1, Color.BLACK)
		#await get_tree().create_timer(2.0).timeout
		var timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(on_reload_timer)
		timer.start(2.0)
	else:
		on_reload_timer()

func on_reload_timer():
	EffectFactory.clear_effects()
	SoundFactory.clear_sounds()
	get_tree().reload_current_scene()

func do_results_screen():
	# BACKGROUND TRANSITION
	
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
	
	# LEVEL COMPLETE HEADER APPEARS
	
	text_header_label.set_visible(true)
	await get_tree().create_timer(1.0).timeout
	
	# CLEAR TIMER
	
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
	
	time_medal_sprite.play("TIME" if level.is_target_time_beaten() else "NOTHING")
	results_sfx.stream = (time_medal_get_sfx_stream if level.is_target_time_beaten() else no_medal_get_sfx_stream)
	time_medal_sprite.set_visible(true)
	results_sfx.play()
	await get_tree().create_timer(0.5).timeout
	
	# DAMAGE TAKEN
	
	if (show_damage_result):
		damage_taken_label.set_visible(true)
		var current_damage_value : float = 0
		var target_damage_value : float = level.player_hub.damage.damage_taken
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
	
	# FRAGMENT TOTALS
	
	var saved_rating_index = 0
	if (show_fragment_result):
		fragment_ratio_label.set_visible(true)
		await get_tree().create_timer(0.5).timeout
		
		mage_fragments_label.set_visible(true)
		dragon_fragments_label.set_visible(true)
		total_fragments_label.set_visible(true)
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
			total_fragments_label.text = fragment_total_format.format({"total" : (current_total_value as int), "minimum" : level.min_fragment_req_for_medal})
			
			current_mage_slider_value = move_toward(current_mage_slider_value, target_mage_slider_value, (target_mage_slider_value * delta) / fragment_count_duration)
			mage_fragments_slider.value = current_mage_slider_value
			
			current_dragon_slider_value = move_toward(current_dragon_slider_value, target_dragon_slider_value, (target_dragon_slider_value * delta) / fragment_count_duration)
			dragon_fragments_slider.value = current_dragon_slider_value
			
			current_whole_value = (current_total_value as int)
			if (current_whole_value != previous_whole_value):
				results_sfx.play()
			previous_whole_value = current_whole_value
			
			await get_tree().process_frame
		total_fragments_label.text = fragment_total_format.format({"total" : (current_total_value as int), "minimum" : level.min_fragment_req_for_medal})
		clear_timer.calculate_time_reduction_bonus(level.mage_fragments, level.dragon_fragments, level.get_total_fragments(), level.min_fragment_req_for_medal)
		clear_time_label.text = clear_time_format_alt.format({"minutes" : "%02d" % (floor(clear_timer.get_reduced_time() / 60) as int), "seconds" : "%05.2f" % fmod(clear_timer.get_reduced_time(), 60.0), "bonus" : clear_timer.get_time_reduction_string()})
		await get_tree().create_timer(0.5).timeout
		
		var medal_type : String = level.get_medal_type()
		var rating_index : int = -1
		match medal_type:
			"MAGIC":
				rating_index = 1
				results_sfx.stream = magic_medal_get_sfx_stream
			"DRAGON":
				rating_index = 2
				results_sfx.stream = dragon_medal_get_sfx_stream
			"BALANCE":
				rating_index = (4 if level.mage_fragments == level.dragon_fragments else 3)
				results_sfx.stream = balance_medal_get_sfx_stream
			_:
				rating_index = 0
				results_sfx.stream = no_medal_get_sfx_stream
		
		fragment_rating_label.text = rating_format.format({"rating" : rating_list[rating_index]})
		fragment_rating_label.visible_characters = rating_chars
		fragment_rating_label.set_visible(true)
		await get_tree().create_timer(1.0).timeout
		
		fragment_rating_label.visible_characters = -1
		results_sfx.play()
		saved_rating_index = rating_index
		clear_timer.calculate_time_reduction_bonus(level.mage_fragments, level.dragon_fragments, level.get_total_fragments(), level.min_fragment_req_for_medal, saved_rating_index)
		clear_time_label.text = clear_time_format_alt.format({"minutes" : "%02d" % (floor(clear_timer.get_reduced_time() / 60) as int), "seconds" : "%05.2f" % fmod(clear_timer.get_reduced_time(), 60.0), "bonus" : clear_timer.get_time_reduction_string()})
		await get_tree().create_timer(1.0).timeout
	
	# SCALES
	
	if (show_scales_result):
		scales_found_label.set_visible(true)
		await get_tree().create_timer(0.5).timeout
		
		var scales_found : int = 0
		
		if (level.magical_scale != null):
			magical_scale_sprite.play("MagicScale" if level.magical_scale.is_collected else "MagicScaleBlank")
			results_sfx.stream = (magic_medal_get_sfx_stream if level.magical_scale.is_collected else no_medal_get_sfx_stream)
			scales_found += (1 if level.magical_scale.is_collected else 0)
			magical_scale_sprite.set_visible(true)
			results_sfx.play()
			clear_timer.calculate_time_reduction_bonus(level.mage_fragments, level.dragon_fragments, level.get_total_fragments(), level.min_fragment_req_for_medal, saved_rating_index, scales_found)
			clear_time_label.text = clear_time_format_alt.format({"minutes" : "%02d" % (floor(clear_timer.get_reduced_time() / 60) as int), "seconds" : "%05.2f" % fmod(clear_timer.get_reduced_time(), 60.0), "bonus" : clear_timer.get_time_reduction_string()})
			await get_tree().create_timer(0.5).timeout
		
		if (level.draconic_scale != null):
			draconic_scale_sprite.play("DragonScale" if level.draconic_scale.is_collected else "DragonScaleBlank")
			results_sfx.stream = (dragon_medal_get_sfx_stream if level.draconic_scale.is_collected else no_medal_get_sfx_stream)
			scales_found += (1 if level.draconic_scale.is_collected else 0)
			draconic_scale_sprite.set_visible(true)
			results_sfx.play()
			clear_timer.calculate_time_reduction_bonus(level.mage_fragments, level.dragon_fragments, level.get_total_fragments(), level.min_fragment_req_for_medal, saved_rating_index, scales_found)
			clear_time_label.text = clear_time_format_alt.format({"minutes" : "%02d" % (floor(clear_timer.get_reduced_time() / 60) as int), "seconds" : "%05.2f" % fmod(clear_timer.get_reduced_time(), 60.0), "bonus" : clear_timer.get_time_reduction_string()})
			await get_tree().create_timer(0.5).timeout
		
		if (level.balanced_scale != null):
			balanced_scale_sprite.play("BalanceScale" if level.balanced_scale.is_collected else "BalanceScaleBlank")
			results_sfx.stream = (balance_medal_get_sfx_stream if level.balanced_scale.is_collected else no_medal_get_sfx_stream)
			scales_found += (1 if level.balanced_scale.is_collected else 0)
			balanced_scale_sprite.set_visible(true)
			results_sfx.play()
			clear_timer.calculate_time_reduction_bonus(level.mage_fragments, level.dragon_fragments, level.get_total_fragments(), level.min_fragment_req_for_medal, saved_rating_index, scales_found)
			clear_time_label.text = clear_time_format_alt.format({"minutes" : "%02d" % (floor(clear_timer.get_reduced_time() / 60) as int), "seconds" : "%05.2f" % fmod(clear_timer.get_reduced_time(), 60.0), "bonus" : clear_timer.get_time_reduction_string()})
			await get_tree().create_timer(0.5).timeout
		
		if (!level.is_target_time_beaten() and level.is_target_time_beaten(true)):
			time_medal_sprite.play("TIME")
			results_sfx.stream = (time_medal_get_sfx_stream)
			time_medal_sprite.set_visible(true)
			results_sfx.play()
			await get_tree().create_timer(0.5).timeout
		
		if (level.is_level_perfected()):
			text_header_label.text = perfect_text
			menu_cursor.play_select_sound()
			await get_tree().create_timer(1.0).timeout
		
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
