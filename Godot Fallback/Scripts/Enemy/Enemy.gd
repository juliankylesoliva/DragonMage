extends Node

class_name Enemy

@export var movement : EnemyMovement

@export var collision_detection : EnemyCollisionDetection

@export var player_detection : EnemyPlayerDetection

@export var immunity_list : Array[StringName]

@export var body : CharacterBody2D

@export var sprite : AnimatedSprite2D

@export var shape : CollisionShape2D

@export var visibility_notifier : VisibleOnScreenNotifier2D

@export var defeated_deactivation_camera_distance : float = 25

@export var vertical_launch_velocity_on_defeat : float = -128

@export var launch_velocity_on_parry : float = 480

@export var gravity_scale : float = 3

@export var normal_z_index : int = 3

@export var z_index_on_defeat : int = 6

var is_defeated : bool = false

var home_position : Vector2 = Vector2.ZERO

func defeat_enemy(damage_type : StringName):
	if (!is_defeated and !immunity_list.has(damage_type)):
		is_defeated = true
		body.velocity = (vertical_launch_velocity_on_defeat * Vector2.UP if damage_type != "PARRY" and damage_type != "INVINCIBILITY" else launch_velocity_on_parry * Vector2(-movement.get_facing_value(), -1))
		sprite.z_index = z_index_on_defeat
		on_defeat()
		return true
	return false

func respawn_enemy():
	is_defeated = false
	sprite.z_index = normal_z_index

func check_defeated_camera_distance():
	if (is_defeated):
		if (body.global_position.distance_to(get_viewport().get_camera_2d().global_position) >= defeated_deactivation_camera_distance):
			set_process(false)
			get_parent().set_process(false)
			sprite.set_visible(false)
			movement.set_process_mode(Node.PROCESS_MODE_DISABLED)

func play_damage_sound():
	SoundFactory.play_sound_by_name("damage_enemy", body.global_position, -2, 1, "SFX")

func activate_enemy():
	pass

func deactivate_enemy():
	pass

func on_defeat():
	pass
