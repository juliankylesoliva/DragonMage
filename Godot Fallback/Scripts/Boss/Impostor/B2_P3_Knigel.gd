extends BossState

enum PhaseState {WINDUP, SPIN, DIZZY}

@export var impostor_boss : ImpostorBoss

@export var falling_gravity_scale : float = 3

@export var windup_backup_speed : float = 128

@export var windup_duration : float = 1

@export var spin_max_speed : float = 256

@export var spin_acceleration : float = 256

@export var spin_rising_acceleration : float = 64

@export var spin_turning_multiplier : float = 2

@export var spin_gravity_scale : float = 2

@export var spin_duration : float = 3

@export var dizzy_duration : float = 3

@export var disguise_break_state : BossState

var windup_facing_direction : float = 1

var dizzy_start_speed : float = 0

var current_phase_state : PhaseState = PhaseState.WINDUP

var current_phase_state_timer : float = 0

func on_enter():
	impostor_boss.restore_armor()
	impostor_boss.can_be_stomped = false
	init_phase_state(PhaseState.WINDUP)
	impostor_boss.sprite.play("ImpKnigelIdle")

func state_process(_delta):
	impostor_boss.check_player_collision()
	phase_state_process(_delta)
	if (impostor_boss.current_armor <= 0):
		set_next_state(disguise_break_state)

func init_phase_state(phase : PhaseState):
	current_phase_state = phase
	match current_phase_state:
		PhaseState.WINDUP:
			impostor_boss.can_reflect_projectiles = false
			impostor_boss.set_gravity_scale(falling_gravity_scale)
			impostor_boss.body.velocity = Vector2.ZERO
			windup_facing_direction = -get_direction_to_player()
			impostor_boss.sprite.flip_h = (-windup_facing_direction < 0)
			current_phase_state_timer = windup_duration
		PhaseState.SPIN:
			impostor_boss.can_reflect_projectiles = true
			impostor_boss.set_gravity_scale(spin_gravity_scale)
			impostor_boss.body.velocity = Vector2.ZERO
			current_phase_state_timer = spin_duration
		PhaseState.DIZZY:
			impostor_boss.can_reflect_projectiles = false
			impostor_boss.set_gravity_scale(falling_gravity_scale)
			dizzy_start_speed = impostor_boss.body.velocity.x
			current_phase_state_timer = dizzy_duration

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.WINDUP:
			do_windup_state(_delta)
		PhaseState.SPIN:
			do_spin_state(_delta)
		PhaseState.DIZZY:
			do_dizzy_state(_delta)

func do_windup_state(_delta):
	impostor_boss.body.velocity = (Vector2.RIGHT * windup_facing_direction * windup_backup_speed * (current_phase_state_timer / windup_duration))
	impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.SPIN)

func do_spin_state(_delta):
	if (impostor_boss.body.is_on_wall()):
		impostor_boss.body.velocity.x *= -1
	impostor_boss.sprite.flip_h = (get_direction_to_player() < 0)
	impostor_boss.body.velocity.x = move_toward(impostor_boss.body.velocity.x, spin_max_speed * get_direction_to_player(), _delta * spin_acceleration * (spin_turning_multiplier if (impostor_boss.body.velocity.x * get_direction_to_player() < 0) else 1.0))
	if (!impostor_boss.player_hub.char_body.is_on_floor() and impostor_boss.body.global_position.y > impostor_boss.player_hub.char_body.global_position.y):
		impostor_boss.body.velocity.y -= (_delta * spin_acceleration)
	else:
		impostor_boss.body.velocity.y += (impostor_boss.get_gravity_delta(_delta))
	impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.DIZZY)

func do_dizzy_state(_delta):
	if (impostor_boss.body.is_on_wall()):
		dizzy_start_speed *= -1
		impostor_boss.body.velocity.x *= -1
		impostor_boss.sprite.flip_h = !impostor_boss.sprite.flip_h
	impostor_boss.body.velocity.x = (dizzy_start_speed * (current_phase_state_timer / dizzy_duration))
	impostor_boss.body.velocity.y += (impostor_boss.get_gravity_delta(_delta))
	impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.WINDUP)

func get_direction_to_player():
	var diff : float = (impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)
	return (1.0 if diff >= 0 else -1.0)
