extends Node2D

class_name CollectableScale

@export var sprite : AnimatedSprite2D

@export var text_label : RichTextLabel

@export var stream_player : AudioStreamPlayer2D

@export var text_template : String = "[center][[color={mage_color}]{mage}[color=white]:[color={dragon_color}]{dragon}[color=white]]"

@export var blue_hex : String = "#443482"

@export var orange_hex : String = "#cf7a30"

@export_range(0, 1) var blank_alpha : float = 0.6

@export_enum("MAGICAL", "DRACONIC", "BALANCED") var collectable_type : String = "BALANCED"

@export var mage_fragments_needed : int = 0

@export var dragon_fragments_needed : int = 0

@export var normal_z_index = 2

@export var collect_z_index: int = 6

@export var collect_spin_rate : float = 3

@export var collect_jump_velocity : float = 32

@export var collect_gravity_scale : float = 2

var level_ref : Level

var is_collected = false

var current_jump_velocity : float = 0

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if (is_collected and sprite.visible):
		text_label.visible = false
		sprite.offset.y += (current_jump_velocity * delta)
		if (sprite.offset.y > 0):
			sprite.visible = false
			sprite.offset.y = 0
			sprite.speed_scale = 1
			sprite.z_index = normal_z_index
		else:
			current_jump_velocity += (base_gravity * collect_gravity_scale * delta)
	
	if (sprite.visible):
		var current_frame : int = sprite.frame
		var current_progress : float = sprite.frame_progress
		var previous_name : String = sprite.animation
		sprite.play(get_animation_name())
		if (sprite.animation != previous_name):
			sprite.frame = current_frame
			sprite.frame_progress = current_progress
		text_label.text = text_template.format({"mage_color" : blue_hex, "dragon_color" : orange_hex, "mage" : (str(mage_fragments_needed) if !collectable_type == "DRACONIC" else "~~"), "dragon" : (str(dragon_fragments_needed) if collectable_type != "MAGICAL" else "--")})
		sprite.modulate.a = (blank_alpha if !is_solid() else 1.0)

func mark_as_collected():
	is_collected = true
	sprite.hide()

func set_level_ref(level : Level):
	level_ref = level

func can_collect():
	return (level_ref.mage_fragments >= mage_fragments_needed or collectable_type == "DRACONIC") and (level_ref.dragon_fragments >= dragon_fragments_needed or collectable_type == "MAGICAL")

func is_solid():
	return level_ref != null and (is_collected or can_collect())

func get_animation_name():
	var type_string : String = ("Magic" if collectable_type == "MAGICAL" else "Dragon" if collectable_type == "DRACONIC" else "Balance")
	return (("%sScale" if is_solid() else "%sScaleBlank") % type_string)

func _on_area_2d_body_entered(body):
	if (is_solid() and !is_collected):
		if (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
			for child in body.get_children():
				if (child is PlayerHub):
					var temp_hub : PlayerHub = (child as PlayerHub)
					if (!temp_hub.damage.is_player_damaged()):
						stream_player.play()
						is_collected = true
						
						sprite.z_index = collect_z_index
						sprite.speed_scale = collect_spin_rate
						current_jump_velocity = -collect_jump_velocity
					return
