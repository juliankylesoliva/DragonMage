extends Node

class_name PlayerDamage

signal took_damage

signal defeated

@export var hub : PlayerHub

@export var fairy_guard_attack : FairyGuardAttack

@export var mage_temper_damage : int = 3

@export var dragon_temper_damage : int = -2

@export var vertical_damage_knockback : float = -64

@export var horizontal_damage_knockback : float = 160

@export var knockback_steering_rate : float = 200

@export var hitstun_time : float = 1

@export_range(0, 1) var hitstun_ground_cancel_portion : float = 0.5

@export var post_damage_invulnerability_time : float = 3

@export_range(0, 1) var invulnerability_alpha : float = 0.75

var damage_taken : int = 0

var knockback_direction : int = 0

var current_hitstun_timer : float = 0

var is_damage_warping : bool = false

var current_iframe_timer : float = 0

var is_damage_invulnerability_flickering : bool = false

var is_player_defeated = false

func _ready():
	if (CheckpointHandler.saved_clear_time >= 0):
		damage_taken = CheckpointHandler.saved_damage_taken

func _process(delta):
	update_iframe_timer(delta)
	do_iframe_sprite_alpha()

func is_player_guarding():
	return fairy_guard_attack.current_attack_state == Attack.AttackState.ACTIVE

func is_player_parrying():
	return (fairy_guard_attack.can_parry() or fairy_guard_attack.did_player_parry)

func is_player_damaged():
	return (current_hitstun_timer > 0 or is_damage_warping)

func is_damage_invulnerability_active():
	return (current_iframe_timer > 0)

func take_damage(knockback : int = 0):
	if (is_player_parrying()):
		on_parry()
		return false
	elif (is_player_damaged() or !can_take_damage()):
		return false
	elif (is_player_guarding() and (knockback * hub.movement.get_facing_value() < 0)):
		fairy_guard_attack.do_blockstun()
		return false
	else:
		damage_taken += 1
		if (hub.temper.is_form_locked()):
			is_player_defeated = true
			defeated.emit()
		else:
			knockback_direction = knockback
			current_hitstun_timer = hitstun_time
			hub.fairy.cut_magic_in_half()
			hub.stomp.reset_stomp_combo()
			hub.jumping.landing_reset()
			took_damage.emit()
		return true

func do_damage_warp():
	if (is_player_damaged()):
		return false
	else:
		if (is_damage_invulnerability_active()):
			is_damage_invulnerability_flickering = false
			current_iframe_timer = 0
		
		damage_taken += 1
		if (hub.temper.is_form_locked()):
			is_player_defeated = true
			defeated.emit()
		else:
			is_damage_warping = true
			hub.fairy.cut_magic_in_half()
			hub.stomp.reset_stomp_combo()
			hub.jumping.landing_reset()
			took_damage.emit()
		return true

func on_parry():
	fairy_guard_attack.do_parry()

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
	return (!is_damage_invulnerability_active() and !fairy_guard_attack.is_invincibility_active and !fairy_guard_attack.did_player_parry and !magic_blast.is_blast_jumping and fire_tackle.current_attack_state != Attack.AttackState.ACTIVE and dodge.current_attack_state != Attack.AttackState.ACTIVE and state_name != "FormChanging" and state_name != "Damaged")

func update_hitstun_timer(delta : float):
	if (is_player_damaged()):
		current_hitstun_timer = move_toward(current_hitstun_timer, 0, delta)
		if (current_hitstun_timer < (hitstun_time * hitstun_ground_cancel_portion) and hub.char_body.is_on_floor()):
			current_hitstun_timer = 0

func reset_hitstun_timer():
	current_hitstun_timer = 0

func reset_damage_warp():
	is_damage_warping = false

func update_iframe_timer(delta : float):
	if (is_damage_invulnerability_active()):
		current_iframe_timer = move_toward(current_iframe_timer, 0, delta)

func do_iframe_sprite_alpha():
	if (is_damage_invulnerability_active() and is_damage_invulnerability_flickering):
		hub.char_sprite.modulate.a = invulnerability_alpha
	else:
		hub.char_sprite.modulate.a = 1
	is_damage_invulnerability_flickering = !is_damage_invulnerability_flickering
