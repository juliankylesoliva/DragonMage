extends BossState

@export var move_speed : float = 320

@export var left_ground_node : Node2D

@export var right_ground_node : Node2D

@export var phase_one_state : BossState

@export var phase_two_state : BossState

@export var phase_three_state : BossState

@export var phase_four_state : BossState

@export var defeat_state : BossState

var prison_guard : PrisonGuardBoss

func on_enter():
	check_prison_guard_ref()
	check_boss_side()
	boss.body.velocity = (Vector2.UP * move_speed)

func state_process(_delta):
	boss.body.move_and_slide()
	if (boss.body.velocity.y < 0 and !boss.visibility.is_on_screen()):
		boss.body.global_position.x = (left_ground_node.global_position.x if prison_guard.is_player_on_right_side else right_ground_node.global_position.x)
		boss.body.velocity = (Vector2.DOWN * move_speed)
		prison_guard.is_boss_on_right_side = !prison_guard.is_player_on_right_side
		boss.sprite.flip_h = prison_guard.is_boss_on_right_side
	elif (boss.body.is_on_floor()):
		match boss.current_health:
			4:
				set_next_state(phase_one_state)
			3:
				set_next_state(phase_two_state)
			2:
				set_next_state(phase_three_state)
			1:
				set_next_state(phase_four_state)
			0:
				set_next_state(defeat_state)
	else:
		pass

func check_boss_side():
	prison_guard.is_boss_on_right_side = (boss.body.global_position.x > prison_guard.room_side_trigger.global_position.x)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
