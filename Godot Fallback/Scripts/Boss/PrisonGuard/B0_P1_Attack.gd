extends BossState

@export var phase_idle_state : BossState

@export var stun_state : BossState

@export var jump_speed : float = 32

@export var jump_attack_cadence : int = 3

@export var jumping_gravity_scale : float = 2

@export var falling_gravity_scale : float = 3

@export var ground_time : float = 0.5

var prison_guard : PrisonGuardBoss

var current_attack_counter : int = 0

var is_jumping : bool = false

var did_fire_projectile : bool = false

var current_ground_time : float = 0

func on_enter():
	check_prison_guard_ref()
	current_ground_time = ground_time
	current_attack_counter += 1
	if (current_attack_counter >= jump_attack_cadence):
		is_jumping = true
		current_attack_counter = 0
		boss.body.velocity = (Vector2.UP * jump_speed)
		boss.set_gravity_scale(jumping_gravity_scale)

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	prison_guard.check_player_collision()
	if (is_jumping):
		if (!did_fire_projectile and boss.body.velocity.y >= 0 and !boss.body.is_on_floor()):
			do_fire_projectile()
		boss.body.move_and_slide()
		boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
		if (boss.body.velocity.y >= 0 and boss.current_gravity_scale != falling_gravity_scale):
			boss.set_gravity_scale(falling_gravity_scale)
		
		if (boss.body.is_on_floor()):
			is_jumping = false
	else:
		if (!did_fire_projectile and current_ground_time <= (ground_time / 2)):
			do_fire_projectile()
		current_ground_time = move_toward(current_ground_time, 0, _delta)
		if (current_ground_time <= 0):
			set_next_state(phase_idle_state)

func on_exit():
	did_fire_projectile = false

func do_fire_projectile():
	did_fire_projectile = true
	prison_guard.spawn_fireball()

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
