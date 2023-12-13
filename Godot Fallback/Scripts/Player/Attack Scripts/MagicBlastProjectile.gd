extends Node

class_name MagicBlastProjectile

@export var hitbox_scene : PackedScene

@export var sprite : AnimatedSprite2D

@export_color_no_alpha var normal_color : Color = Color.WHITE

@export_color_no_alpha var pulse_color : Color = Color.WHITE

@export var fuse_time : float = 5

@export var max_lerp_change : float = 1

@export var blast_radius : float = 57.6

@export var base_radius : float = 16

var attack_ref : MagicBlastAttack = null

var current_fuse_time_left : float = 0

var current_lerp_weight : float = 0

func _ready():
	current_fuse_time_left = fuse_time

func _process(delta):
	sprite.modulate = normal_color.lerp(pulse_color, pingpong(current_lerp_weight, 1))
	current_fuse_time_left = move_toward(current_fuse_time_left, 0, delta)
	current_lerp_weight += (min(max_lerp_change, (fuse_time / current_fuse_time_left) * delta))
	
	if (current_fuse_time_left <= 0):
		detonate()

func detonate():
	var hitbox_instance = hitbox_scene.instantiate()
	add_sibling(hitbox_instance)
	(hitbox_instance as Node2D).global_position = sprite.global_position
	
	(hitbox_instance as KnockbackHitbox).hit.connect(attack_ref._on_magic_blast_hit)
	
	SoundFactory.play_sound_by_name("attack_magli_explosion", sprite.global_position, -6, 1, "SFX")
	EffectFactory.get_effect("MagicBlastExplosion", sprite.global_position, blast_radius / base_radius)
	
	despawn()

func despawn():
	queue_free()

func _on_body_entered(_body):
	SoundFactory.play_sound_by_name("attack_magli_bounce", sprite.global_position, -4, 1, "SFX")
