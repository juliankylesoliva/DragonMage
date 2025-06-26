extends Node2D

class_name FallingPlatform

const TILE_SIZE : float = 32

@export var room_ref : Room

@export var platform_body : AnimatableBody2D

@export var area_2d : Area2D

@export var platform_collision_shape : CollisionShape2D

@export var area_collision_shape : CollisionShape2D

@export var solo_sprite : Sprite2D

@export var left_sprite : Sprite2D

@export var middle_sprite : Sprite2D

@export var right_sprite : Sprite2D

@export var on_screen_notifier : VisibleOnScreenNotifier2D

@export_range(1, 8) var platform_length : int = 1 

@export var y_pos_stand_threshold : float = 2

@export var max_fall_speed : float = 288

@export var gravity_scale : float = 2

@export var stand_time_limit : float = 1

@export var respawn_time : float = 2

@export_color_no_alpha var unstable_color : Color = Color.WHITE

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_player_detected : bool = false

var player_ref : PlayerHub = null

var current_platform_state : int = 0

var current_stand_time : float = 0

var current_fall_speed : float = 0

var current_respawn_time : float = 0

func _ready():
	if (room_ref != null):
		room_ref.room_activated.connect(reset_position)
	setup()

func _physics_process(delta):
	if (room_ref != null and room_ref.is_room_active):
		match current_platform_state:
			0:
				if (is_player_detected and player_ref != null and player_ref.char_body.is_on_floor() and player_ref.raycast_dm.global_position.y <= (self.global_position.y + y_pos_stand_threshold) and player_ref.raycast_dm.global_position.y >= (self.global_position.y - y_pos_stand_threshold)):
					current_stand_time = move_toward(current_stand_time, stand_time_limit, delta)
					self.modulate = lerp(Color.WHITE, unstable_color, current_stand_time / stand_time_limit)
					if (current_stand_time >= stand_time_limit):
						current_platform_state = 1
				else:
					self.modulate = Color.WHITE
					current_stand_time = 0
			1:
				self.modulate = unstable_color
				current_fall_speed = move_toward(current_fall_speed, max_fall_speed, base_gravity * gravity_scale * delta)
				platform_body.position.y += (current_fall_speed * delta)
				if (current_fall_speed >= max_fall_speed and !on_screen_notifier.is_on_screen()):
					area_2d.set_deferred("monitoring", false)
					platform_collision_shape.set_deferred("disabled", true)
					self.set_visible(false)
					current_platform_state = 2
			2:
				if (current_respawn_time < respawn_time):
					current_respawn_time = move_toward(current_respawn_time, respawn_time, delta)
					if (current_respawn_time >= respawn_time):
						self.set_visible(true)
						self.modulate = Color.WHITE
						platform_body.position.y = 0
						area_2d.set_deferred("monitoring", true)
						platform_collision_shape.set_deferred("disabled", false)
						current_stand_time = 0
						current_fall_speed = 0
						current_respawn_time = 0
						current_platform_state = 0
			_:
				current_platform_state = 0

func setup():
	platform_collision_shape.shape.size.x = (TILE_SIZE * platform_length)
	area_collision_shape.shape.size = platform_collision_shape.shape.size
	
	solo_sprite.set_visible(platform_length == 1)
	
	if (platform_length > 1):
		left_sprite.set_visible(true)
		right_sprite.set_visible(true)
		
		if (platform_length > 2):
			left_sprite.position.x -= ((platform_length - 2) * TILE_SIZE / 2)
			right_sprite.position.x += ((platform_length - 2) * TILE_SIZE / 2)
	else:
		left_sprite.set_visible(false)
		right_sprite.set_visible(false)
	
	if (platform_length > 2):
		middle_sprite.set_visible(true)
		middle_sprite.region_rect.size.x = ((platform_length - 2) * TILE_SIZE)
	else:
		middle_sprite.set_visible(false)

func reset_position():
	self.set_visible(true)
	self.modulate = Color.WHITE
	platform_body.position.y = 0
	area_2d.set_deferred("monitoring", true)
	platform_collision_shape.set_deferred("disabled", false)
	current_stand_time = 0
	current_fall_speed = 0
	current_respawn_time = 0
	current_platform_state = 0

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
