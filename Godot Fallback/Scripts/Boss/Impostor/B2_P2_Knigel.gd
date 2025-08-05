extends BossState

enum PhaseState {TRAVEL, JUMP, WINDUP, ATTACK, LAND}

@export var impostor_boss : ImpostorBoss

@export var move_speed : float = 128

@export var cooldown_duration : float = 1

@export var attack_distance : float = 96

@export var jump_speed : float = 256

@export var jump_gravity : float = 2

@export var windup_duration : float = 0.5

@export var windup_rising_speed : float = 64

@export var attack_speed : float = 256

@export var endlag_duration : float = 0.5

@export var arena_boundary_left : Node2D

@export var arena_boundary_right : Node2D

@export var fyerlarm_left : Fyerlarm

@export var fyerlarm_right : Fyerlarm

@export var disguise_break_state : BossState

var current_phase_state : PhaseState = PhaseState.TRAVEL

var current_phase_state_timer : float = 0

func on_enter():
	impostor_boss.restore_armor()
	impostor_boss.can_be_stomped = false
	impostor_boss.can_reflect_projectiles = true
	init_phase_state(PhaseState.TRAVEL)
	impostor_boss.sprite.play("ImpKnigelIdle")

func state_process(_delta):
	impostor_boss.check_player_collision()
	phase_state_process(_delta)
	if (impostor_boss.current_armor <= 0):
		set_next_state(disguise_break_state)

func init_phase_state(state : PhaseState):
	current_phase_state = state
	match current_phase_state:
		PhaseState.TRAVEL:
			current_phase_state_timer = cooldown_duration
		PhaseState.JUMP:
			impostor_boss.set_gravity_scale(jump_gravity)
			impostor_boss.body.velocity.x = (abs(move_speed) * get_direction_to_player())
			impostor_boss.body.velocity.y = -jump_speed
			impostor_boss.sprite.flip_h = (impostor_boss.body.velocity.x < 0)
		PhaseState.WINDUP:
			impostor_boss.set_gravity_scale(0)
			impostor_boss.body.velocity = Vector2.ZERO
			current_phase_state_timer = windup_duration
		PhaseState.ATTACK:
			impostor_boss.body.velocity = (Vector2.DOWN * abs(attack_speed))
		PhaseState.LAND:
			current_phase_state_timer = endlag_duration
		_:
			pass

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.TRAVEL:
			do_travel_state(_delta)
		PhaseState.JUMP:
			do_jump_state(_delta)
		PhaseState.WINDUP:
			do_windup_state(_delta)
		PhaseState.ATTACK:
			do_attack_state(_delta)
		PhaseState.LAND:
			do_land_state(_delta)
		_:
			pass

func do_travel_state(_delta):
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0 and is_near_player()):
		init_phase_state(PhaseState.JUMP)
	else:
		impostor_boss.body.velocity.x = (abs(move_speed) * get_direction_to_player())
		impostor_boss.sprite.flip_h = (impostor_boss.body.velocity.x < 0)
		
		if (!is_near_player() or impostor_boss.player_hub.char_body.is_on_floor()):
			impostor_boss.body.move_and_slide()
		
		if (impostor_boss.body.is_on_wall()):
			current_phase_state_timer = 0

func do_jump_state(_delta):
	impostor_boss.body.velocity.y += impostor_boss.get_gravity_delta(_delta)
	impostor_boss.body.move_and_slide()
	if (impostor_boss.body.velocity.y >= 0):
		init_phase_state(PhaseState.WINDUP)

func do_windup_state(_delta):
	impostor_boss.body.velocity.y = (-windup_rising_speed * (current_phase_state_timer / windup_duration))
	impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.ATTACK)

func do_attack_state(_delta):
	impostor_boss.body.velocity = (Vector2.DOWN * abs(attack_speed))
	impostor_boss.body.move_and_slide()
	if (impostor_boss.body.is_on_floor()):
		init_phase_state(PhaseState.LAND)

func do_land_state(_delta):
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.TRAVEL)

func get_distance_to_player():
	return abs(impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)

func get_direction_to_player():
	var diff : float = (impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)
	return (1.0 if diff >= 0 else -1.0)

func is_near_player():
	return (get_distance_to_player() <= attack_distance)
