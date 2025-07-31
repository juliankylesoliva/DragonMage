extends PathFollow2D

class_name ImpostorSwordProjectile

@export var travel_time : float = 2

var is_moving : bool = false

var target_ratio : float = 0

func _physics_process(delta):
	if (!is_moving):
		return
	
	if (progress_ratio != target_ratio):
		progress_ratio = move_toward(progress_ratio, target_ratio, delta / travel_time)
		if (progress_ratio == target_ratio):
			self.queue_free()
	

func start_moving(is_reverse : bool):
	if (!is_moving):
		self.position = Vector2.ZERO
		progress_ratio = (1.0 if is_reverse else 0.0)
		target_ratio = (0.0 if is_reverse else 1.0)
		is_moving = true
