extends Node

class_name CutsceneActor

@export var actor_name : String

@export var actor_char_body : CharacterBody2D

@export var actor_anim_sprite : AnimatedSprite2D

@export var rising_gravity_scale : float = 2

@export var falling_gravity_scale : float = 3

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_gravity_scale : float = 1

var current_gravity_scale_override : float = 0

var is_using_gravity_scale_override : bool = false

func _physics_process(delta):
	if (!actor_char_body.is_on_floor()):
		current_gravity_scale = (current_gravity_scale_override if is_using_gravity_scale_override else rising_gravity_scale if actor_char_body.velocity.y < 0 else falling_gravity_scale)
		actor_char_body.velocity += (Vector2.DOWN * base_gravity * current_gravity_scale * delta)
	actor_char_body.move_and_slide()

func set_gravity_scale_override(g : float):
	current_gravity_scale_override = g
	is_using_gravity_scale_override = true

func reset_gravity_scale_override():
	current_gravity_scale_override = 0
	is_using_gravity_scale_override = false

func do_move(speed : float, duration : float, set_direction : bool = true):
	actor_char_body.velocity += (Vector2.RIGHT * speed)
	if (set_direction):
		set_facing_direction(speed)
	await get_tree().create_timer(abs(duration)).timeout
	actor_char_body.velocity.x = 0.0

func set_facing_direction(direction : float):
	actor_anim_sprite.flip_h = (direction < 0)

func do_jump(speed : float):
	actor_char_body.velocity += (Vector2.UP * -abs(speed))

func do_shorten_jump(time : float):
	var starting_y_velocity : float = actor_char_body.velocity.y
	while (actor_char_body.velocity.y < 0):
		actor_char_body.velocity.y = move_toward(actor_char_body.velocity.y, 0, (starting_y_velocity / time) * get_physics_process_delta_time())
		await get_tree().physics_frame
