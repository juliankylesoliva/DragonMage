extends Node

class_name Breakable

@export var node_2d : Node2D

@export var fragments_scene : PackedScene = null

@export_enum("ANY", "MAGIC", "FIRE") var breakable_by : String = "ANY"

@export var break_durablility : int = 0

@export var break_sound : String = "object_block_breakable"

func break_object(other : Object):
	if (other.has_meta("BreakType") and other.has_meta("BreakStrength")):
		if (other.get_meta("BreakStrength") >= break_durablility):
			if (breakable_by == "ANY" or other.get_meta("BreakType") == breakable_by):
				SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
				if (fragments_scene != null):
					var instance = fragments_scene.instantiate()
					add_sibling(instance)
					(instance as Node2D).global_position = node_2d.global_position
					(instance as GPUParticles2D).emitting = true
				queue_free()
				return true
	return false
