extends BossState

enum PhaseState {TRAVEL, WINDUP, ATTACK}

@export var impostor_boss : ImpostorBoss

@export var move_speed : float = 128

@export var attack_speed : float = 128

@export var back_target_offset : float = 32

@export var distance_margin : float = 2

@export var attack_windup_duration : float = 0.85

@export var attack_endlag_duration : float = 0.6

@export_range(0, 1) var partial_invis_alpha : float = 0.15

@export var damaged_state : BossState

@export var minimum_health : int = 7

var current_phase_state : PhaseState = PhaseState.TRAVEL

var attack_direction : float = 1

var current_phase_state_timer : float = 0

func on_enter():
	impostor_boss.is_invisible = true
	impostor_boss.can_be_stomped = true
	current_phase_state = PhaseState.TRAVEL
	impostor_boss.sprite.play("DrickeryIdle")

func state_process(_delta):
	phase_state_process(_delta)
	if (impostor_boss.current_health < minimum_health):
		set_next_state(damaged_state)

func on_exit():
	impostor_boss.is_invisible = false

func init_phase_state(phase : PhaseState):
	current_phase_state = phase
	match current_phase_state:
		PhaseState.TRAVEL:
			impostor_boss.body.velocity = Vector2.ZERO
			impostor_boss.is_invisible = true
			impostor_boss.can_be_stomped = false
			impostor_boss.sprite.modulate.a = 0.0
		PhaseState.WINDUP:
			impostor_boss.body.velocity = Vector2.ZERO
			attack_direction = get_direction_to_player()
			impostor_boss.sprite.flip_h = (attack_direction < 0)
			current_phase_state_timer = attack_windup_duration
			impostor_boss.sprite.modulate.a = 0.0
		PhaseState.ATTACK:
			impostor_boss.is_invisible = false
			impostor_boss.can_be_stomped = true
			current_phase_state_timer = attack_endlag_duration
			impostor_boss.sprite.modulate.a = 1.0

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.TRAVEL:
			do_travel_state(_delta)
		PhaseState.WINDUP:
			do_windup_state(_delta)
		PhaseState.ATTACK:
			do_attack_state(_delta)

func do_travel_state(_delta):
	impostor_boss.sprite.modulate.a = (partial_invis_alpha if impostor_boss.is_player_in_collider else 0.0)
	
	if (((is_near_player() or impostor_boss.body.is_on_wall()) and (get_direction_to_player() * impostor_boss.player_hub.movement.get_facing_value()) > 0)):
		if (impostor_boss.player_hub.char_body.is_on_floor() and !is_player_attacking()):
			init_phase_state(PhaseState.WINDUP)
	else:
		impostor_boss.body.velocity.x = (abs(move_speed) * get_direction_to_target())
		impostor_boss.sprite.flip_h = (impostor_boss.body.velocity.x < 0)
		impostor_boss.body.move_and_slide()

func do_windup_state(_delta):
	impostor_boss.sprite.modulate.a = partial_invis_alpha
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.ATTACK)

func do_attack_state(_delta):
	impostor_boss.check_player_collision()
	impostor_boss.body.velocity.x = (abs(attack_speed) * attack_direction * (current_phase_state_timer / attack_endlag_duration))
	impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.TRAVEL)

func get_target_x_location():
	return (impostor_boss.player_hub.char_body.global_position.x + (abs(back_target_offset) * -impostor_boss.player_hub.movement.get_facing_value()))

func get_distance_to_player():
	return abs(impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)

func get_direction_to_target():
	var diff : float = (get_target_x_location() - impostor_boss.body.global_position.x)
	return (1.0 if diff >= 0 else -1.0)

func get_direction_to_player():
	var diff : float = (impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)
	return (1.0 if diff >= 0 else -1.0)

func is_near_player():
	return (get_distance_to_player() >= (back_target_offset - distance_margin) and get_distance_to_player() <= (back_target_offset + distance_margin))

func is_player_attacking():
	var player_temp : PlayerHub = impostor_boss.player_hub
	var magic_blast_temp : MagicBlastAttack = player_temp.jumping.magic_blast_attack
	return (player_temp.state_machine.current_state.name == "Attacking" or magic_blast_temp.projectile_instance != null or magic_blast_temp.is_blast_jumping)
