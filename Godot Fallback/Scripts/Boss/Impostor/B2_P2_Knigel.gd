extends BossState

@export var impostor_boss : ImpostorBoss

@export var disguise_break_state : BossState

func on_enter():
	impostor_boss.can_be_stomped = false
	impostor_boss.sprite.play("ImpKnigelIdle")

func state_process(_delta):
	impostor_boss.check_player_collision()
	if (impostor_boss.current_armor <= 0):
		set_next_state(disguise_break_state)
