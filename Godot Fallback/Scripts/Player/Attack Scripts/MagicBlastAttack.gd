extends Attack

class_name MagicBlastAttack

@export var projectile_scene : PackedScene

@export var knockback_effect_radius : float = 1.8

@export var knockback_strength : float = 10

@export var inertia_multiplier : float = 0.9

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

var pixels_per_unit : float = 32

func can_use_attack():
	return (hub.form.current_mode == PlayerForm.CharacterMode.MAGE)

func use_attack():
	if (projectile_instance == null):
		projectile_instance = projectile_scene.instantiate()
		add_child(projectile_instance)
		
		var vertical_axis = hub.get_input_vector().y
		var throw_offset = (forward_throw_offset if vertical_axis == 0 else lob_throw_offset if vertical_axis > 0 else drop_throw_offset)
		
		var throw_direction : Vector2 = Vector2.from_angle(deg_to_rad(forward_throw_angle if vertical_axis == 0 else lob_throw_angle if vertical_axis > 0 else drop_throw_angle))
		throw_direction.x *= hub.movement.get_facing_value()
		
		var throw_strength = (forward_throw_strength if vertical_axis == 0 else lob_throw_strength if vertical_axis > 0 else drop_throw_strength)
		
		var throw_inertia : Vector2 = (Vector2.RIGHT * hub.movement.current_horizontal_velocity * inertia_multiplier)
		
		var throw_rotation : float = (forward_throw_rotation if vertical_axis == 0 else lob_throw_rotation if vertical_axis > 0 else drop_throw_rotation)
		
		var projectile_velocity : Vector2 = ((throw_direction * throw_strength) + throw_inertia)
		
		(projectile_instance as Node2D).global_position = (hub.char_body.position + throw_offset)
		
		var projectile_rb = (projectile_instance as RigidBody2D)
		projectile_rb.linear_velocity = projectile_velocity
		projectile_rb.apply_torque_impulse(throw_rotation * hub.movement.get_facing_value())
	else:
		var projectile_node : Node2D = (projectile_instance as Node2D)
		var distance_to_projectile : float = (hub.collision_shape.global_position.distance_to(projectile_node.global_position))
		var state_name : String = hub.state_machine.current_state.name
		
		if (distance_to_projectile <= knockback_effect_radius and state_name != "Standing" and state_name != "WallSliding" and state_name != "Attacking" and state_name != "FormChanging"):
			var launch_direction : Vector2 = projectile_node.global_position.direction_to(hub.collision_shape.global_position)
			var launch_power : float = (knockback_strength / (1 + (distance_to_projectile / pixels_per_unit)))
			var launch_velocity = (launch_direction * launch_power)
			if (hub.char_body.is_on_floor() or state_name == "Gliding"):
				launch_velocity.y = 0
			hub.char_body.velocity += launch_velocity
			hub.movement.current_horizontal_velocity = hub.char_body.velocity.x
		
		projectile_instance.queue_free()
	
	hub.attacks.set_attack_cooldown_timer()
