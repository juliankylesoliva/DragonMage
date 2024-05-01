extends BossState

@export var switch_sides_state : BossState

@export var initial_vertical_launch : float = 128

@export var knockback_vertical_launch : float = 64

@export var minimum_horizontal_knockback : float = 64

@export var horizontal_knockback_factor : float = 0.5

@export var knockback_gravity_scale : float = 3

var prison_guard : PrisonGuardBoss

func on_enter():
	check_prison_guard_ref()
	check_boss_side()
	boss.set_gravity_scale(knockback_gravity_scale)
	boss.is_knockback_enabled = true
	boss.body.velocity = (Vector2.UP * initial_vertical_launch)

func state_process(_delta):
	if (prison_guard.current_spike_reference != null and (prison_guard.current_spike_reference == prison_guard.floor_spikes_l or prison_guard.current_spike_reference == prison_guard.floor_spikes_r)):
		if (prison_guard.current_spike_reference.are_spikes_active()):
			boss.current_health -= 1
			boss.current_armor = boss.armor
			prison_guard.unset_current_spike_reference()
			boss.do_post_damage_invulnerability()
			set_next_state(switch_sides_state)
			return
		else:
			prison_guard.current_spike_reference.force_activate()
	
	boss.body.move_and_slide()
	boss.body.velocity += (Vector2.DOWN * boss.get_gravity_delta(_delta))
	if (boss.body.is_on_floor()):
		boss.body.velocity.x = 0

func on_exit():
	boss.is_knockback_enabled = false
	boss.body.velocity = Vector2.ZERO

func apply_knockback(horizontal_knockback_strength : float, horizontal_knockback_direction : float):
	if (boss.is_knockback_enabled and boss.body.is_on_floor()):
		boss.body.velocity = Vector2(horizontal_knockback_direction * abs(max(horizontal_knockback_strength, minimum_horizontal_knockback)), -knockback_vertical_launch)
		boss.sprite.flip_h = (boss.body.velocity.x >= 0)

func check_boss_side():
	prison_guard.is_boss_on_right_side = (boss.body.global_position.x > prison_guard.room_side_trigger.global_position.x)

func check_prison_guard_ref():
	if (prison_guard == null and boss != null and (boss is PrisonGuardBoss)):
		prison_guard = (boss as PrisonGuardBoss)
