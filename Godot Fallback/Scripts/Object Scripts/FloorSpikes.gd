extends Node2D

class_name FloorSpikes

@export var floor_spikes_segment_scene : PackedScene

@export var collision_shape : CollisionShape2D

@export_range(1, 8) var floor_length : int = 1

@export var tile_size : float = 32

@export var time_between_states : float = 1

var spike_segment_list : Array[AnimatedSprite2D]

var is_player_detected : bool = false

var player_ref : PlayerHub = null

var spike_state : int = 0

var spike_state_timer : float = 0

func _ready():
	var left_start_point : float = ((tile_size / -2.0) * (floor_length - 1))
	for i in floor_length:
		var instance : Node = floor_spikes_segment_scene.instantiate()
		add_child(instance)
		(instance as Node2D).global_position = Vector2(global_position.x + left_start_point + (tile_size * i), global_position.y)
		spike_segment_list.append(instance as AnimatedSprite2D)
	collision_shape.shape.size.x = (tile_size * floor_length)

func _process(delta):
	spike_state_timer = move_toward(spike_state_timer, 0, delta)
	if (spike_state_timer <= 0):
		match spike_state:
			0:
				if (is_player_detected and player_ref != null and player_ref.char_body.is_on_floor()):
					for spike in spike_segment_list:
						spike.play("Warning")
					spike_state = 1
					spike_state_timer = time_between_states
			1:
				for spike in spike_segment_list:
					spike.play("Active")
				spike_state = 2
				spike_state_timer = time_between_states
			2:
				for spike in spike_segment_list:
					spike.play("Retract")
				spike_state = 0
				spike_state_timer = time_between_states
			_:
				pass

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_detected = true
		for child in body.get_children():
			if (child is PlayerHub):
				player_ref = (child as PlayerHub)
				break

func _on_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_detected = false
		player_ref = null
