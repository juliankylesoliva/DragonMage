extends Node

class_name PlayerStomp

@export var hub : PlayerHub

@export var stomp_hitbox : StompKnockbackHitbox

@export var valid_stomp_state_names : Array[String]

@export var magic_blast_attack : MagicBlastAttack

@export var fire_tackle_attack : FireTackleAttack

func _physics_process(_delta):
	stomp_check()

func stomp_check():
	if (!hub.damage.is_player_damaged() and !hub.char_body.is_on_floor() and !magic_blast_attack.is_blast_jumping and fire_tackle_attack.current_attack_state == Attack.AttackState.NOTHING and valid_stomp_state_names.has(hub.state_machine.current_state.name)):
		if (stomp_hitbox.enemy_to_stomp != null and hub.raycast_dm.global_position.y < stomp_hitbox.enemy_to_stomp.body.global_position.y):
			if (stomp_hitbox.enemy_to_stomp.defeat_enemy(stomp_hitbox.damage_type)):
				EffectFactory.get_effect("StompImpact", hub.raycast_dm.global_position)
				if (hub.jumping.is_fast_falling):
					hub.jumping.charge_super_jump_with_fast_fall()
				hub.jumping.start_ground_jump()
				hub.state_machine.current_state.set_next_state(hub.state_machine.get_state_by_name("Jumping"))
