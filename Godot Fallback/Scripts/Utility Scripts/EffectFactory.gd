extends Node

@export var offset_dictonary : Dictionary

@export var frames : SpriteFrames

const frames_path : String = "res://SpriteEffects.tres"

const effects_z_layer : int = 6

func _ready():
	pass

func get_effect(anim_name : String, position : Vector2, scale : float = 1, flip_h : bool = false):
	var instance = AnimatedSprite2D.new()
	instance.sprite_frames = frames
	instance.animation = anim_name
	instance.animation_finished.connect(remove_node.bind(instance))
	instance.scale.x = scale
	instance.scale.y = scale
	instance.offset = (offset_dictonary[anim_name] if offset_dictonary.has(anim_name) else Vector2.ZERO)
	instance.flip_h = flip_h
	instance.offset.x *= (-1 if flip_h else 1)
	instance.z_index = effects_z_layer
	add_child(instance)
	(instance as Node2D).global_position = position
	instance.play()
	return instance

func clear_effects():
	for child in get_children():
		child.queue_free()

func remove_node(instance : AnimatedSprite2D):
	instance.queue_free()
