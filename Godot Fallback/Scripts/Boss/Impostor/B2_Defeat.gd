extends BossState

@export var impostor_boss : ImpostorBoss

func on_enter():
	impostor_boss.sprite.modulate.a = 1.0
	impostor_boss.can_be_stomped = false
	impostor_boss.fyerlarm_l.set_disable(true)
	impostor_boss.fyerlarm_r.set_disable(true)
	impostor_boss.sprite.play("DrickeryIdle")
