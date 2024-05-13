extends BossState

@export var phase_idle_state : BossState

@export var stun_state : BossState

@export var move_speed : float = 224

@export var attack_time : float = 1

@export var jump_time_threshold : float = 0.75

@export var player_jump_height_threshold : float = 96

@export var jump_speed : float = 384

@export var jumping_gravity_scale : float = 2

@export var falling_gravity_scale : float = 3

var prison_guard : PrisonGuardBoss

var attack_time_left : float = 0

var current_move_direction : float = -1

var is_jumping : bool = false

var did_jump : bool = false

func on_enter():
	check_prison_guard_ref()
	attack_time_left = attack_time
	current_move_direction = (-1 if prison_guard.is_boss_on_right_side else 1)
	is_jumping = check_if_jumping()
	did_jump = false

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	prison_guard.check_player_collision()
	boss.body.velocity.x = (current_move_direction * move_speed)
	boss.sprite.play("Phase2JumpAttack" if !boss.body.is_on_floor() else "Phase2Attack")
	if (is_jumping and !did_jump and attack_time_left <= jump_time_threshold):
		did_jump = true
		SoundFactory.play_sound_by_name("enemy_dragoon_jump", boss.global_position, 0, 1, "SFX")
		boss.body.velocity += (Vector2.UP * jump_speed)
		boss.set_gravity_scale(jumping_gravity_scale)
	else:
		boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
		if (boss.body.velocity.y >= 0):
			boss.set_gravity_scale(falling_gravity_scale)
	boss.body.move_and_slide()
	attack_time_left = move_toward(attack_time_left, 0, _delta)
	if (attack_time_left <= 0):
		set_next_state(phase_idle_state)

func on_exit():
	boss.body.velocity = Vector2.ZERO
	prison_guard.is_boss_on_right_side = !prison_guard.is_boss_on_right_side

func check_if_jumping():
	return (!boss.player_hub.char_body.is_on_floor() and abs(boss.player_hub.char_body.global_position.y - boss.body.global_position.y) >= player_jump_height_threshold and is_facing_player())

func is_facing_player():
	if (boss.sprite.flip_h):
		return ((boss.player_hub.char_body.global_position.x - boss.body.global_position.x) < 0)
	else:
		return ((boss.player_hub.char_body.global_position.x - boss.body.global_position.x) > 0)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
