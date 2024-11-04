extends Node

func _ready():
	while (!ProjectSettings.load_resource_pack("res://ch0_music.pck")):
		pass
	print_debug("ch0_music.pck loaded!")
	
	while (!ProjectSettings.load_resource_pack("res://ch1_music.pck")):
		pass
	print_debug("ch1_music.pck loaded!")
	
	get_tree().change_scene_to_file("res://Misc Scenes/TitleScreen.tscn")
