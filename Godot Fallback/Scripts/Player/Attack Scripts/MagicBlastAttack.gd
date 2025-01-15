extends Attack

class_name MagicBlastAttack

signal magic_blast_thrown

@export var affect_source_player_only : bool = false

@export var blast_jump_particles : CPUParticles2D

@export var projectile_trail : LineTrail

@export var guide_arrows : Sprite2D

@export var projectile_scene : PackedScene

@export var blast_jump_hitbox_scene : PackedScene

@export var magic_blast_hit_magic_gain : float = 2

@export var blast_jump_hit_magic_gain : float = 3

@export var magic_blast_hit_temper_reduction : int = -1

@export var blast_jump_hit_temper_reduction : int = -2

@export var blast_jump_start_temper_increase : int = 1

@export var blast_jump_continuous_temper_increase : int = 1

@export var inertia_multiplier : float = 0.9

@export var projectile_despawn_distance : float = 20

@export var blast_jump_max_fall_speed : float = 20

@export var blast_jump_min_active_time : float = 0.25

@export var blast_jump_temper_increase_interval : float = 0.5

@export var blast_jump_max_velocity_magnitude_offset : float = 24

@export_color_no_alpha var blast_jump_active_color : Color

@export var blast_jump_guide_distance : float = 36

@export var blast_jump_max_guide_distance : float = 57.6

@export var blast_jump_guide_arrow_offset : float = 32

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

var blast_jump_hitbox_instance : Node = null

var is_blast_jumping : bool = false

var blast_jump_current_active_time : float = 0

var blast_jump_current_temper_interval_time : float = 0

func _process(delta):
	check_despawn_distance()
	update_blast_jump_guide()
	blast_jump_update(delta)

func can_use_attack():
	return (hub.form.is_a_mage())

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
		throw_offset.x *= (-1 if hub.state_machine.current_state.name == "WallSliding" else 1)
		
		var throw_direction : Vector2 = Vector2.from_angle(deg_to_rad(forward_throw_angle if vertical_axis == 0 else lob_throw_angle if vertical_axis > 0 else drop_throw_angle))
		throw_direction.x *= hub.movement.get_facing_value()
		throw_direction.x *= (-1 if hub.state_machine.current_state.name == "WallSliding" else 1)
		
		var throw_strength = (forward_throw_strength if vertical_axis == 0 else lob_throw_strength if vertical_axis > 0 else drop_throw_strength)
		
		var throw_inertia : Vector2 = (Vector2.RIGHT * hub.movement.current_horizontal_velocity * inertia_multiplier)
		
		var throw_rotation : float = (forward_throw_rotation if vertical_axis == 0 else lob_throw_rotation if vertical_axis > 0 else drop_throw_rotation)
		
		var projectile_velocity : Vector2 = ((throw_direction * throw_strength) + throw_inertia)
		
		(projectile_instance as Node2D).global_position = (hub.char_body.position + throw_offset)
		
		projectile_trail.set_node_to_follow(projectile_instance)
		
		var projectile_rb = (projectile_instance as RigidBody2D)
		projectile_rb.linear_velocity = projectile_velocity
		projectile_rb.apply_torque_impulse(throw_rotation * hub.movement.get_facing_value())
		
		(projectile_instance as MagicBlastProjectile).attack_ref = self
		
		if (affect_source_player_only):
			(projectile_instance as MagicBlastProjectile).set_source_rid(hub.char_body.get_rid())
		
		magic_blast_thrown.emit()

func check_despawn_distance():
	if (projectile_instance != null):
		if (hub.force_stand or hub.char_body.global_position.distance_to((projectile_instance as Node2D).global_position) > projectile_despawn_distance):
			destroy_projectile()

func destroy_projectile():
	if (projectile_instance != null):
		projectile_instance.queue_free()

func do_detonation():
	if (projectile_instance != null):
		var projectile_script = (projectile_instance as MagicBlastProjectile)
		projectile_script.detonate()

func update_blast_jump_guide():
	if (projectile_instance != null):
		var vec : Vector2 = (hub.char_body.global_position - (projectile_instance as Node2D).global_position)
		var distance : float = vec.length()
		if (distance <= blast_jump_max_guide_distance):
			guide_arrows.set_visible(true)
			var normalized_vec : Vector2 = vec.normalized()
			guide_arrows.global_position = (hub.char_body.global_position + (blast_jump_guide_arrow_offset * normalized_vec))
			guide_arrows.rotation = Vector2.UP.angle_to(normalized_vec)
			var lerp_val : float = min(1.0, (1.0 - inverse_lerp(blast_jump_guide_distance, blast_jump_max_guide_distance, distance)))
			guide_arrows.scale.x = 1
			guide_arrows.scale.y = lerp_val
		else:
			guide_arrows.set_visible(false)
	else:
		guide_arrows.set_visible(false)

func activate_blast_jump():
	SoundFactory.play_sound_by_name("attack_magli_blastjump", hub.char_body.global_position, 0, 1, "SFX")
	is_blast_jumping = true
	blast_jump_particles.emitting = true
	hub.char_sprite.modulate = blast_jump_active_color
	hub.sprite_trail.activate_trail()
	if (!hub.temper.is_form_locked()):
		hub.temper.neutralize_temper_by(blast_jump_start_temper_increase)
	blast_jump_current_active_time = blast_jump_min_active_time
	blast_jump_current_temper_interval_time = blast_jump_temper_increase_interval

func blast_jump_update(delta : float):
	if (is_blast_jumping):
		var state_name : String = hub.state_machine.current_state.name
		var normalized_velocity : Vector2 = hub.char_body.velocity.normalized()
		var velocity_offset : float = min(hub.char_body.velocity.length(), blast_jump_max_velocity_magnitude_offset)
		
		var velocity_temp = -hub.char_body.velocity.normalized()
		blast_jump_particles.direction = Vector2(velocity_temp.x, velocity_temp.y)
		
		if (blast_jump_hitbox_instance == null):
			blast_jump_hitbox_instance = blast_jump_hitbox_scene.instantiate()
			add_child(blast_jump_hitbox_instance)
			(blast_jump_hitbox_instance as KnockbackHitbox).hit.connect(_on_blast_jump_hit)
			(blast_jump_hitbox_instance as BlastJumpKnockbackHitbox).player_body = hub.char_body
		
		(blast_jump_hitbox_instance as Node2D).global_position = (hub.collision_shape.global_position + (normalized_velocity * velocity_offset))
		
		if (hub.damage.is_player_defeated or hub.damage.is_player_damaged() or blast_jump_current_active_time <= 0 or hub.state_machine.current_state.name == "FormChanging"):
			if (((!hub.buffers.is_speed_preservation_buffer_active() or hub.movement.is_crouching or hub.movement.is_turning()) and hub.char_body.is_on_floor()) or state_name == "Damaged" or state_name == "FormChanging" or state_name == "Gliding" or state_name == "WallSliding" or state_name == "Deactivated" or hub.attacks.get_attack_by_name("Dodge").current_attack_state == AttackState.ACTIVE or hub.form.current_mode != PlayerForm.CharacterMode.MAGE):
				is_blast_jumping = false
				blast_jump_particles.emitting = false
				if (hub.attacks.get_attack_by_name("Dodge").current_attack_state == AttackState.NOTHING):
					hub.sprite_trail.deactivate_trail()
				blast_jump_hitbox_instance.queue_free()
				hub.char_sprite.modulate = Color.WHITE
		else:
			blast_jump_current_active_time = move_toward(blast_jump_current_active_time, 0, delta)
			if (blast_jump_current_active_time <= 0 or hub.state_machine.current_state.name == "FormChanging"):
				blast_jump_current_active_time = 0
		
		if (!hub.temper.is_form_locked() and blast_jump_current_temper_interval_time > 0):
			blast_jump_current_temper_interval_time -= delta
			if (blast_jump_current_temper_interval_time <= 0):
				hub.temper.neutralize_temper_by(blast_jump_continuous_temper_increase)
				blast_jump_current_temper_interval_time += blast_jump_temper_increase_interval

func _on_magic_blast_hit():
	hub.fairy.change_current_magic_by(magic_blast_hit_magic_gain)
	if (hub.temper.is_form_locked()):
		hub.temper.neutralize_temper_by(-magic_blast_hit_temper_reduction)
	else:
		hub.temper.neutralize_temper_by(magic_blast_hit_temper_reduction)

func _on_blast_jump_hit():
	hub.fairy.change_current_magic_by(blast_jump_hit_magic_gain)
	if (hub.temper.is_form_locked()):
		hub.temper.neutralize_temper_by(-blast_jump_hit_temper_reduction)
	else:
		hub.temper.neutralize_temper_by(blast_jump_hit_temper_reduction)
