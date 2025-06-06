extends Node

class_name Level

signal player_defeated

@export var level_index : int = -1

@export var player_reference : CharacterBody2D

@export var starting_room : Room

@export var starting_room_entrance_index : int = 0

@export var room_list : Array[Room]

@export var magical_scale : CollectableScale = null

@export var draconic_scale : CollectableScale = null

@export var balanced_scale : CollectableScale = null

@export_range(0, 1) var min_fragment_collection_rate : float = 0.5

@export_range(1, 9) var min_fragment_majority_ratio : float = 2

@export var fragment_requirement_death_penalty : int = 10

@export var max_fragments_dropped : int = 10

@export var fragment_drop_split : int = 5

@export var dropped_fragment_scene : PackedScene

@export var screen_fade : ScreenFade

@export var intro_screen : LevelIntroScreen

@export var clear_timer : ClearTimer

@export_range(0, 5999.99) var time_to_beat : float = 0

@export var collision_tilemap_name : String = "LevelCollisionTilemap"

@export var hidden_tilemap_name : String = "HiddenTilemap"

@export_color_no_alpha var tilemap_color : Color = Color.WHITE

var player_hub : PlayerHub

var fragment_array : Array[MedalFragment]

var enemy_array : Array[Enemy]

var num_fragments_in_level : int = 0

var min_fragment_req_for_medal : int = 0

var mage_fragments : int = 0

var dragon_fragments : int = 0

var restore_from_checkpoint : bool = false

func _ready():
	PauseHandler.enable_pausing(true)
	level_startup()

func level_startup():
	var restored_room_index : int = CheckpointHandler.saved_room_index
	if (restored_room_index != -1 and restored_room_index >= 0 and restored_room_index < room_list.size()):
		restore_from_checkpoint = true
	
	var room_to_use : Room = (room_list[restored_room_index] if restore_from_checkpoint else starting_room)
	
	var destination_coords : Vector2 = (CheckpointHandler.saved_destination_coords if restore_from_checkpoint else starting_room.get_room_entrance_coordinates(starting_room_entrance_index))
	player_reference.global_position = destination_coords
	
	for child in player_reference.get_children():
		if child is PlayerHub:
			player_hub = (child as PlayerHub)
			break
	
	if (player_hub == null):
		push_warning("PlayerHub not found in level!")
	
	player_hub.set_respawn_position(destination_coords)
	
	player_hub.damage.took_damage.connect(drop_fragments)
	player_hub.damage.defeated.connect(on_player_defeat)
	
	if (player_hub.fairy.fairy_ref != null):
		player_hub.fairy.fairy_ref.snap_to_target_node()
	
	for room in room_list:
		room.set_enemy_player_refs(player_hub)
		
		enemy_array.append_array(room.enemy_list)
		
		room.set_level_ref(self)
		
		if (room != room_to_use):
			room.deactivate_room()
		
		for fragment in room.medal_fragments:
			fragment.set_level_ref(self)
			fragment_array.append(fragment)
		
		for tilemap in room.tilemap_list:
			if (tilemap.name == collision_tilemap_name or tilemap.name.contains(hidden_tilemap_name)):
				tilemap.modulate = tilemap_color
				continue
	
	num_fragments_in_level = fragment_array.size()
	
	min_fragment_req_for_medal = ((num_fragments_in_level * min_fragment_collection_rate) as int)
	min_fragment_req_for_medal += ((fragment_requirement_death_penalty * CheckpointHandler.death_counter) as int)
	if (min_fragment_req_for_medal > num_fragments_in_level):
		min_fragment_req_for_medal = num_fragments_in_level
	
	if (num_fragments_in_level == CheckpointHandler.saved_fragment_status_array.size()):
		mage_fragments = CheckpointHandler.saved_mage_fragments
		dragon_fragments = CheckpointHandler.saved_dragon_fragments
		for i in CheckpointHandler.saved_fragment_status_array.size():
			if (CheckpointHandler.saved_fragment_status_array[i]):
				fragment_array[i].mark_as_collected()
	
	if (magical_scale != null):
		magical_scale.set_level_ref(self)
		if (CheckpointHandler.saved_magical_scale):
			magical_scale.mark_as_collected()
	
	if (draconic_scale != null):
		draconic_scale.set_level_ref(self)
		if (CheckpointHandler.saved_draconic_scale):
			draconic_scale.mark_as_collected()
	
	if (balanced_scale != null):
		balanced_scale.set_level_ref(self)
		if (CheckpointHandler.saved_balanced_scale):
			balanced_scale.mark_as_collected()
	
	if (enemy_array.size() == CheckpointHandler.saved_enemy_status_array.size()):
		for i in CheckpointHandler.saved_enemy_status_array.size():
			if (CheckpointHandler.saved_enemy_status_array[i]):
				enemy_array[i].mark_as_defeated()
	
	if (intro_screen != null):
		PauseHandler.enable_pausing(false)
		player_hub.set_force_stand(true)
		screen_fade.set_enable_fading(false)
		var prev_form_selection : PlayerForm.CharacterMode = FormSelectionHelper.selected_form
		if (!FormSelectionHelper.form_changing_enabled):
			FormSelectionHelper.set_selected_form(player_hub.form.current_mode)
		intro_screen.do_level_intro()
		await intro_screen.intro_finished
		FormSelectionHelper.set_selected_form(prev_form_selection)
		room_to_use.activate_room()
		player_hub.camera.snap_camera_to_player()
		screen_fade.set_enable_fading(true)
		player_hub.set_force_stand(false)
		PauseHandler.enable_pausing(true)
	else:
		room_to_use.activate_room()
		player_hub.camera.snap_camera_to_player()
	
	if (clear_timer != null):
		clear_timer.start_timer()

func respawn_all_enemies():
	for room in room_list:
		room.respawn_enemies()

func level_finish():
	player_hub.set_force_stand(true)
	NextLevelHelper.set_next_level_menu_index(level_index + 1)

func get_current_room():
	for room in room_list:
		if (room.is_room_active):
			return room
	return null

func get_current_room_index():
	for i in room_list.size():
		if (room_list[i].is_room_active):
			return i
	return -1

func get_given_room_index(r : Room):
	for i in room_list.size():
		if (r == room_list[i]):
			return i
	return -1

func increment_fragments(is_mage : bool):
	if (is_mage):
		mage_fragments += 1
	else:
		dragon_fragments += 1

func get_total_fragments():
	return (mage_fragments + dragon_fragments)

func get_total_uncollected_fragments():
	var sum : int = 0
	for fragment in fragment_array:
		if (!fragment.is_collected):
			sum += 1
	return sum

func get_magical_scale_status():
	return (magical_scale != null and magical_scale.is_collected)

func get_draconic_scale_status():
	return (draconic_scale != null and draconic_scale.is_collected)

func get_balanced_scale_status():
	return (balanced_scale != null and balanced_scale.is_collected)

func can_get_medal():
	return (get_total_fragments() >= min_fragment_req_for_medal)

func is_target_time_beaten(use_reduced_time : bool = false):
	return ((clear_timer.get_current_time() if !use_reduced_time else clear_timer.get_reduced_time()) < time_to_beat)

func is_medal_possible():
	return ((get_total_fragments() + get_total_uncollected_fragments()) >= min_fragment_req_for_medal)

func get_medal_type():
	if (can_get_medal()):
		var maximum : float = max(mage_fragments, dragon_fragments)
		var minimum : float = min(mage_fragments, dragon_fragments)
		if (minimum == 0 or (maximum / minimum) >= min_fragment_majority_ratio):
			if (mage_fragments > dragon_fragments):
				return "MAGIC"
			else:
				return "DRAGON"
		else:
			return "BALANCE"
	else:
		return "NOTHING"

func is_level_perfected():
	return ((magical_scale == null or magical_scale.is_collected) and (draconic_scale == null or draconic_scale.is_collected) and (balanced_scale == null or balanced_scale.is_collected) and get_total_fragments() >= min_fragment_req_for_medal and (!player_hub.form.enable_form_changing or mage_fragments == dragon_fragments) and is_target_time_beaten(true))

func get_total_enemies_defeated():
	var sum : int = 0
	for enemy in enemy_array:
		if (enemy.is_defeated):
			sum += 1
	return sum

func drop_fragments():
	var dropped_mage_fragments : int = 0
	var dropped_dragon_fragments : int = 0
	
	var total_fragments : int = get_total_fragments()
	
	if (total_fragments > 0):
		if (total_fragments <= max_fragments_dropped):
			dropped_mage_fragments = mage_fragments
			dropped_dragon_fragments = dragon_fragments
		else:
			if (mage_fragments == 0):
				dropped_dragon_fragments = max_fragments_dropped
			elif (dragon_fragments == 0):
				dropped_mage_fragments = max_fragments_dropped
			else:
				var mage_fragments_to_drop : int = fragment_drop_split
				var dragon_fragments_to_drop : int = fragment_drop_split
				var fragment_diff = (mage_fragments - dragon_fragments)
				
				if (fragment_diff != 0):
					fragment_diff = min(max(fragment_diff, -fragment_drop_split), fragment_drop_split)
					mage_fragments_to_drop += fragment_diff
					dragon_fragments_to_drop -= fragment_diff
					
					if (mage_fragments_to_drop > mage_fragments):
						mage_fragments_to_drop = mage_fragments
						dragon_fragments_to_drop = (max_fragments_dropped - mage_fragments_to_drop)
					elif (dragon_fragments_to_drop > dragon_fragments):
						dragon_fragments_to_drop = dragon_fragments
						mage_fragments_to_drop = (max_fragments_dropped - dragon_fragments_to_drop)
					else:
						pass
				dropped_mage_fragments = mage_fragments_to_drop
				dropped_dragon_fragments = dragon_fragments_to_drop
	mage_fragments -= dropped_mage_fragments
	dragon_fragments -= dropped_dragon_fragments
	spawn_dropped_fragments(dropped_mage_fragments, dropped_dragon_fragments)

func spawn_dropped_fragments(mage : int, dragon : int):
	while (mage > 0 or dragon > 0):
		var temp_node : Node = dropped_fragment_scene.instantiate()
		call_deferred("add_child", temp_node)
		
		var temp_fragment : DroppedFragment = (temp_node as DroppedFragment)
		if (mage == 0):
			temp_fragment.setup_color(false)
			dragon -= 1
		elif (dragon == 0):
			temp_fragment.setup_color(true)
			mage -= 1
		else:
			var is_mage : bool = ((randi() % 2) == 0)
			temp_fragment.setup_color(is_mage)
			if (is_mage):
				mage -= 1
			else:
				dragon -= 1
		
		temp_fragment.global_position = player_hub.char_body.global_position

func on_player_defeat():
	PauseHandler.enable_pausing(false)
	var current_room : Room = get_current_room()
	if (current_room != null):
		current_room.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
	if (clear_timer != null):
		CheckpointHandler.save_clear_time(clear_timer.get_current_time())
	CheckpointHandler.save_damage_taken(player_hub.damage.damage_taken)
	CheckpointHandler.increment_death_counter()
	player_defeated.emit()
