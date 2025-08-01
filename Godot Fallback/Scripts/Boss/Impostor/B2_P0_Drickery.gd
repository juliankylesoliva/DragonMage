extends BossState

@export var impostor_boss : ImpostorBoss

@export var knigel_phase1_state : BossState

func on_enter():
	impostor_boss.sprite.play("DrickeryIdle")
	impostor_boss.on_first_fyerlarm_hit()

func state_process(_delta):
	if (impostor_boss.second_intro_finished):
		set_next_state(knigel_phase1_state)
