extends BossState

@export var upper_left_node : Node2D

@export var upper_right_node : Node2D

@export var max_move_speed : float = 96

@export var turning_speed : float = 128

@export var rising_speed_multiplier : float = 2

@export var min_rising_speed : float = 16

@export var player_detection_radius : float = 32

@export var min_time_between_attacks : float = 1

@export var phase_attack_state : BossState

@export var stun_state : BossState

var prison_guard : PrisonGuardBoss

var current_move_direction : float = 1

var current_move_speed : float = 0

var current_attack_cooldown_time : float = 0

func on_enter():
	check_prison_guard_ref()
	prison_guard.update_weakness_and_defense()
	check_boss_side()
	current_move_speed = 0
	current_move_direction = (-1 if (boss.player_hub.char_body.global_position.x < boss.body.global_position.x) else 1)
	boss.sprite.flip_h = (current_move_direction < 0)
	current_attack_cooldown_time = min_time_between_attacks

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	check_boss_side()
	if (boss.global_position.y > upper_left_node.global_position.y):
		boss.body.velocity = Vector2.ZERO
		boss.global_position.y = move_toward(boss.global_position.y, upper_left_node.global_position.y, _delta * max(min_rising_speed, abs(boss.global_position.y - upper_left_node.global_position.y) * rising_speed_multiplier))
	else:
		boss.sprite.flip_h = (current_move_direction < 0)
		current_move_speed = move_toward(current_move_speed, current_move_direction * max_move_speed, turning_speed * _delta)
		boss.body.velocity = (Vector2.RIGHT * current_move_speed)
		boss.body.move_and_slide()
		if ((current_move_direction > 0 and boss.body.global_position.x > upper_right_node.global_position.x) or (current_move_direction < 0 and boss.global_position.x < upper_left_node.global_position.x)):
			current_move_direction *= -1
		
		if (current_attack_cooldown_time > 0):
			current_attack_cooldown_time = move_toward(current_attack_cooldown_time, 0, _delta)
		else:
			if (is_player_down_below()):
				set_next_state(phase_attack_state)

func check_boss_side():
	prison_guard.is_boss_on_right_side = (boss.body.global_position.x > prison_guard.room_side_trigger.global_position.x)

func is_player_down_below():
	var player_x : float = boss.player_hub.char_body.global_position.x
	var player_y : float = boss.player_hub.char_body.global_position.y
	var boss_x : float = boss.body.global_position.x
	var boss_y : float = boss.body.global_position.y
	return (player_y > boss_y and player_x >= (boss_x - player_detection_radius) and player_x <= (boss_x + player_detection_radius))

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
