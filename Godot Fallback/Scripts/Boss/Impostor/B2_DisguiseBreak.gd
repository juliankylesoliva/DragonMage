extends BossState

@export var impostor_boss : ImpostorBoss

@export var falling_gravity : float = 3

@export var drickery_phase0_state : BossState

@export var drickery_phase1_state : BossState

@export var drickery_phase2_state : BossState

@export var drickery_phase3_state : BossState

@export var defeat_state : BossState

@export var break_duration : float = 1.0

var current_break_timer : float = 0

func on_enter():
	impostor_boss.set_gravity_scale(falling_gravity)
	impostor_boss.can_be_stomped = false
	impostor_boss.can_reflect_projectiles = false
	impostor_boss.sprite.play("DrickeryIdle")
	current_break_timer = break_duration

func state_process(_delta):
	if (!impostor_boss.body.is_on_floor()):
		impostor_boss.body.velocity += (Vector2.DOWN * impostor_boss.get_gravity_delta(_delta))
		impostor_boss.body.move_and_slide()
		return
	
	current_break_timer = move_toward(current_break_timer, 0, _delta)
	if (current_break_timer > 0):
		return
	
	if (impostor_boss.current_armor > 0):
		set_next_state(drickery_phase0_state)
		return
	
	if (impostor_boss.current_health >= 7):
		set_next_state(drickery_phase1_state)
	elif (impostor_boss.current_health >= 4):
		set_next_state(drickery_phase2_state)
	elif (impostor_boss.current_health >= 1):
		set_next_state(drickery_phase3_state)
	else:
		set_next_state(defeat_state)
