extends BossState

enum PhaseState {TRAVEL, WINDUP, THROW}

enum ThrowPosition {LEFT, RIGHT}

@export var impostor_boss : ImpostorBoss

@export var move_speed : float = 128

@export var windup_duration : float = 0.5

@export var disguise_break_state : BossState

@export var sword_throw_position_left : Node2D

@export var sword_throw_position_right : Node2D

@export var sword_throw_path_left : Path2D

@export var sword_throw_path_right : Path2D

@export var fyerlarm_left : Fyerlarm

@export var fyerlarm_right : Fyerlarm

@export_range(0, 1) var left_turnaround_threshold : float = 0.6

@export_range(0, 1) var right_turnaround_threshold : float = 0.4

var current_phase_state : PhaseState = PhaseState.TRAVEL

var target_throw_position : ThrowPosition = ThrowPosition.RIGHT

var current_windup_time : float = 0

var sword_instance : ImpostorSwordProjectile = null

func on_enter():
	impostor_boss.restore_armor()
	current_phase_state = PhaseState.TRAVEL
	target_throw_position = (ThrowPosition.LEFT if impostor_boss.player_hub.char_body.global_position.x > impostor_boss.body.global_position.x else ThrowPosition.RIGHT)
	impostor_boss.can_be_stomped = false
	impostor_boss.can_reflect_projectiles = true
	impostor_boss.sprite.play("ImpKnigelIdle")

func state_process(_delta):
	impostor_boss.check_player_collision()
	phase_state_process(_delta)
	if (impostor_boss.current_armor <= 0):
		set_next_state(disguise_break_state)

func init_phase_state(phase : PhaseState):
	current_phase_state = phase
	match current_phase_state:
		PhaseState.TRAVEL:
			swap_target_throw_position()
		PhaseState.WINDUP:
			current_windup_time = windup_duration
			impostor_boss.sprite.flip_h = !impostor_boss.sprite.flip_h
		PhaseState.THROW:
			sword_instance = impostor_boss.spawn_sword_projectile(get_target_path(), impostor_boss.player_hub.char_body.is_on_floor(), !impostor_boss.sprite.flip_h)

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.TRAVEL:
			do_travel_state(_delta)
		PhaseState.WINDUP:
			do_windup_state(_delta)
		PhaseState.THROW:
			do_throw_state(_delta)

func do_travel_state(_delta):
	var distance_btwn_fyerlarms : float = inverse_lerp(sword_throw_position_left.global_position.x, sword_throw_position_right.global_position.x, impostor_boss.global_position.x)
	if (fyerlarm_left.is_attack_active() or fyerlarm_right.is_attack_active()):
		if (fyerlarm_left.is_attack_active() and !fyerlarm_right.is_attack_active() and distance_btwn_fyerlarms < left_turnaround_threshold):
			target_throw_position = ThrowPosition.RIGHT
		elif (!fyerlarm_left.is_attack_active() and fyerlarm_right.is_attack_active() and distance_btwn_fyerlarms > right_turnaround_threshold):
			target_throw_position = ThrowPosition.LEFT
		else:
			pass
	
	impostor_boss.sprite.flip_h = (target_throw_position == ThrowPosition.LEFT)
	impostor_boss.body.global_position.x = move_toward(impostor_boss.body.global_position.x, get_target_node_position().x, move_speed * _delta)
	
	if (impostor_boss.body.global_position.x == get_target_node_position().x):
		init_phase_state(PhaseState.WINDUP)

func do_windup_state(_delta):
	current_windup_time = move_toward(current_windup_time, 0, _delta)
	if (current_windup_time <= 0):
		init_phase_state(PhaseState.THROW)

func do_throw_state(_delta):
	if (sword_instance == null):
		init_phase_state(PhaseState.TRAVEL)

func get_target_node_position():
	return (sword_throw_position_left.global_position if target_throw_position == ThrowPosition.LEFT else sword_throw_position_right.global_position)

func get_target_path():
	return (sword_throw_path_left if target_throw_position == ThrowPosition.LEFT else sword_throw_path_right)

func swap_target_throw_position():
	target_throw_position = (ThrowPosition.RIGHT if target_throw_position == ThrowPosition.LEFT else ThrowPosition.LEFT)
