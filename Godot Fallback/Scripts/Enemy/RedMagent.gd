extends Enemy

@export var red_magent_projectile_scene : PackedScene

@export var projectile_spawn_point : Node2D

@export var firing_rate : float = 1.0

@export var teleport_location_offsets : Array[Vector2] = [Vector2.ZERO]

@export var max_distance_from_player : float = 256

@export var reflector_sprite : AnimatedSprite2D

@export var magic_particles : CPUParticles2D

@export var enable_wings : bool = false

@export var enable_helmet : bool = false

@export var enable_reflector : bool = false

@export var enable_magic : bool = false

@export var magic_speed_modifier : float = 0.5

@export var magic_projectile_scale_modifier : float = 1.5

@export var magic_projectile_speed_modifier : float = 2

@export var magic_sound_pitch_modifer : float = 1.5

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_firing_timer : float = 0
