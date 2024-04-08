extends Node2D

class_name FairyFollow

@export var sprite : AnimatedSprite2D

@export var sigil_sprite : AnimatedSprite2D

@export var home_position_target : Node2D

@export var min_theta_change_rate : float = PI

@export var max_theta_change_rate : float = TAU

@export var min_sine_amplitude : float = 16

@export var max_sine_amplitude : float = 24

@export var min_rotation_shift : float = -PI

@export var max_rotation_shift : float = PI

@export var easing : float = 0.99

var default_home_position : Vector2 = Vector2.ZERO

var current_home_position : Vector2 = Vector2.ZERO

var current_rotation : float = 0

var current_x_sine_amplitude : float = 0

var current_y_sine_amplitude : float = 0

var current_theta_change_rate : float = 0

var current_theta : float = 0

var target_position : Vector2 = Vector2.ZERO

var enable_idle_motion : bool = true

func _ready():
	default_home_position = self.global_position
	randomize_rotation()
	randomize_theta_change_rate()
	randomize_sine_amplitudes()

func _physics_process(delta):
	if (enable_idle_motion):
		do_idle_motion(delta)

func set_enable_idle_motion(b : bool):
	enable_idle_motion = b

func do_idle_motion(delta : float):
	update_home_position()
	update_idle_motion(delta)
	do_easing_motion()

func set_home_position_target(target : Node2D):
	home_position_target = target
	self.global_position = target.global_position

func snap_to_target_node():
	self.global_position = home_position_target.global_position

func update_home_position():
	current_home_position = (default_home_position if home_position_target == null else home_position_target.global_position)

func update_idle_motion(delta : float):
	var x_sine_offset : float = (get_facing_direction() * (current_x_sine_amplitude * sin(current_theta)))
	var y_sine_offset : float = (current_y_sine_amplitude * sin(2 * current_theta))
	var vector_result : Vector2 = Vector2((x_sine_offset * cos(current_rotation)) - (y_sine_offset * sin(current_rotation)), (x_sine_offset * sin(current_rotation)) + (y_sine_offset * cos(current_rotation)))
	
	target_position = (current_home_position + vector_result)
	
	current_theta += (current_theta_change_rate * delta)
	if (current_theta >= TAU):
		current_theta -= TAU
		randomize_rotation()
		randomize_sine_amplitudes()
		randomize_theta_change_rate()

func do_easing_motion():
	self.global_position += ((target_position - self.global_position) * easing)

func randomize_rotation():
	current_rotation += randf_range(min_rotation_shift, max_rotation_shift)

func randomize_sine_amplitudes():
	current_x_sine_amplitude = randf_range(min_sine_amplitude, max_sine_amplitude)
	current_y_sine_amplitude = randf_range(min_sine_amplitude, max_sine_amplitude)

func randomize_theta_change_rate():
	current_theta_change_rate = randf_range(min_theta_change_rate, max_theta_change_rate)

func set_facing_direction(direction : float):
	if (direction > 0):
		sprite.flip_h = false
	elif (direction < 0):
		sprite.flip_h = true
	else:
		pass

func get_facing_direction():
	return (1 if sprite.flip_h else -1)
