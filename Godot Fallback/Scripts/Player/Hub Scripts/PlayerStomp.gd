extends Node

class_name PlayerStomp

@export var hub : PlayerHub

@export var stomp_damage : int = 1

@export var base_magic_gain : float = 1

@export var stomp_combo_multiplier : float = 2

@export var max_stomp_combo : int = 4

@export var stomp_hitbox : StompKnockbackHitbox

@export var valid_stomp_state_names : Array[String]

@export var magic_blast_attack : MagicBlastAttack

@export var dodge_attack : DodgeAttack

@export var fire_tackle_attack : FireTackleAttack

var current_stomp_combo : int = 0

func is_stomping_enemy():
	if (!hub.damage.is_player_damaged() and !hub.char_body.is_on_floor() and !magic_blast_attack.is_blast_jumping and (valid_stomp_state_names.has(hub.state_machine.current_state.name) or can_do_rising_stomp() or is_valid_attack_state())):
		if (stomp_hitbox.enemy_to_stomp != null and hub.raycast_dm.global_position.y < stomp_hitbox.enemy_to_stomp.body.global_position.y):
			return true
		elif (stomp_hitbox.boss_to_stomp != null and hub.raycast_dm.global_position.y < stomp_hitbox.boss_to_stomp.body.global_position.y):
			return (true and !can_do_rising_stomp())
		else:
			pass
	return false

func do_stomp_jump():
	if (stomp_hitbox.boss_to_stomp != null):
		stomp_hitbox.boss_to_stomp.damage_boss(stomp_hitbox.damage_type, stomp_damage, Vector2.RIGHT * hub.movement.get_facing_value() * abs(hub.char_body.velocity.y))
		EffectFactory.get_effect("StompImpact", hub.raycast_dm.global_position)
		if (hub.jumping.is_fast_falling):
			hub.sprite_trail.deactivate_trail()
			hub.jumping.reset_fast_fall()
			hub.jumping.charge_super_jump_with_fast_fall()
		hub.jumping.start_ground_jump()
		hub.fairy.change_current_magic_by(base_magic_gain * pow(stomp_combo_multiplier, current_stomp_combo))
		increase_stomp_combo()
	elif (can_do_rising_stomp() and stomp_hitbox.enemy_to_stomp.defeat_enemy(stomp_hitbox.damage_type)):
		EffectFactory.get_effect("StompImpact", hub.raycast_dm.global_position)
		if (hub.jumping.is_fast_falling):
			hub.sprite_trail.deactivate_trail()
			hub.jumping.reset_fast_fall()
			hub.jumping.charge_super_jump_with_fast_fall()
		hub.jumping.start_ground_jump()
		hub.fairy.change_current_magic_by(base_magic_gain * pow(stomp_combo_multiplier, current_stomp_combo))
		increase_stomp_combo()
	else:
		pass

func is_valid_attack_state():
	return (fire_tackle_attack.current_attack_state == Attack.AttackState.ENDLAG or dodge_attack.current_attack_state == Attack.AttackState.ACTIVE)

func can_do_rising_stomp():
	return (hub.state_machine.current_state.name == "Jumping")

func increase_stomp_combo():
	if (current_stomp_combo < max_stomp_combo):
		current_stomp_combo += 1

func reset_stomp_combo():
	current_stomp_combo = 0
