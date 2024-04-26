extends Node2D

class_name TemperMeterUI

@export var player_node : Node

@export var meter_start : Sprite2D

@export var meter_middle : Sprite2D

@export var meter_end : Sprite2D

@export var segment_size : float = 16

@export_color_no_alpha var cold_segment_color : Color = Color.WHITE

@export_color_no_alpha var neutral_segment_color : Color = Color.WHITE

@export_color_no_alpha var hot_segment_color : Color = Color.WHITE

@export var segment_list : Array[AnimatedSprite2D]

@export_range(0, 1) var segment_shake_chance : float = 0.05

@export var segment_shake_amplitude : int = 2

var hub : PlayerHub = null

var prev_temper_level : int = -1

var prev_cold_threshold : int = -1

var prev_hot_threshold : int = -1

var prev_total_segments : int = -1

func _ready():
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	refresh_meter_ui()

func did_player_temper_change():
	return (hub.temper.current_temper_level != prev_temper_level or hub.temper.cold_threshold != prev_cold_threshold or hub.temper.hot_threshold != prev_hot_threshold or hub.temper.total_segments != prev_total_segments)

func refresh_meter_ui():
	if (hub != null and hub.temper != null and did_player_temper_change()):
		var total_segments : int = hub.temper.total_segments
		var cold_threshold : int = hub.temper.cold_threshold
		var hot_threshold : int = hub.temper.hot_threshold
		var current_temper_level : int = hub.temper.current_temper_level
		
		meter_middle.global_scale.x = total_segments
		meter_end.offset.x = (meter_start.offset.x + (segment_size * (total_segments + 1)))
		
		for i in segment_list.size():
			var current_segment : AnimatedSprite2D = segment_list[i]
			if (current_segment != null):
				var segment_level : int = (i + 1)
				
				if (segment_level > total_segments):
					current_segment.visible = false
				else:
					current_segment.visible = true
					current_segment.modulate = (cold_segment_color if segment_level <= cold_threshold else hot_segment_color if segment_level >= hot_threshold else neutral_segment_color)
					current_segment.animation = ("Danger" if hub.temper.is_form_locked() and segment_level <= current_temper_level and ((current_temper_level <= cold_threshold and segment_level <= hub.temper.cold_threshold) or (current_temper_level >= hot_threshold and segment_level >= hot_threshold)) else "On" if segment_level < current_temper_level else "Off" if segment_level > current_temper_level else "Flashing")
					
					if (current_segment.animation == "Danger" and i > 0):
						var previous_segment : AnimatedSprite2D = segment_list[i - 1]
						if (previous_segment.animation == "Danger"):
							current_segment.set_frame_and_progress(previous_segment.frame, previous_segment.frame_progress)
					
					if (current_segment.animation == "Danger" and randf() <= segment_shake_chance):
						current_segment.offset = Vector2((randi() % 2) * segment_shake_amplitude, (randi() % 2) * segment_shake_amplitude)
					else:
						current_segment.offset = Vector2.ZERO
					current_segment.play()
