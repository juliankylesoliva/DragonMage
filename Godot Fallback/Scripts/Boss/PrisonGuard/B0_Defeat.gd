extends BossState

func on_enter():
	boss.on_defeat()
	boss.sprite.play("DefeatIdle")
