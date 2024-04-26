extends BossState

@export var left_start_point : Node2D

@export var right_start_point : Node2D

@export var travel_time : float = 1

@export var phase_attack_state : BossState

var prison_guard : PrisonGuardBoss

var target_point : Vector2

var travel_speed : float = 0

func on_enter():
	check_prison_guard_ref()
	check_boss_side()
	boss.body.velocity = Vector2.ZERO
	boss.sprite.flip_h = prison_guard.is_boss_on_right_side
	boss.body.global_position.x = (right_start_point.global_position.x if prison_guard.is_boss_on_right_side else left_start_point.global_position.x)
	target_point = (right_start_point.global_position if prison_guard.is_boss_on_right_side else left_start_point.global_position)
	travel_speed = (boss.body.global_position.distance_to(target_point) / travel_time)

func state_process(_delta):
	if (boss.global_position != target_point):
		boss.body.velocity = Vector2.ZERO
		boss.body.global_position.x = move_toward(boss.global_position.x, target_point.x, travel_speed * _delta)
		boss.body.global_position.y = move_toward(boss.global_position.y, target_point.y, travel_speed * _delta)
	else:
		set_next_state(phase_attack_state)

func check_boss_side():
	prison_guard.is_boss_on_right_side = (boss.body.global_position.x > prison_guard.room_side_trigger.global_position.x)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
