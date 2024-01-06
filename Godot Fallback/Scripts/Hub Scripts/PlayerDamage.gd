extends Node

class_name PlayerDamage

@export var hub : PlayerHub

@export var mage_temper_damage : int = 3

@export var dragon_temper_damage : int = -2

@export var vertical_damage_knockback : float = -64

@export var horizontal_damage_knockback : float = 160

@export var knockback_steering_rate : float = 200

@export var hitstun_time : float = 1

@export_range(0, 1) var hitstun_ground_cancel_portion : float = 0.5

@export var post_damage_invulnerability_time : float = 3

@export_range(0, 1) var invulnerability_alpha : float = 0.75

var knockback_direction : int = 0

var current_hitstun_timer : float = 0

var current_iframe_timer : float = 0

var is_damage_invulnerability_flickering : bool = false

func _process(delta):
	update_iframe_timer(delta)
	do_iframe_sprite_alpha()

func is_player_damaged():
	return (current_hitstun_timer > 0)

func is_damage_invulnerability_active():
	return (current_iframe_timer > 0)

func take_damage(knockback : int = 0):
	if (is_player_damaged() or !can_take_damage()):
		return false
	
	knockback_direction = knockback
	current_hitstun_timer = hitstun_time
	return true

func do_knockback():
	if (knockback_direction == 0):
		knockback_direction = -hub.movement.get_facing_value()
	
	hub.jumping.switch_to_falling_gravity()
	hub.char_body.velocity = Vector2(knockback_direction * horizontal_damage_knockback, vertical_damage_knockback)

func update_knockback(delta : float):
	if (!hub.char_body.is_on_floor()):
		hub.char_body.velocity.x += (hub.get_input_vector().x * knockback_steering_rate * delta)
	
	if (hub.char_body.velocity.y >= 0 and hub.char_body.is_on_floor()):
		hub.char_body.velocity.x = 0
	
	hub.char_body.velocity.y += hub.jumping.get_gravity_delta(delta)
	if (hub.char_body.velocity.y > hub.jumping.max_fall_speed):
		hub.char_body.velocity.y = hub.jumping.max_fall_speed
	
	var intended_velocity : Vector2 = hub.char_body.velocity
	hub.char_body.move_and_slide()
	hub.collisions.upward_slope_correction(intended_velocity)

func do_iframes():
	if (is_damage_invulnerability_active()):
		return
	is_damage_invulnerability_flickering = false
	current_iframe_timer = post_damage_invulnerability_time

func can_take_damage():
	var state_name : String = hub.state_machine.current_state.name
	var magic_blast : MagicBlastAttack = (hub.attacks.get_attack_by_name("MagicBlast") as MagicBlastAttack)
	var fire_tackle : FireTackleAttack = (hub.attacks.get_attack_by_name("FireTackle") as FireTackleAttack)
	var dodge : DodgeAttack = (hub.attacks.get_attack_by_name("Dodge") as DodgeAttack)
	return (!is_damage_invulnerability_active() and !magic_blast.is_blast_jumping and fire_tackle.current_attack_state != Attack.AttackState.ACTIVE and dodge.current_attack_state != Attack.AttackState.ACTIVE and state_name != "FormChanging" and state_name != "Damaged")

func update_hitstun_timer(delta : float):
	if (is_player_damaged()):
		current_hitstun_timer = move_toward(current_hitstun_timer, 0, delta)
		if (current_hitstun_timer < (hitstun_time * hitstun_ground_cancel_portion) and hub.char_body.is_on_floor()):
			current_hitstun_timer = 0

func update_iframe_timer(delta : float):
	if (is_damage_invulnerability_active()):
		current_iframe_timer = move_toward(current_iframe_timer, 0, delta)

func do_iframe_sprite_alpha():
	if (is_damage_invulnerability_active() and is_damage_invulnerability_flickering):
		hub.char_sprite.modulate.a = invulnerability_alpha
	else:
		hub.char_sprite.modulate.a = 1
	is_damage_invulnerability_flickering = !is_damage_invulnerability_flickering
