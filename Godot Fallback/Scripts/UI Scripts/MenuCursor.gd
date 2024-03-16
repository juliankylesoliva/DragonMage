extends Node2D

class_name MenuCursor

@export var left_cursor : AnimatedSprite2D

@export var right_cursor : AnimatedSprite2D

@export var padding : float = 16

@export var initial_spacing : float = 0

func _ready():
	set_spacing(initial_spacing)

func set_spacing(distance : float):
	var half : float = abs(distance / 2.0)
	left_cursor.offset.x = -(half + padding)
	right_cursor.offset.x = (half + padding)
