extends Node2D

class_name WaterHazard

const PIXELS_PER_TILE : float = 32

const HITBOX_HEIGHT_OFFSET : float = 16

@export var room_ref : Room

@export var collision_shape : CollisionShape2D

@export var sprites_parent : Node2D

@export var sprite_back : Sprite2D

@export var sprite_front : Sprite2D

@export var sprite_fill : Sprite2D

@export var particles : CPUParticles2D

@export var tile_width : int = 2

@export var water_tile_height_offsets : Array[float] = [1]

@export var initial_height_index : int = 0

@export_enum("NONE:0", "LOOP:1", "PING-PONG:2") var cycle_type : int = 0

@export_enum("FORWARD:1", "BACKWARD:-1") var cycle_direction : int = 1

@export var cycle_interval : float = 3

@export var height_change_time : float = 5

var is_player_detected : bool = false

var player_ref : PlayerHub = null

var current_timer : float = 0

var is_changing_height : bool = false

var current_height_index : int = 0

var previous_height_index : int = 0

func _ready():
	initialize()
	if (room_ref != null):
		room_ref.room_activated.connect(initialize)

func _process(_delta: float):
	if (player_ref != null and is_player_detected):
		if (player_ref.damage.do_damage_warp() and player_ref.damage.is_player_damaged()):
			EffectFactory.get_effect("EnemyContactImpact", player_ref.char_body.global_position)
			SoundFactory.play_sound_by_name("enemy_contact_impact", player_ref.char_body.global_position, 0, 1, "SFX")

func _physics_process(delta: float):
	if (cycle_type > 0 and room_ref != null and room_ref.is_room_active):
		if (is_changing_height):
			collision_shape.shape.size.y = move_toward(collision_shape.shape.size.y, get_target_height(current_height_index), get_height_change_rate(current_height_index, previous_height_index) * delta)
			update_y_offset()
			update_sprites()
			if (current_timer == 0):
				is_changing_height = !is_changing_height
				current_timer = cycle_interval
		else:
			if (current_timer == 0):
				previous_height_index = current_height_index
				current_height_index += cycle_direction
				if (current_height_index < 0 or current_height_index >= water_tile_height_offsets.size()):
					match cycle_type:
						1:
							if (current_height_index < 0):
								current_height_index = (water_tile_height_offsets.size() - 1)
							else:
								current_height_index = 0
						2:
							cycle_direction *= -1
							current_height_index += (cycle_direction * 2)
						_:
							current_height_index = clampi(initial_height_index, 0, water_tile_height_offsets.size() - 1)
				is_changing_height = !is_changing_height
				current_timer = height_change_time
		current_timer = move_toward(current_timer, 0, delta)

func initialize():
	current_height_index = clampi(initial_height_index, 0, water_tile_height_offsets.size() - 1)
	collision_shape.shape.size.x = (tile_width * PIXELS_PER_TILE)
	collision_shape.shape.size.y = get_target_height(current_height_index)
	update_y_offset()
	update_sprites()
	particles.amount = tile_width
	particles.emitting = true
	is_changing_height = false
	if (cycle_type > 0):
		current_timer = cycle_interval

func get_target_height(index):
	return ((water_tile_height_offsets[index] * PIXELS_PER_TILE) - HITBOX_HEIGHT_OFFSET) 

func update_y_offset():
	collision_shape.position.y = -(collision_shape.shape.size.y / 2)

func update_sprites():
	sprites_parent.global_position = (self.global_position + (2 * collision_shape.position))
	sprite_fill.scale.x = tile_width
	sprite_fill.scale.y = collision_shape.shape.size.y
	sprite_back.region_rect.size.x = collision_shape.shape.size.x
	sprite_front.region_rect.size.x = collision_shape.shape.size.x
	particles.emission_rect_extents.x = (collision_shape.shape.size.x / 2)

func get_height_change_rate(target : int, previous : int):
	return abs((get_target_height(target) - get_target_height(previous)) / height_change_time)

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_detected = true
		for child in body.get_children():
			if (child is PlayerHub):
				player_ref = (child as PlayerHub)
				break
	elif (body is MagicBlastProjectile):
		body.queue_free()
	else:
		pass

func _on_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_player_detected = false
		player_ref = null
