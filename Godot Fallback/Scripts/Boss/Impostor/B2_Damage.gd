extends BossState

@export var impostor_boss : ImpostorBoss

@export var knigel_phase1_state : BossState

@export var knigel_phase2_state : BossState

@export var knigel_phase3_state : BossState

@export var defeat_state : BossState

@export var damage_duration : float = 1.0

var current_damage_timer : float = 0

func on_enter():
	impostor_boss.can_be_stomped = false
	impostor_boss.can_reflect_projectiles = false
	impostor_boss.sprite.play("DrickeryIdle")
	current_damage_timer = damage_duration

func state_process(_delta):
	current_damage_timer = move_toward(current_damage_timer, 0, _delta)
	if (current_damage_timer > 0):
		return
	
	if (impostor_boss.current_health >= 7):
		set_next_state(knigel_phase1_state)
	elif (impostor_boss.current_health >= 4):
		set_next_state(knigel_phase2_state)
	elif (impostor_boss.current_health >= 1):
		set_next_state(knigel_phase3_state)
	else:
		set_next_state(defeat_state)
