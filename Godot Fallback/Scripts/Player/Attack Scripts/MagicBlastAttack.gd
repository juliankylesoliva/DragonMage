extends Attack

class_name MagicBlastAttack

@export var projectile_scene : PackedScene

@export var inertia_multiplier : float = 0.9

@export var projectile_despawn_distance : float = 20

@export var blast_jump_min_velocity_magnitude : float = 6

@export var blast_jump_max_fall_speed : float = 20

@export var blast_jump_min_active_time : float = 0.25

@export var blast_jump_temper_increase_interval : float = 0.5

@export_color_no_alpha var blast_jump_active_color : Color

@export_group("Throw Velocities")
@export var forward_throw_strength : float = 5
@export var lob_throw_strength : float = 5
@export var drop_throw_strength : float = 5

@export_group("Throw Offsets")
@export var forward_throw_offset : Vector2 = Vector2.ZERO
@export var lob_throw_offset : Vector2 = Vector2.ZERO
@export var drop_throw_offset : Vector2 = Vector2.ZERO

@export_group("Throw Angles")
@export var forward_throw_angle : float = 0
@export var lob_throw_angle : float = 0
@export var drop_throw_angle : float = 0

@export_group("Throw Rotations")
@export var forward_throw_rotation : float = 10
@export var lob_throw_rotation : float = 20
@export var drop_throw_rotation : float = -10

var projectile_instance : Node = null

var is_blast_jumping : bool = false

var blast_jump_current_active_time : float = 0

var blast_jump_current_temper_interval_time : float = 0

func _process(delta):
	blast_jump_update(delta)

func can_use_attack():
	return (hub.form.current_mode == PlayerForm.CharacterMode.MAGE)

func use_attack():
	if (projectile_instance == null):
		throw_projectile()
	else:
		do_detonation()
	
	hub.attacks.set_attack_cooldown_timer()

func throw_projectile():
	if (projectile_instance == null):
		projectile_instance = projectile_scene.instantiate()
		add_sibling(projectile_instance)
		
		var vertical_axis = hub.get_input_vector().y
		var throw_offset = (forward_throw_offset if vertical_axis == 0 else lob_throw_offset if vertical_axis > 0 else drop_throw_offset)
		throw_offset.x *= hub.movement.get_facing_value()
		
		var throw_direction : Vector2 = Vector2.from_angle(deg_to_rad(forward_throw_angle if vertical_axis == 0 else lob_throw_angle if vertical_axis > 0 else drop_throw_angle))
		throw_direction.x *= hub.movement.get_facing_value()
		throw_direction.x *= (-1 if hub.state_machine.current_state.name == "WallSliding" else 1)
		
		var throw_strength = (forward_throw_strength if vertical_axis == 0 else lob_throw_strength if vertical_axis > 0 else drop_throw_strength)
		
		var throw_inertia : Vector2 = (Vector2.RIGHT * hub.movement.current_horizontal_velocity * inertia_multiplier)
		
		var throw_rotation : float = (forward_throw_rotation if vertical_axis == 0 else lob_throw_rotation if vertical_axis > 0 else drop_throw_rotation)
		
		var projectile_velocity : Vector2 = ((throw_direction * throw_strength) + throw_inertia)
		
		(projectile_instance as Node2D).global_position = (hub.char_body.position + throw_offset)
		
		var projectile_rb = (projectile_instance as RigidBody2D)
		projectile_rb.linear_velocity = projectile_velocity
		projectile_rb.apply_torque_impulse(throw_rotation * hub.movement.get_facing_value())

func do_detonation():
	if (projectile_instance != null):
		var projectile_script = (projectile_instance as MagicBlastProjectile)
		projectile_script.detonate()

func activate_blast_jump():
	is_blast_jumping = true
	hub.char_sprite.modulate = blast_jump_active_color
	blast_jump_current_active_time = blast_jump_min_active_time
	blast_jump_current_temper_interval_time = blast_jump_temper_increase_interval

func blast_jump_update(delta : float):
	if (is_blast_jumping):
		var state_name : String = hub.state_machine.current_state.name
		if (blast_jump_current_active_time <= 0 or hub.state_machine.current_state.name == "FormChanging"):
			if (hub.char_body.velocity.length() < blast_jump_min_velocity_magnitude or hub.char_body.is_on_floor() or state_name == "FormChanging" or state_name == "Gliding" or hub.form.current_mode != PlayerForm.CharacterMode.MAGE):
				is_blast_jumping = false
				hub.char_sprite.modulate = Color.WHITE
		else:
			blast_jump_current_active_time = move_toward(blast_jump_current_active_time, 0, delta)
			if (blast_jump_current_active_time <= 0 or hub.state_machine.current_state.name == "FormChanging"):
				blast_jump_current_active_time = 0
		
		if (blast_jump_current_temper_interval_time > 0):
			blast_jump_current_temper_interval_time -= delta
			if (blast_jump_current_temper_interval_time <= 0):
				blast_jump_current_temper_interval_time += blast_jump_temper_increase_interval