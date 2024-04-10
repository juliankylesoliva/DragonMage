extends Node2D

class_name MedalFragment

@export var sprite : AnimatedSprite2D

@export var stream_player : AudioStreamPlayer2D

@export_color_no_alpha var mage_color : Color

@export_color_no_alpha var dragon_color : Color

@export var normal_z_index = 2

@export var collect_z_index: int = 6

@export var collect_spin_rate : float = 3

@export var collect_jump_velocity : float = 32

@export var collect_gravity_scale : float = 2

@export var magic_restore_amount : float = 1

var level_ref : Level

var is_collected = false

var current_jump_velocity : float = 0

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if (is_collected and sprite.visible):
		sprite.offset.y += (current_jump_velocity * delta)
		if (sprite.offset.y > 0):
			sprite.visible = false
			sprite.offset.y = 0
			sprite.speed_scale = 1
			sprite.z_index = normal_z_index
		else:
			current_jump_velocity += (base_gravity * collect_gravity_scale * delta)

func mark_as_collected():
	is_collected = true
	sprite.hide()

func set_level_ref(level : Level):
	level_ref = level

func _on_area_2d_body_entered(body):
	if (!is_collected):
		if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
			for child in body.get_children():
				if (child is PlayerHub):
					var temp_hub : PlayerHub = (child as PlayerHub)
					var is_mage = temp_hub.form.is_a_mage()
					
					stream_player.play()
					is_collected = true
					sprite.modulate = (mage_color if is_mage else dragon_color)
					level_ref.increment_fragments(is_mage)
					
					sprite.z_index = collect_z_index
					sprite.speed_scale = collect_spin_rate
					current_jump_velocity = -collect_jump_velocity
					
					temp_hub.fairy.change_current_magic_by(magic_restore_amount)
					
					return
