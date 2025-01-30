extends CharacterBody2D

class_name CutsceneActor

signal actor_movement_finished

signal actor_falling

signal actor_landing

@export var actor_name : String = "???"

@export var actor_anim_sprite : AnimatedSprite2D

@export var actor_on_screen : VisibleOnScreenNotifier2D

@export var ground_raycast : RayCast2D

@export var min_blink_anim_time : float = 2

@export var max_blink_anim_time : float = 3

@export var jump_sound : String = "jump_magli"

@export var footstep_dictionary : Dictionary

@export var footstep_sound : String = "jump_magli_landing"

@export var rising_gravity_scale : float = 2

@export var falling_gravity_scale : float = 3

var current_blink_timer : float = 0

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_gravity_scale : float = 1

var current_gravity_scale_override : float = 0

var is_using_gravity_scale_override : bool = false

var prev_is_on_floor : bool = true

func _ready():
	actor_anim_sprite.animation_finished.connect(check_blink_animation)
	actor_anim_sprite.frame_changed.connect(check_footstep_animation)
	set_blink_timer()

func _process(delta):
	update_blink_timer(delta)
	check_landing()
	prev_is_on_floor = self.is_on_floor()

func _physics_process(delta):
	apply_gravity(delta)
	self.move_and_slide()

func set_blink_timer():
	current_blink_timer = randf_range(min_blink_anim_time, max_blink_anim_time)

func update_blink_timer(delta):
	current_blink_timer = move_toward(current_blink_timer, 0, delta)

func apply_gravity(delta : float):
	if (!self.is_on_floor()):
		var prev_y_velocity : float = self.velocity.y
		current_gravity_scale = (current_gravity_scale_override if is_using_gravity_scale_override else rising_gravity_scale if self.velocity.y < 0 else falling_gravity_scale)
		self.velocity += (Vector2.DOWN * base_gravity * current_gravity_scale * delta)
		if (prev_y_velocity < 0 and self.velocity.y >= 0):
			actor_falling.emit()

func check_blink_animation():
	if (!actor_anim_sprite.is_playing()):
		if (actor_anim_sprite.animation.contains("Blink")):
			actor_anim_sprite.play(actor_anim_sprite.animation.substr(0,actor_anim_sprite.animation.find("Blink")))
		else:
			var blink_anims : Array[StringName] = []
			for anim in actor_anim_sprite.sprite_frames.get_animation_names():
				if (anim.contains("%sBlink" % actor_anim_sprite.animation)):
					blink_anims.append(anim)
			if (blink_anims != null and blink_anims.size() > 0):
				actor_anim_sprite.play(blink_anims.pick_random())
				set_blink_timer()

func check_footstep_animation():
	if (self.is_on_floor() and footstep_dictionary.has(actor_anim_sprite.animation) and footstep_dictionary[actor_anim_sprite.animation].has(actor_anim_sprite.frame)):
		var effect_instance = EffectFactory.get_effect("WalkingDust", get_ground_point(), 1, actor_anim_sprite.flip_h)
		effect_instance.rotation = self.up_direction.angle_to(self.get_floor_normal())
		SoundFactory.play_sound_by_name(footstep_sound, self.global_position, 0, 1, "SFX")

func check_landing():
	if (!prev_is_on_floor and self.is_on_floor()):
		var effect_instance = EffectFactory.get_effect("LandingDust", get_ground_point(), 1, actor_anim_sprite.flip_h)
		effect_instance.rotation = self.up_direction.angle_to(self.get_floor_normal())
		SoundFactory.play_sound_by_name(footstep_sound, self.global_position, 0, 1, "SFX")
		actor_landing.emit()

func set_gravity_scale_override(g : float):
	current_gravity_scale_override = g
	is_using_gravity_scale_override = true

func reset_gravity_scale_override():
	current_gravity_scale_override = 0
	is_using_gravity_scale_override = false

func get_ground_point():
	ground_raycast.force_raycast_update()
	return (ground_raycast.get_collision_point() if ground_raycast.is_colliding() else ground_raycast.global_position)

func do_move(speed : float, duration : float, set_direction : bool = true):
	self.velocity += (Vector2.RIGHT * speed)
	if (set_direction):
		set_facing_direction(speed)
	await get_tree().create_timer(abs(duration)).timeout
	self.velocity.x = 0.0
	actor_movement_finished.emit()

func set_facing_direction(direction : float):
	actor_anim_sprite.flip_h = (direction < 0)

func do_jump(speed : float):
	self.velocity += (Vector2.UP * abs(speed))
	var effect_instance : AnimatedSprite2D = EffectFactory.get_effect("JumpSpark", get_ground_point(), 1, actor_anim_sprite.flip_h)
	effect_instance.rotation = self.up_direction.angle_to(self.get_floor_normal())
	SoundFactory.play_sound_by_name(jump_sound, self.global_position, 0, 1, "SFX")

func do_shorten_jump(time : float):
	var starting_y_velocity : float = self.velocity.y
	while (self.velocity.y < 0):
		self.velocity.y = move_toward(self.velocity.y, 0, (abs(starting_y_velocity) / time) * get_physics_process_delta_time())
		await get_tree().physics_frame
