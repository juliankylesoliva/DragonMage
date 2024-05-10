extends BossState

@export var move_speed : float = 32

@export var time_between_attacks : float = 1

@export var rest_duration : float = 0.5

@export var player_jump_height_threshold : float = 96

@export var phase_attack_state : BossState

@export var stun_state : BossState

var prison_guard : PrisonGuardBoss

var current_rest_timer : float = 0

var current_attack_timer : float = 0

var current_move_direction : float = -1

func on_enter():
	check_prison_guard_ref()
	check_boss_side()
	prison_guard.update_weakness_and_defense()
	current_rest_timer = rest_duration
	current_attack_timer = time_between_attacks
	current_move_direction = (1 if prison_guard.is_boss_on_right_side else -1)
	boss.sprite.flip_h = prison_guard.is_boss_on_right_side
	boss.sprite.play("Phase2WindupLookUp" if check_if_jumping() else "Phase2Windup")

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	boss.sprite.play("Phase2WindupLookUp" if check_if_jumping() else "Phase2Windup")
	prison_guard.check_player_collision()
	if (current_rest_timer > 0):
		current_rest_timer = move_toward(current_rest_timer, 0, _delta)
	else:
		boss.body.velocity.x = (current_move_direction * move_speed)
		current_attack_timer = move_toward(current_attack_timer, 0, _delta)
	boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
	boss.body.move_and_slide()
	if (current_attack_timer <= 0):
		set_next_state(phase_attack_state)

func check_if_jumping():
	return (!boss.player_hub.char_body.is_on_floor() and abs(boss.player_hub.char_body.global_position.y - boss.body.global_position.y) >= player_jump_height_threshold and is_facing_player())

func is_facing_player():
	if (boss.sprite.flip_h):
		return ((boss.player_hub.char_body.global_position.x - boss.body.global_position.x) < 0)
	else:
		return ((boss.player_hub.char_body.global_position.x - boss.body.global_position.x) > 0)

func check_boss_side():
	prison_guard.is_boss_on_right_side = (boss.body.global_position.x > prison_guard.room_side_trigger.global_position.x)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
