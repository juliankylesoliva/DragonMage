extends CameraFollow

class_name TemperMeterUI

@export var player_node : Node

@export var meter_start : Sprite2D

@export var meter_middle : Sprite2D

@export var meter_end : Sprite2D

@export var segment_size : float = 16

@export_range(0, 1) var player_collision_alpha : float = 0.25

@export var player_collision_alpha_delta_multiplier : float = 5

@export_color_no_alpha var cold_segment_color : Color = Color.WHITE

@export_color_no_alpha var neutral_segment_color : Color = Color.WHITE

@export_color_no_alpha var hot_segment_color : Color = Color.WHITE

@export var segment_list : Array[AnimatedSprite2D]

var hub : PlayerHub = null

var prev_temper_level : int = -1

var prev_cold_threshold : int = -1

var prev_hot_threshold : int = -1

var prev_total_segments : int = -1

var is_player_colliding : bool = false

func _ready():
	super._ready()
	if (player_node != null):
		for child in player_node.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break

func _process(_delta):
	super._process(_delta)
	uniform_process(_delta)

func _physics_process(_delta):
	super._physics_process(_delta)
	uniform_process(_delta)

func uniform_process(_delta):
	refresh_meter_ui()
	update_modulate_alpha(_delta)

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
					current_segment.animation = ("On" if segment_level < current_temper_level else "Off" if segment_level > current_temper_level else "Flashing")
					current_segment.play()

func update_modulate_alpha(delta : float):
	modulate.a = move_toward(modulate.a, player_collision_alpha if is_player_colliding or hub.char_body.global_position.y < global_position.y else 1.0, delta * player_collision_alpha_delta_multiplier)

func _on_rigid_body_2d_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_colliding = true

func _on_rigid_body_2d_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_colliding = false
