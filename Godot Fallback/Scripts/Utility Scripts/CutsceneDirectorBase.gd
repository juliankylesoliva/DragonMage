extends Node

class_name CutsceneDirectorBase

@export var cutscene_cast_list : Array[CutsceneActor]

@export var textbox : Textbox

@export_multiline var script_lines : Array[String]

var cast_dictionary : Dictionary

func _ready():
	for actor in cutscene_cast_list:
		cast_dictionary[actor.actor_name] = actor

# override this function in a child class for each unique cutscene
func lights_camera_action():
	pass

func say_the_lines(first : int, last : int):
	for t in script_lines.slice(first, last + 1):
		textbox.queue_text(t)
