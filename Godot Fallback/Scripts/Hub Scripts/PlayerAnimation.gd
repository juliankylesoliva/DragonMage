extends Node

class_name PlayerAnimation

@export var hub : PlayerHub

func set_animation(animation_name : String):
	hub.char_sprite.animation = animation_name

func set_animation_speed(speed : float):
	hub.char_sprite.speed_scale = speed

func set_animation_frame(frame : int):
	hub.char_sprite.set_frame_and_progress(frame, 0)
