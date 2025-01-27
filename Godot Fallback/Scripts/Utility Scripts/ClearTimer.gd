extends Node2D

class_name ClearTimer

const MAX_TIME : float = 5999.99

@export var timer_label : RichTextLabel

@export var time_format : String = "{minutes}:{seconds}"

@export var base_fragment_ratio_time_bonus = 10

@export var base_fragment_time_bonus : float = 15

@export var rating_time_bonus_table : Array[int] = [0, 1, 3, 5, 10]

@export var scale_time_bonus_table : Array[int] = [2, 5, 8]

var current_time : float = 0

var current_time_reduction_bonus : float = 1

var is_timer_stopped : bool = false

func _ready():
	self.visible = OptionsHelper.enable_clear_timer_toggle
	if (CheckpointHandler.saved_clear_time >= 0):
		current_time = CheckpointHandler.saved_clear_time

func _physics_process(delta):
	if (!is_timer_stopped):
		self.visible = OptionsHelper.enable_clear_timer_toggle
		current_time = move_toward(current_time, MAX_TIME, delta)
		timer_label.text = time_format.format({"minutes" : "%02d" % (floor(current_time / 60) as int), "seconds" : "%04.1f" % fmod(current_time, 60.0)})

func start_timer():
	is_timer_stopped = false

func stop_timer():
	is_timer_stopped = true

func get_current_time():
	return current_time

func calculate_time_reduction_bonus(mage_fragments : int = 0, dragon_fragments : int = 0, collected_fragments : int = 0, minimum_fragments : int = 0, rating_index : int = 0, scales_collected : int = 0):
	var md_ratio : float = (minf(mage_fragments, dragon_fragments) / maxf(mage_fragments, dragon_fragments) if mage_fragments > 0 or dragon_fragments > 0 else 0.0)
	var collection_ratio : float = (collected_fragments as float / minimum_fragments as float if minimum_fragments > 0 else 0.0)
	var fragment_bonus : float = ((base_fragment_ratio_time_bonus * md_ratio) + (base_fragment_time_bonus * collection_ratio))
	
	var rating_bonus : float = (rating_time_bonus_table[rating_index] as float if rating_index >= 0 or rating_index < rating_time_bonus_table.size() else 0.0)
	
	var scale_bonus_sum : int = 0
	for i in min(scale_time_bonus_table.size(), abs(scales_collected)):
		scale_bonus_sum += scale_time_bonus_table[i]
	
	var scale_bonus_sumf : float = (scale_bonus_sum as float)
	
	current_time_reduction_bonus = (1.0 - ((fragment_bonus + rating_bonus + scale_bonus_sumf) / 100.0))

func reset_time_reduction_bonus():
	current_time_reduction_bonus = 1.0

func get_reduced_time():
	return (current_time * current_time_reduction_bonus)

func get_time_reduction_string():
	return "-{result}%".format({"result" : "%3.1f" % (100.0 * (1.0 - current_time_reduction_bonus))})
