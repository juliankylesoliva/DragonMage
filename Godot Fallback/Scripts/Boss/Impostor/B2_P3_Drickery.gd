extends BossState

@export var impostor_boss : ImpostorBoss

@export var damaged_state : BossState

@export var expected_health : int = 1

func on_enter():
	impostor_boss.can_be_stomped = true
	impostor_boss.sprite.play("DrickeryIdle")

func state_process(_delta):
	impostor_boss.check_player_collision()
	if (impostor_boss.current_health < expected_health):
		set_next_state(damaged_state)
