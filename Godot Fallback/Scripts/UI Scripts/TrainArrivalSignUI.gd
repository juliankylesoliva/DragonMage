extends Node2D

@export var bg_rect : ColorRect

@export var status_text : RichTextLabel

@export var time_text : RichTextLabel

@export var train_list : Array[TrainHazard]

@export var left_text : String = "Drakageau"

@export var right_text : String = "Areltun"

@export var delayed_text : String = "Delayed"

@export var time_display_format : String = "[right]%3.1f"

@export var time_display_active : String = "[right]Due"

@export var neutral_weakness_color : Color

@export var magic_weakness_color : Color

@export var fire_weakness_color : Color

var current_train : TrainHazard = null

func _process(_delta):
	if (is_a_train_activated()):
		self.set_visible(true)
		var is_train_damaged = (((current_train is TrainBoss) and (current_train as TrainBoss).took_damage()) or current_train.is_slowed_down())
		var is_train_idle = (current_train.current_state == TrainHazard.TrainHazardState.IDLE)
		bg_rect.color = (magic_weakness_color if current_train.breakable_by == "MAGIC" else fire_weakness_color if current_train.breakable_by == "FIRE" else neutral_weakness_color)
		status_text.text = (delayed_text if is_train_damaged else right_text if current_train.current_direction > 0 else left_text)
		time_text.text = (time_display_format % current_train.current_idle_timer if is_train_idle else time_display_active if !is_train_damaged else time_display_format % current_train.calculate_remaining_recovery_time() if !(current_train is TrainBoss) else time_display_format % (current_train as TrainBoss).get_damage_duration_display())
	else:
		self.set_visible(false)

func is_a_train_activated():
	for t in train_list:
		if (!t.is_train_disabled):
			current_train = t
			return true
	return false
