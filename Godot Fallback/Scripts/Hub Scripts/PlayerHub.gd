extends Node

class_name PlayerHub

@export var state_machine : PlayerStateMachine
@export var collisions : PlayerCollisions
@export var buffers : PlayerBuffers
@export var movement : PlayerMovement
@export var jumping : PlayerJumping
@export var animation : PlayerAnimation

@export var char_body : CharacterBody2D
@export var char_sprite : AnimatedSprite2D
@export var collision_shape : CollisionShape2D

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = (Input.get_action_strength("Move Right") - Input.get_action_strength("Move Left"))
	input_vector.y = (Input.get_action_strength("Move Up") - Input.get_action_strength("Move Down"))
	return input_vector
