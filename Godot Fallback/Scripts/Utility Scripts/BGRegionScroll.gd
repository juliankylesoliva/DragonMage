extends Sprite2D

@export var scroll_speed : float = 32

@export var loop_value : float = 512

func _process(delta):
	if (self.visible and self.region_enabled):
		self.region_rect.position.x += (scroll_speed * delta)
		if (self.region_rect.position.x >= loop_value):
			self.region_rect.position.x -= loop_value
