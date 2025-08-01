extends BossState

@export var impostor_boss : ImpostorBoss

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
	
	if (impostor_boss.current_health <= 0):
		set_next_state(defeat_state)
	elif (impostor_boss.current_health <= 3):
		set_next_state(knigel_phase3_state)
	elif (impostor_boss.current_health <= 6):
		set_next_state(knigel_phase2_state)
	else:
		pass
