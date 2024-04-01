extends Node

class_name PlayerFairy

@export var hub : PlayerHub

@export var is_using_fairy : bool = false

@export var fairy_follower_scene : PackedScene

@export var fairy_target_node : Node2D

@export var fairy_target_offset : float = 32

var fairy_ref : FairyFollow

func _ready():
	if (is_using_fairy):
		var node_temp : Node = fairy_follower_scene.instantiate()
		call_deferred("add_sibling", node_temp)
		fairy_ref = (node_temp as FairyFollow)
		fairy_ref.set_home_position_target(fairy_target_node)

func _physics_process(_delta):
	if (is_using_fairy and fairy_ref != null):
		fairy_ref.set_facing_direction(hub.movement.get_facing_value())
		update_target_node_position()

func update_target_node_position():
	fairy_target_node.position.x = (fairy_target_offset * -hub.movement.get_facing_value())
