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

var current_phase_state : PhaseState = PhaseState.TRAVEL

var target_throw_position : ThrowPosition = ThrowPosition.LEFT

var current_windup_time : float = 0

var sword_instance : ImpostorSwordProjectile = null

func on_enter():
	current_phase_state = PhaseState.TRAVEL
	target_throw_position = ThrowPosition.LEFT
	impostor_boss.can_be_stomped = false
	impostor_boss.sprite.play("ImpKnigelIdle")

func state_process(_delta):
	impostor_boss.check_player_collision()
	phase_state_process(_delta)
	if (impostor_boss.current_armor <= 0):
		set_next_state(disguise_break_state)

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.TRAVEL:
			do_travel_state(_delta)
		PhaseState.WINDUP:
			do_windup_state(_delta)
		PhaseState.THROW:
			do_throw_state(_delta)

func do_travel_state(_delta):
	if (fyerlarm_left.is_attack_active() or fyerlarm_right.is_attack_active()):
		if (fyerlarm_left.is_attack_active() and !fyerlarm_right.is_attack_active()):
			target_throw_position = ThrowPosition.RIGHT
		elif (!fyerlarm_left.is_attack_active() and fyerlarm_right.is_attack_active()):
			target_throw_position = ThrowPosition.LEFT
		else:
			pass
	
	impostor_boss.sprite.flip_h = (target_throw_position == ThrowPosition.LEFT)
	impostor_boss.body.global_position.x = move_toward(impostor_boss.body.global_position.x, get_target_node_position().x, move_speed * _delta)
	
	if (impostor_boss.body.global_position.x == get_target_node_position().x):
		impostor_boss.body.velocity = Vector2.ZERO
		current_windup_time = windup_duration
		impostor_boss.sprite.flip_h = !impostor_boss.sprite.flip_h
		current_phase_state = PhaseState.WINDUP

func do_windup_state(_delta):
	current_windup_time = move_toward(current_windup_time, 0, _delta)
	if (current_windup_time <= 0):
		sword_instance = impostor_boss.spawn_sword_projectile(get_target_path(), randi_range(0, 1) == 1)
		current_phase_state = PhaseState.THROW

func do_throw_state(_delta):
	if (sword_instance == null):
		swap_target_throw_position()
		current_phase_state = PhaseState.TRAVEL

func get_target_node_position():
	return (sword_throw_position_left.global_position if target_throw_position == ThrowPosition.LEFT else sword_throw_position_right.global_position)

func get_target_path():
	return (sword_throw_path_left if target_throw_position == ThrowPosition.LEFT else sword_throw_path_right)

func swap_target_throw_position():
	target_throw_position = (ThrowPosition.RIGHT if target_throw_position == ThrowPosition.LEFT else ThrowPosition.LEFT)
