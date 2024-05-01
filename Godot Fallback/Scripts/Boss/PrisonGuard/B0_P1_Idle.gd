extends BossState

@export var move_speed : float = 96

@export var initial_move_time : float = 1

@export var time_between_attacks : float = 1

@export var phase_attack_state : BossState

@export var side_switch_state : BossState

@export var stun_state : BossState

var prison_guard : PrisonGuardBoss

var current_attack_timer : float = 0

var current_move_direction : float = 1

var is_first_move : bool = true

func on_enter():
	check_prison_guard_ref()
	prison_guard.update_weakness_and_defense()
	current_attack_timer = (time_between_attacks if !is_first_move else initial_move_time)
	if (is_first_move):
		is_first_move = false
	# set idle animation

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	boss.body.velocity.x = (current_move_direction * move_speed)
	boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
	boss.body.move_and_slide()
	current_attack_timer = move_toward(current_attack_timer, 0, _delta)
	
	if ((prison_guard.is_boss_on_right_side and prison_guard.is_player_on_right_side) or (!prison_guard.is_boss_on_right_side and !prison_guard.is_player_on_right_side)):
		set_next_state(side_switch_state)
	elif (current_attack_timer <= 0):
		set_next_state(phase_attack_state)

func on_exit():
	if (next_state == side_switch_state):
		is_first_move = true
	current_move_direction *= -1

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
