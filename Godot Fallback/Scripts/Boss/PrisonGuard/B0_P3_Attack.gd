extends BossState

@export var phase_idle_state : BossState

@export var stun_state : BossState

@export var windup_time : float = 0.5

@export var endlag_time : float = 0.5

var current_windup_time : float = 0

var current_endlag_time : float = 0

func on_enter():
	boss.body.velocity = Vector2.ZERO
	current_windup_time = windup_time
	current_endlag_time = endlag_time

func state_process(_delta):
	if (boss.current_armor <= 0):
		set_next_state(stun_state)
		return
	
	if (current_windup_time > 0):
		current_windup_time = move_toward(current_windup_time, 0, _delta)
		if (current_windup_time <= 0):
			fire_projectile()
	elif (current_endlag_time > 0):
		current_endlag_time = move_toward(current_endlag_time, 0, _delta)
	else:
		set_next_state(phase_idle_state)

func fire_projectile():
	print_debug("Fired Projectile!")
	# spawn bouncing fireball projectile
