extends Node

func _ready():
	print_debug(ProjectSettings.load_resource_pack("res://sounds.pck"))
	print_debug(ProjectSettings.load_resource_pack("res://ch0_music.pck"))
	print_debug(ProjectSettings.load_resource_pack("res://ch1_music.pck"))
	get_tree().change_scene_to_file("res://Misc Scenes/TitleScreen.tscn")
