extends Node

var offset_dictonary : Dictionary

const frames_path : String = "res://SpriteEffects.tres"

const effects_z_layer : int = 6

var frames : SpriteFrames

func _ready():
	frames = load(frames_path)
	var file : FileAccess = FileAccess.open("res://Scene Objects/Effects/sprite_effect_offsets.txt", FileAccess.READ)
	while (file.get_position() < file.get_length()):
		var csv_line : PackedStringArray = file.get_csv_line()
		offset_dictonary[csv_line[0]] = Vector2(csv_line[1].to_float(), csv_line[2].to_float())
	file.close()

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

func remove_node(instance : AnimatedSprite2D):
	instance.queue_free()
