extends Node

class_name PlayerDamage

@export var hub : PlayerHub

@export var mage_temper_damage : int = 3

@export var dragon_temper_damage : int = -2

@export var vertical_damage_knockback : float = -64

@export var horizontal_damage_knockback : float = 160

@export var hitstun_time : float = 1

@export_range(0, 1) var invulnerability_alpha : float = 0.75

var current_hitstun_timer : float = 0

var is_damage_invulnerability_flickering : bool = false

var is_damage_invulnerability_active : bool = false
