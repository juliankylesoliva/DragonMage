extends BossState

@export var move_speed : float = 32

@export var time_between_attacks : float = 1

@export var rest_duration : float = 0.5

@export var phase_attack_state : BossState

@export var stun_state : BossState

var prison_guard : PrisonGuardBoss

var current_rest_timer : float = 0

var current_attack_timer : float = 0

var current_move_direction : float = -1

func on_enter():
	check_prison_guard_ref()
	prison_guard.update_weakness_and_defense()
	current_rest_timer = rest_duration
	current_attack_timer = time_between_attacks
	current_move_direction = (1 if prison_guard.is_boss_on_right_side else -1)
	boss.sprite.flip_h = prison_guard.is_boss_on_right_side

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	if (current_rest_timer > 0):
		current_rest_timer = move_toward(current_rest_timer, 0, _delta)
	else:
		boss.body.velocity.x = (current_move_direction * move_speed)
		current_attack_timer = move_toward(current_attack_timer, 0, _delta)
	boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
	boss.body.move_and_slide()
	if (current_attack_timer <= 0):
		set_next_state(phase_attack_state)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
