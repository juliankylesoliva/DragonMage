extends Node2D

class_name CameraFollow

@export_enum("Physics", "Idle") var process_callback : String = "Idle"

@export var camera_offset : Vector2 = Vector2.ZERO

func _ready():
	set_process(process_callback == "Idle")
	set_physics_process(process_callback == "Physics")

func _process(_delta):
	global_position = (get_viewport().get_camera_2d().get_screen_center_position() + camera_offset)

func _physics_process(_delta):
	global_position = (get_viewport().get_camera_2d().get_screen_center_position() + camera_offset)
