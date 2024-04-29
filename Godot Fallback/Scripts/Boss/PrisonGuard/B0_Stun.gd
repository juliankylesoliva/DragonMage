extends BossState

@export var switch_sides_state : BossState

@export var initial_vertical_launch : float = 128

@export var knockback_vertical_launch : float = 64

@export var minimum_horizontal_knockback : float = 64

@export var horizontal_knockback_factor : float = 0.5

@export var knockback_gravity_scale : float = 3

func on_enter():
	boss.set_gravity_scale(knockback_gravity_scale)
	boss.is_knockback_enabled = true
	boss.body.velocity = (Vector2.UP * initial_vertical_launch)

func state_process(_delta):
	boss.body.move_and_slide()
	boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
	if (boss.body.is_on_floor()):
		boss.body.velocity.x = 0

func on_exit():
	boss.is_knockback_enabled = false
	boss.body.velocity = Vector2.ZERO

func apply_knockback(horizontal_knockback_strength : float, horizontal_knockback_direction : float):
	if (boss.is_knockback_enabled and boss.body.is_on_floor()):
		boss.body.velocity = Vector2(horizontal_knockback_direction * abs(min(horizontal_knockback_strength, minimum_horizontal_knockback)), -knockback_vertical_launch)
