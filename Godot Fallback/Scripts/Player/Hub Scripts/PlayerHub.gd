extends Node

class_name PlayerHub

@export var state_machine : PlayerStateMachine
@export var collisions : PlayerCollisions
@export var buffers : PlayerBuffers
@export var movement : PlayerMovement
@export var jumping : PlayerJumping
@export var fairy : PlayerFairy
@export var attacks : PlayerAttacks
@export var temper : PlayerTemper
@export var form : PlayerForm
@export var damage : PlayerDamage
@export var interaction : PlayerInteraction
@export var stomp : PlayerStomp
@export var animation : PlayerAnimation
@export var sprite_trail : PlayerSpriteTrail
@export var camera : PlayerCamera
@export var audio : AudioHandler

@export var char_body : CharacterBody2D
@export var char_sprite : AnimatedSprite2D
@export var collision_shape : CollisionShape2D
@export var stream_player : AudioStreamPlayer2D

@export var raycast_dl : RayCast2D
@export var raycast_dm : RayCast2D
@export var raycast_dr : RayCast2D
@export var raycast_ledge_l : RayCast2D
@export var raycast_ledge_r : RayCast2D

@export var raycast_ul : RayCast2D
@export var raycast_um : RayCast2D
@export var raycast_ur : RayCast2D
@export var raycast_ceiling_l : RayCast2D
@export var raycast_ceiling_r : RayCast2D

@export var raycast_wall_top_l : RayCast2D
@export var raycast_wall_mid_l : RayCast2D
@export var raycast_wall_bot_l : RayCast2D
@export var raycast_wall_top_r : RayCast2D
@export var raycast_wall_mid_r : RayCast2D
@export var raycast_wall_bot_r : RayCast2D

var current_respawn_position : Vector2 = Vector2.ZERO

var is_deactivated : bool = false

func get_input_vector():
	var input_vector = Vector2.ZERO
	
	input_vector.x = ((1 if Input.is_action_pressed("Move Right") else 0) - (1 if Input.is_action_pressed("Move Left") else 0))
	input_vector.y = ((1 if Input.is_action_pressed("Move Up") else 0) - (1 if Input.is_action_pressed("Move Down") else 0))
	return input_vector

func set_respawn_position(pos : Vector2):
	current_respawn_position = pos

func do_respawn():
	char_body.global_position = current_respawn_position

func set_deactivation(b : bool):
	is_deactivated = b
