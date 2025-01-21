extends Node

@export var camera : Camera2D

@export var path : Path2D

@export var path_follow : PathFollow2D

@export var remote_transform : RemoteTransform2D

func set_curve(c : Curve2D):
	path.set_curve(c)
	path_follow.set_progress_ratio(0)
