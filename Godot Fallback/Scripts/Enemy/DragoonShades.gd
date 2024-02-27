extends RigidBody2D

class_name DragoonShades

@export var sprite : Sprite2D

@export var camera_despawn_distance : float = 800

func _physics_process(_delta):
	if (global_position.distance_to(get_viewport().get_camera_2d().global_position) >= camera_despawn_distance):
		queue_free()

func setup(enemy_ref : Enemy):
	sprite.flip_h = enemy_ref.sprite.flip_h
	constant_torque *= enemy_ref.movement.get_facing_value()
