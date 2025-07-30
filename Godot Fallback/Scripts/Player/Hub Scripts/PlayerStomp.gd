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

@export var slide_attack : SlideAttack

var current_stomp_combo : int = 0

var is_rising_stomp_on_cooldown : bool = false

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
	if (stomp_hitbox.boss_to_stomp != null and stomp_hitbox.boss_to_stomp.can_be_stomped):
		var stomp_result : bool = stomp_hitbox.boss_to_stomp.damage_boss(stomp_hitbox.damage_type, stomp_damage, Vector2.RIGHT * hub.movement.get_facing_value() * abs(hub.char_body.velocity.y))
		if (stomp_result):
			EffectFactory.get_effect("StompImpact", hub.raycast_dm.global_position)
		else:
			EffectFactory.get_effect("HeadbonkFX", hub.raycast_dm.global_position)
			var boss_bonk_sound_name : String = ("jump_magli_headbonk" if hub.form.is_a_mage() else "jump_draelyn_headbonk")
			SoundFactory.play_sound_by_name(boss_bonk_sound_name, hub.char_body.global_position, -2)
		
		if (hub.jumping.is_fast_falling):
			hub.sprite_trail.deactivate_trail()
			hub.jumping.reset_fast_fall()
			hub.jumping.charge_super_jump_with_fast_fall()
		hub.jumping.start_ground_jump()
		#hub.fairy.change_current_magic_by(base_magic_gain * pow(stomp_combo_multiplier, current_stomp_combo))
		#increase_stomp_combo()
	elif (stomp_hitbox.enemy_to_stomp.defeat_enemy(stomp_hitbox.damage_type) and !is_rising_stomp_on_cooldown):
		if (hub.jumping.is_fast_falling):
			hub.sprite_trail.deactivate_trail()
			hub.jumping.reset_fast_fall()
			hub.jumping.charge_super_jump_with_fast_fall()
		hub.jumping.start_ground_jump()
		if (stomp_hitbox.enemy_to_stomp.is_defeated):
			EffectFactory.get_effect("StompImpact", hub.raycast_dm.global_position)
			hub.fairy.change_current_magic_by(base_magic_gain * pow(stomp_combo_multiplier, current_stomp_combo))
			increase_stomp_combo()
		else:
			EffectFactory.get_effect("HeadbonkFX", hub.raycast_dm.global_position)
			var bonk_sound_name : String = ("jump_magli_headbonk" if hub.form.is_a_mage() else "jump_draelyn_headbonk")
			SoundFactory.play_sound_by_name(bonk_sound_name, hub.char_body.global_position, -2)
			set_rising_stomp_cooldown()
	else:
		pass

func is_valid_attack_state():
	return (fire_tackle_attack.current_attack_state == Attack.AttackState.ENDLAG or dodge_attack.current_attack_state == Attack.AttackState.ACTIVE or slide_attack.current_attack_state == Attack.AttackState.ACTIVE)

func can_do_rising_stomp():
	return (!is_rising_stomp_on_cooldown and hub.state_machine.current_state.name == "Jumping")

func set_rising_stomp_cooldown():
	is_rising_stomp_on_cooldown = true

func reset_rising_stomp_cooldown():
	is_rising_stomp_on_cooldown = false

func increase_stomp_combo():
	if (current_stomp_combo < max_stomp_combo):
		current_stomp_combo += 1

func reset_stomp_combo():
	current_stomp_combo = 0
