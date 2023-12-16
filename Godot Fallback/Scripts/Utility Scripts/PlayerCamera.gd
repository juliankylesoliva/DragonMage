extends Camera2D

class_name PlayerCamera

@export var hub : PlayerHub

@export var base_x_lookahead : float = 64

@export var max_x_lookahead : float = 192

@export var target_x_lookahead_delta_multiplier : float = 2

func _physics_process(delta):
	if (hub.state_machine.current_state.can_update_camera):
		update_lookahead(delta)

func update_lookahead(delta : float):
	var target_x : float = (base_x_lookahead * (hub.char_body.velocity.x / hub.movement.top_speed))
	if (abs(target_x) > max_x_lookahead):
		if (target_x > 0):
			target_x = max_x_lookahead
		else:
			target_x = -max_x_lookahead
	position.x = (move_toward(position.x, target_x, abs(target_x - position.x) * target_x_lookahead_delta_multiplier * delta) as int)
