extends BossState

@export var impostor_boss : ImpostorBoss

@export var drickery_phase0_state : BossState

@export var drickery_phase1_state : BossState

@export var drickery_phase2_state : BossState

@export var drickery_phase3_state : BossState

@export var break_duration : float = 1.0

var current_break_timer : float = 0

func on_enter():
	impostor_boss.can_be_stomped = false
	impostor_boss.sprite.play("DrickeryIdle")
	current_break_timer = break_duration

func state_process(_delta):
	current_break_timer = move_toward(current_break_timer, 0, _delta)
	if (current_break_timer > 0):
		return
	
	if (impostor_boss.current_armor > 0):
		set_next_state(drickery_phase0_state)
		return
	
	match impostor_boss.current_health:
		3:
			set_next_state(drickery_phase1_state)
		2:
			set_next_state(drickery_phase2_state)
		1:
			set_next_state(drickery_phase3_state)
		_:
			pass
