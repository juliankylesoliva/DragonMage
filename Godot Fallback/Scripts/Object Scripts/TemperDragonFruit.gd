extends Node2D

class_name TemperDragonFruit

@export var collision_shape : CollisionShape2D

@export var anim_sprite : AnimatedSprite2D

@export var stream_player : AudioStreamPlayer2D

@export_enum("Cold:-1", "Warm:0", "Hot:1") var starting_state : int = -1

@export var time_per_state : float = 1

@export var enable_cycling : bool = true

@export var enable_respawning : bool = true

@export var respawn_time : float = 5

@export var floating_amplitude : int = 2

@export var floating_speed_scale : float = 1

@onready var current_state : int = starting_state

@onready var current_state_time_left : float = time_per_state

@onready var cycle_direction : int = (-1 if current_state >= 1 else 1)

var current_respawn_time_left : float = 0

var current_theta : float = 0

func _ready():
	set_initial_sprite()

func _process(delta):
	if (current_respawn_time_left <= 0):
		current_theta += (floating_speed_scale * delta)
		if (current_theta > (PI * 2)):
			current_theta -= (PI * 2)
		anim_sprite.position.y = (floating_amplitude * sin(current_theta))
		
		if (enable_cycling):
			current_state_time_left = move_toward(current_state_time_left, 0, delta)
		
		if (enable_cycling and current_state_time_left <= 0):
			current_state_time_left = time_per_state
			current_state += cycle_direction
			match current_state:
				-1:
					anim_sprite.play("WarmToCold")
					cycle_direction = 1
				0:
					anim_sprite.play("ColdToWarm" if cycle_direction > 0 else "HotToWarm")
				1:
					anim_sprite.play("WarmToHot")
					cycle_direction = -1
				_:
					current_state = -1
					anim_sprite.play("ColdStart")
					cycle_direction = 1
	else:
		collision_shape.disabled = true
		current_respawn_time_left = move_toward(current_respawn_time_left, 0, delta)
		if (current_respawn_time_left <= 0):
			visible = true
			collision_shape.disabled = false
			current_state = starting_state
			current_state_time_left = time_per_state
			cycle_direction = (-1 if current_state >= 1 else 1)
			set_initial_sprite()
			play_sound("object_item_spawn")

func _on_body_entered(body):
	if (current_respawn_time_left <= 0 and body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				var hub : PlayerHub = (child as PlayerHub)
				hub.temper.set_temper_level(hub.temper.get_min_warm_threshold() if current_state <= -1 else hub.temper.get_max_warm_threshold() if current_state >= 1 else hub.temper.get_warm_midpoint())
				SoundFactory.play_sound_by_name("object_item_pickup", global_position, -2)
				if (enable_respawning):
					visible = false
					current_respawn_time_left = respawn_time
				break
		if (!enable_respawning):
			queue_free()

func set_initial_sprite():
	anim_sprite.position.y = 0
	match current_state:
		-1:
			anim_sprite.play("ColdStart")
		0:
			anim_sprite.play("WarmStart")
		1:
			anim_sprite.play("HotStart")
		_:
			current_state = -1
			anim_sprite.play("ColdStart")

func play_sound(sound_name : String, volume : float = 0, pitch : float = 1, bus_name : StringName = "SFX"):
	var stream : AudioStream = SoundFactory.get_sound_by_name(sound_name)
	if (stream != null):
		stream_player.stream = stream
		stream_player.volume_db = volume
		stream_player.pitch_scale = pitch
		stream_player.bus = bus_name
		stream_player.play()
