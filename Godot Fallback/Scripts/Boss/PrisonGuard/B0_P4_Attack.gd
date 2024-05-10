extends BossState

@export var phase_idle_state : BossState

@export var stun_state : BossState

@export var left_start_point : Node2D

@export var right_start_point : Node2D

@export var high_midpoint : Node2D

@export var low_midpoint : Node2D

@export var windup_time : float = 0.5

@export var attack_time : float = 1

var prison_guard : PrisonGuardBoss

var starting_point : Vector2

var midpoint : Vector2

var ending_point : Vector2

var windup_speed : float = 0

var is_windup_done : bool = false

var horizontal_speed : float = 0

func on_enter():
	check_prison_guard_ref()
	check_boss_side()
	boss.body.velocity = Vector2.ZERO
	starting_point = (right_start_point.global_position if prison_guard.is_boss_on_right_side else left_start_point.global_position)
	ending_point = (left_start_point.global_position if prison_guard.is_boss_on_right_side else right_start_point.global_position)
	horizontal_speed = calculate_speed()
	windup_speed = abs((starting_point.x - boss.body.global_position.x) / windup_time)
	is_windup_done = false

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	prison_guard.check_player_collision()
	if (!is_windup_done and boss.body.global_position.x != starting_point.x):
		boss.sprite.play("Phase4WindupLookUp" if !boss.player_hub.char_body.is_on_floor() else "Phase4Windup")
		boss.body.global_position.x = move_toward(boss.body.global_position.x, starting_point.x, _delta * windup_speed)
	elif (boss.visibility.is_on_screen()):
		if (!is_windup_done):
			is_windup_done = true
			midpoint = (high_midpoint.global_position if !boss.player_hub.char_body.is_on_floor() else low_midpoint.global_position)
			boss.sprite.play("Phase4Attack")
		boss.body.global_position.x += (_delta * horizontal_speed)
		boss.body.global_position.y = calculate_vertical_position()
		check_boss_side()
	else:
		set_next_state(phase_idle_state)

func calculate_vertical_position():
	var distance_to_midpoint : float = abs(boss.body.global_position.x - midpoint.x)
	var distance_factor : float = abs(distance_to_midpoint / (starting_point.x - midpoint.x))
	distance_factor *= distance_factor
	distance_factor = (1.0 - distance_factor)
	var ret_val = (((midpoint.y - starting_point.y) * distance_factor) + starting_point.y)
	return ret_val

func calculate_speed():
	return ((ending_point.x - starting_point.x) / attack_time)

func check_boss_side():
	prison_guard.is_boss_on_right_side = (boss.body.global_position.x > prison_guard.room_side_trigger.global_position.x)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
