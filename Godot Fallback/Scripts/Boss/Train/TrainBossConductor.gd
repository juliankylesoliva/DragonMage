extends Breakable

@export var boss : Boss

var hit_taken : bool = false

func break_object(other : Object):
	if (!hit_taken and (other is KnockbackHitbox)):
		var hitbox_temp : KnockbackHitbox = (other as KnockbackHitbox)
		if (hitbox_temp.damage_strength >= break_durablility):
			if (breakable_by == "ANY" or hitbox_temp.damage_type == breakable_by):
				SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
				on_break.emit()
				hit_taken = true
				boss.damage_boss(hitbox_temp.damage_type, hitbox_temp.damage_strength, Vector2.ZERO)
				return true
	return false
