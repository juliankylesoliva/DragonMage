extends BossState

enum PhaseState {RISE, FLY, WINDUP, THROW, DIVE}

@export var impostor_boss : ImpostorBoss

@export var flying_height_position : Node2D

@export var rising_speed : float = 64

@export var flying_speed : float = 128

@export var throw_attack_range : float = 4

@export var dive_attack_range : float = 128

@export var flying_cooldown_duration : float = 3

@export var windup_dive_backup_speed : float = 64

@export var windup_duration : float = 0.25

@export var throw_angle_separation : float = 30

@export var throw_duration : float = 0.5

@export var dive_speed : float = 512

@export_range(0, 1) var partial_invis_alpha : float = 0.15

@export var damaged_state : BossState

@export var minimum_health : int = 1

var next_attack_state : PhaseState = PhaseState.THROW

var current_flying_direction : float = 1

var current_dive_direction : Vector2 = Vector2.DOWN

var current_phase_state : PhaseState = PhaseState.RISE

var current_phase_state_timer : float = 0

func on_enter():
	next_attack_state = PhaseState.THROW
	init_phase_state(PhaseState.RISE)
	impostor_boss.fyerlarm_l.set_disable(true)
	impostor_boss.fyerlarm_r.set_disable(true)
	impostor_boss.sprite.play("DrickeryIdle")

func state_process(_delta):
	phase_state_process(_delta)
	if (impostor_boss.current_health < minimum_health):
		set_next_state(damaged_state)

func init_phase_state(phase : PhaseState):
	current_phase_state = phase
	match current_phase_state:
		PhaseState.RISE:
			impostor_boss.reset_post_damage_invulnerability()
			impostor_boss.body.velocity = (Vector2.UP * rising_speed)
			impostor_boss.is_invisible = true
			impostor_boss.can_be_stomped = false
			impostor_boss.sprite.modulate.a = partial_invis_alpha
		PhaseState.FLY:
			impostor_boss.reset_post_damage_invulnerability()
			current_flying_direction = -get_direction_to_player()
			current_phase_state_timer = flying_cooldown_duration
			impostor_boss.body.velocity = (Vector2.RIGHT * current_flying_direction * flying_speed)
			impostor_boss.is_invisible = true
			impostor_boss.can_be_stomped = false
			impostor_boss.sprite.modulate.a = 0.0
		PhaseState.WINDUP:
			current_phase_state_timer = windup_duration
			impostor_boss.body.velocity = Vector2.ZERO
			impostor_boss.is_invisible = true
			impostor_boss.can_be_stomped = false
			impostor_boss.sprite.modulate.a = partial_invis_alpha
		PhaseState.THROW:
			current_phase_state_timer = throw_duration
			impostor_boss.body.velocity = Vector2.ZERO
			impostor_boss.is_invisible = false
			impostor_boss.can_be_stomped = true
			impostor_boss.sprite.modulate.a = 1.0
			next_attack_state = PhaseState.DIVE
			impostor_boss.spawn_fire_bullet(Vector2.DOWN)
			impostor_boss.spawn_fire_bullet(Vector2.DOWN.rotated(deg_to_rad(throw_angle_separation)))
			impostor_boss.spawn_fire_bullet(Vector2.DOWN.rotated(deg_to_rad(-throw_angle_separation)))
		PhaseState.DIVE:
			current_dive_direction = (impostor_boss.player_hub.char_body.global_position - impostor_boss.body.global_position).normalized()
			impostor_boss.body.velocity = (current_dive_direction * dive_speed)
			impostor_boss.is_invisible = false
			impostor_boss.can_be_stomped = true
			impostor_boss.sprite.modulate.a = 1.0
			next_attack_state = PhaseState.THROW

func phase_state_process(_delta):
	match current_phase_state:
		PhaseState.RISE:
			do_rise_state(_delta)
		PhaseState.FLY:
			do_fly_state(_delta)
		PhaseState.WINDUP:
			do_windup_state(_delta)
		PhaseState.THROW:
			do_throw_state(_delta)
		PhaseState.DIVE:
			do_dive_state(_delta)

func do_rise_state(_delta):
	impostor_boss.sprite.modulate.a = partial_invis_alpha
	impostor_boss.body.move_and_slide()
	if (impostor_boss.body.global_position.y <= flying_height_position.global_position.y):
		impostor_boss.body.global_position.y = flying_height_position.global_position.y
		init_phase_state(PhaseState.FLY)

func do_fly_state(_delta):
	impostor_boss.sprite.modulate.a = (partial_invis_alpha if impostor_boss.is_player_in_collider else 0.0)
	if (impostor_boss.body.is_on_wall()):
		current_flying_direction *= -1
	impostor_boss.body.velocity = (Vector2.RIGHT * current_flying_direction * flying_speed)
	impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0 and is_near_player() and !is_player_attacking() and impostor_boss.player_hub.char_body.is_on_floor()):
		init_phase_state(PhaseState.WINDUP)

func do_windup_state(_delta):
	impostor_boss.sprite.modulate.a = partial_invis_alpha
	if (next_attack_state == PhaseState.DIVE):
		impostor_boss.body.velocity.y = (-windup_dive_backup_speed * (current_phase_state_timer / windup_duration))
		impostor_boss.body.move_and_slide()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(next_attack_state)

func do_throw_state(_delta):
	impostor_boss.check_player_collision()
	current_phase_state_timer = move_toward(current_phase_state_timer, 0, _delta)
	if (current_phase_state_timer <= 0):
		init_phase_state(PhaseState.FLY)

func do_dive_state(_delta):
	impostor_boss.check_player_collision()
	impostor_boss.body.velocity = (current_dive_direction * dive_speed)
	impostor_boss.body.move_and_slide()
	if (impostor_boss.body.is_on_floor() or impostor_boss.body.is_on_wall()):
		init_phase_state(PhaseState.RISE)

func get_distance_to_player():
	return abs(impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)

func get_direction_to_player():
	var diff : float = (impostor_boss.player_hub.char_body.global_position.x - impostor_boss.body.global_position.x)
	return (1.0 if diff >= 0 else -1.0)

func is_near_player():
	match next_attack_state:
		PhaseState.THROW:
			return get_distance_to_player() <= throw_attack_range
		PhaseState.DIVE:
			return get_distance_to_player() >= dive_attack_range
	return false

func is_player_attacking():
	var player_temp : PlayerHub = impostor_boss.player_hub
	var magic_blast_temp : MagicBlastAttack = player_temp.jumping.magic_blast_attack
	return (player_temp.state_machine.current_state.name == "Attacking" or magic_blast_temp.projectile_instance != null or magic_blast_temp.is_blast_jumping)
