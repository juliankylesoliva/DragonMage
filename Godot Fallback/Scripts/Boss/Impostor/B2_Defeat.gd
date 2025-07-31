extends BossState

@export var impostor_boss : ImpostorBoss

func on_enter():
	impostor_boss.can_be_stomped = false
	impostor_boss.sprite.play("DrickeryIdle")
