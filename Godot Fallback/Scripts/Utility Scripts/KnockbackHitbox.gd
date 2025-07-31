extends Node2D

class_name KnockbackHitbox

signal hit

@export var damage_type : StringName = "NONE"

@export var damage_strength : int = 0

@export var collision_shape : CollisionShape2D

@export var ray : RayCast2D

@export var pixels_per_unit : float = 0

@export var knockback_strength : float = 0

@export var knockback_effect_radius : float = 0

@export var lifetime : float = -1

@export var is_projectile : bool = false

var current_lifetime_left : float = 0

func _ready():
	collision_shape.shape.radius = knockback_effect_radius
	current_lifetime_left = lifetime

func _physics_process(delta):
	if (current_lifetime_left > 0):
		current_lifetime_left = move_toward(current_lifetime_left, 0, delta)
		if (current_lifetime_left <= 0):
			queue_free()

func _on_body_entered(_body):
	pass
