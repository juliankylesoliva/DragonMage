extends Node2D

class_name FloorSpikes

@export var floor_spikes_segment_scene : PackedScene

@export var collision_shape : CollisionShape2D

@export var audio_stream_player : AudioStreamPlayer2D

@export_range(1, 16) var floor_length : int = 1

@export var tile_size : float = 32

@export var time_between_states : float = 1

@export var stun_duration_on_parry : float = 3

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
	if (spike_state == 2 and player_ref != null and is_player_detected and player_ref.char_body.is_on_floor() and player_ref.damage.can_take_damage()):
		if (player_ref.damage.take_damage()):
			EffectFactory.get_effect("EnemyContactImpact", player_ref.char_body.global_position)
			SoundFactory.play_sound_by_name("enemy_contact_impact", player_ref.char_body.global_position, 0, 1, "SFX")
		elif (player_ref.damage.is_player_parrying()):
			for spike in spike_segment_list:
					spike.play("Retract")
			spike_state = 0
			spike_state_timer = stun_duration_on_parry
			play_sound("obstacle_spikes_retract")
		else:
			pass
	
	spike_state_timer = move_toward(spike_state_timer, 0, delta)
	if (spike_state_timer <= 0):
		match spike_state:
			0:
				if (is_player_detected and player_ref != null and player_ref.char_body.is_on_floor()):
					for spike in spike_segment_list:
						spike.play("Warning")
					spike_state = 1
					spike_state_timer = time_between_states
					play_sound("obstacle_spikes_warning")
			1:
				for spike in spike_segment_list:
					spike.play("Active")
				spike_state = 2
				spike_state_timer = time_between_states
				play_sound("obstacle_spikes_active")
			2:
				for spike in spike_segment_list:
					spike.play("Retract")
				spike_state = 0
				spike_state_timer = time_between_states
				play_sound("obstacle_spikes_retract")
			_:
				pass

func play_sound(sound_name : String, volume : float = 0, pitch : float = 1, bus_name : StringName = "SFX"):
	var stream : AudioStream = SoundFactory.get_sound_by_name(sound_name)
	if (stream != null):
		audio_stream_player.stream = stream
		audio_stream_player.volume_db = volume
		audio_stream_player.pitch_scale = pitch
		audio_stream_player.bus = bus_name
		audio_stream_player.play()

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
