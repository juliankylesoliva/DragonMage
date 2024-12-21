extends Node2D

@export var player_node : Node

@export var y_fade_offset_from_center : float = 96

@export var alpha_fade_time : float = 0.25

@export_range(0, 1) var target_alpha : float = 0.5

@export var bg_rect : ColorRect

@export var status_text : RichTextLabel

@export var time_text : RichTextLabel

@export var train_list : Array[TrainHazard]

@export var left_text : String = "Drakageau"

@export var right_text : String = "Areltun"

@export var delayed_text : String = "Delayed"

@export var time_display_format : String = "[right]%3.1f sec"

@export var time_display_active : String = "[right]Due"

@export var neutral_weakness_color : Color

@export var magic_weakness_color : Color

@export var fire_weakness_color : Color

@export var delayed_color : Color

var hub : PlayerHub

var current_train : TrainHazard = null

var current_fade_y_threshold : float = 0

func _ready():
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	if (!hub.damage.is_player_defeated and is_a_train_activated()):
		self.set_visible(true)
		var is_train_damaged = (((current_train is TrainBoss) and (current_train as TrainBoss).took_damage()) or current_train.is_slowed_down())
		var is_train_idle = (current_train.current_state == TrainHazard.TrainHazardState.IDLE)
		bg_rect.color = (delayed_color if is_train_damaged else magic_weakness_color if current_train.breakable_by == "MAGIC" else fire_weakness_color if current_train.breakable_by == "FIRE" else neutral_weakness_color)
		status_text.text = (delayed_text if is_train_damaged else right_text if current_train.current_direction > 0 else left_text)
		time_text.text = (time_display_format % current_train.current_idle_timer if is_train_idle else time_display_active if !is_train_damaged else time_display_format % current_train.calculate_remaining_recovery_time() if !(current_train is TrainBoss) else time_display_format % (current_train as TrainBoss).get_damage_duration_display())
	else:
		self.set_visible(false)
	check_alpha_fade(_delta)

func is_a_train_activated():
	for t in train_list:
		if (!t.is_train_disabled):
			current_train = t
			return true
	return false

func check_alpha_fade(delta):
	current_fade_y_threshold = calculate_fade_y_threshold()
	if (hub.char_body.global_position.y > current_fade_y_threshold):
		modulate.a = move_toward(modulate.a, target_alpha, delta / alpha_fade_time)
	else:
		modulate.a = move_toward(modulate.a, 1.0, delta / alpha_fade_time)

func calculate_fade_y_threshold():
	return (get_viewport().get_camera_2d().get_screen_center_position().y + y_fade_offset_from_center)
