extends RigidBody2D

class_name DroppedFragment

@export var sprite : AnimatedSprite2D

@export var min_vertical_launch : float = -32

@export var max_vertical_launch : float = -64

@export var min_horizontal_launch : float = -32

@export var max_horizontal_launch : float = 32

@export_color_no_alpha var mage_color : Color

@export_color_no_alpha var dragon_color : Color

@export var flicker_alpha : float = 0.25

@export var non_flicker_alpha : float = 0.85

var flickering : bool = false

func _ready():
	linear_velocity = Vector2(randf_range(min_horizontal_launch, max_horizontal_launch), randf_range(min_vertical_launch, max_vertical_launch))

func _physics_process(_delta):
	if (flickering):
		modulate.a = flicker_alpha
	else:
		modulate.a = non_flicker_alpha
	flickering = !flickering

func setup_color(is_mage_fragment : bool):
	sprite.modulate = (mage_color if is_mage_fragment else dragon_color)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if (linear_velocity.y > 0):
		queue_free()
