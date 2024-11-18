extends Node2D

class_name Breakable

@export var node_2d : Node2D

@export var fragments_scene : PackedScene = null

@export_enum("ANY", "MAGIC", "FIRE") var breakable_by : String = "ANY"

@export var break_durablility : int = 0

@export var break_sound : String = "object_block_breakable"

func break_object(other : Object):
	if ((other is KnockbackHitbox)):
		var hitbox_temp : KnockbackHitbox = (other as KnockbackHitbox)
		if (hitbox_temp.damage_strength >= break_durablility):
			if (breakable_by == "ANY" or hitbox_temp.damage_type == breakable_by):
				SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
				if (fragments_scene != null):
					var instance = fragments_scene.instantiate()
					add_sibling(instance)
					(instance as Node2D).global_position = node_2d.global_position
					(instance as CPUParticles2D).emitting = true
				queue_free()
				return true
	return false
