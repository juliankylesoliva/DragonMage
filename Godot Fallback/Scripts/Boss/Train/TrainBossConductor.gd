extends Breakable

@export var boss : Boss

@export var player_cutscene_position : Node2D

@export var sprite : AnimatedSprite2D

@export var react_trigger : Trigger

@export var damage_animation_time : float = 1

var hit_taken : bool = false

var damage_anim_time_left : float = 0

func _ready():
	react_trigger.trigger_entered.connect(on_react_trigger_enter)
	react_trigger.trigger_exited.connect(on_react_trigger_exit)

func _process(delta):
	if (sprite.animation == "Damage" and damage_anim_time_left > 0):
		damage_anim_time_left = move_toward(damage_anim_time_left, 0, delta)
		if (damage_anim_time_left <= 0):
			if (boss.current_health > 0):
				sprite.play("Lookback")
			else:
				sprite.play("Defeat")

func break_object(other : Object):
	if (!hit_taken and (other is KnockbackHitbox)):
		var hitbox_temp : KnockbackHitbox = (other as KnockbackHitbox)
		if (hitbox_temp.damage_strength >= break_durablility):
			if (breakable_by == "ANY" or hitbox_temp.damage_type == breakable_by):
				SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
				on_break.emit()
				hit_taken = true
				boss.damage_boss(hitbox_temp.damage_type, hitbox_temp.damage_strength, Vector2.ZERO)
				if (player_cutscene_position != null):
					boss.player_hub.char_body.global_position = player_cutscene_position.global_position
					boss.player_hub.movement.set_facing_direction(1.0)
					boss.player_hub.fairy.fairy_ref.snap_to_target_node()
				sprite.play("Damage")
				set_damage_anim_timer()
				return true
	return false

func set_damage_anim_timer():
	damage_anim_time_left = damage_animation_time

func on_react_trigger_enter():
	if (!hit_taken):
		sprite.play("Lookback")

func on_react_trigger_exit():
	if (!hit_taken):
		sprite.play("Idle")
