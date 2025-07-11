extends Node2D

class_name Breakable

signal on_break

@export var node_2d : Node2D

@export var fragments_scene : PackedScene = null

@export var can_enemy_projectiles_hit : bool = false

@export_enum("ANY", "MAGIC", "FIRE") var breakable_by : String = "ANY"

@export var break_durablility : int = 0

@export var break_sound : String = "object_block_breakable"

func break_object(other : Object):
	if ((other is KnockbackHitbox)):
		var hitbox_temp : KnockbackHitbox = (other as KnockbackHitbox)
		if (hitbox_temp.damage_strength >= break_durablility):
			if (breakable_by == "ANY" or hitbox_temp.damage_type == breakable_by):
				do_break()
				return true
	elif (can_enemy_projectiles_hit and (other is EnemyProjectile)):
		var proj_temp : EnemyProjectile = (other as EnemyProjectile)
		if (breakable_by == "ANY" or proj_temp.damage_type == breakable_by):
			do_break()
			return true
	else:
		return false

func do_break():
	SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
	if (fragments_scene != null):
		var instance = fragments_scene.instantiate()
		add_sibling(instance)
		(instance as Node2D).global_position = node_2d.global_position
		(instance as CPUParticles2D).emitting = true
	on_break.emit()
	queue_free()
