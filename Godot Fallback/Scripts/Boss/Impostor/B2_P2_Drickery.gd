extends BossState

enum PhaseState {TRAVEL, AIM, FIRE}

@export var impostor_boss : ImpostorBoss

@export var move_speed : float = 128

@export var cooldown_duration : float = 3

@export var attack_distance : float = 160

@export var aiming_duration : float = 0.5

@export var firing_end_duration : float = 1

@export_range(0, 1) var partial_invis_alpha : float = 0.15

@export var damaged_state : BossState

@export var minimum_health : int = 4

var current_phase_state : PhaseState = PhaseState.TRAVEL

var current_phase_state_timer : float = 0

var travel_direction : float = 1

var aim_direction : Vector2 = Vector2.ZERO

func on_enter():
	impostor_boss.can_be_stomped = true
	impostor_boss.sprite.play("DrickeryIdle")

func state_process(_delta):
	phase_state_process(_delta)
	if (impostor_boss.current_health < minimum_health):
		set_next_state(damaged_state)

func init_phase_state(phase : PhaseState):
	current_phase_state = phase
	match current_phase_state:
		PhaseState.TRAVEL:
			impostor_boss.body.velocity = Vector2.ZERO
			impostor_boss.is_invisible = true
			impostor_boss.can_be_stomped = false
			impostor_boss.sprite.modulate.a = 0.0
			travel_direction = -get_direction_to_player()
			current_phase_state_timer = cooldown_duration
		PhaseState.AIM:
			impostor_boss.body.velocity = Vector2.ZERO
			impostor_boss.sprite.flip_h = (get_direction_to_player() < 0)
			current_phase_state_timer = aiming_duration
			impostor_boss.sprite.modulate.a = 0.0
		PhaseState.FIRE:
			impostor_boss.is_invisible = false
			impostor_boss.can_be_stomped = true
			current_phase_state_timer = firing_end_duration
			impostor_boss.sprite.modulate.a = 1.0
			impostor_boss.spawn_fire_bullet(aim_direction)

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.TRAVEL:
			do_travel_state(_delta)
		PhaseState.AIM:
			do_aim_state(_delta)
		PhaseState.FIRE:
			do_fire_state(_delta)

func do_travel_state(_delta):
	impostor_boss.sprite.modulate.a = (partial_invis_alpha if impostor_boss.is_player_in_collider else 0.0)
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0 and is_far_from_player()):
		init_phase_state(PhaseState.AIM)
	else:
		impostor_boss.body.velocity.x = (abs(move_speed) * travel_direction)
		impostor_boss.sprite.flip_h = (impostor_boss.body.velocity.x < 0)
		impostor_boss.body.move_and_slide()
		if (impostor_boss.body.is_on_wall()):
			travel_direction *= -1

func do_aim_state(_delta):
	impostor_boss.sprite.modulate.a = partial_invis_alpha
	impostor_boss.sprite.flip_h = (get_direction_to_player() < 0)
	aim_direction = (impostor_boss.player_hub.raycast_wall_top_l.global_position - impostor_boss.global_position).normalized()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.FIRE)

func do_fire_state(_delta):
	impostor_boss.check_player_collision()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.TRAVEL)

func get_distance_to_player():
	return abs(impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)

func get_direction_to_player():
	var diff : float = (impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)
	return (1.0 if diff >= 0 else -1.0)

func is_far_from_player():
	return (get_distance_to_player() >= attack_distance)
