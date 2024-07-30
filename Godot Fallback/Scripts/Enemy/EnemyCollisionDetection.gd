extends Node

class_name EnemyCollisionDetection

@export var enemy : Enemy

@export var raycast_wall_top_l : RayCast2D

@export var raycast_wall_mid_l : RayCast2D

@export var raycast_wall_bot_l : RayCast2D

@export var raycast_wall_top_r : RayCast2D

@export var raycast_wall_mid_r : RayCast2D

@export var raycast_wall_bot_r : RayCast2D

@export var raycast_ledge_l : RayCast2D

@export var raycast_ledge_r : RayCast2D

@export var player_collision_sound_name : String = "enemy_contact_impact"

@export var player_collision_effect_name : String = "EnemyContactImpact"

var is_touching_ledge : bool = false

var is_colliding_with_player : bool = false

signal touching_wall

signal touching_ledge

signal player_collision

signal leaving_ground

signal touching_ground

func _physics_process(_delta):
	ground_check()
	wall_check()
	ledge_check()
	player_check()

func play_player_collision_sound():
	SoundFactory.play_sound_by_name(player_collision_sound_name, enemy.player_detection.get_player_position(), 0, 1, "SFX")

func spawn_player_collision_effect():
	EffectFactory.get_effect(player_collision_effect_name, enemy.player_detection.get_player_position())

func ground_check():
	if (enemy.body.is_on_floor()):
		touching_ground.emit()
	else:
		leaving_ground.emit()

func wall_check():
	var top_check : RayCast2D = (raycast_wall_top_l if enemy.movement.get_facing_value() < 0 else raycast_wall_top_r)
	var mid_check : RayCast2D = (raycast_wall_mid_l if enemy.movement.get_facing_value() < 0 else raycast_wall_mid_r)
	var bot_check : RayCast2D = (raycast_wall_bot_l if enemy.movement.get_facing_value() < 0 else raycast_wall_bot_r)
	
	top_check.force_raycast_update()
	mid_check.force_raycast_update()
	bot_check.force_raycast_update()
	
	if (enemy.body.is_on_wall() and (top_check.is_colliding() or mid_check.is_colliding() or bot_check.is_colliding()) and (top_check.get_collision_normal().y == 0 or mid_check.get_collision_normal().y == 0 or bot_check.get_collision_normal().y == 0)):
		touching_wall.emit()

func ledge_check():
	if (enemy.body.is_on_floor()):
		var raycast_to_check : RayCast2D = (raycast_ledge_l if enemy.movement.get_facing_value() < 0 else raycast_ledge_r)
		raycast_to_check.force_raycast_update()
		if (raycast_to_check.is_colliding()):
			is_touching_ledge = false
		else:
			touching_ledge.emit()
			is_touching_ledge = true

func player_check():
	if (is_colliding_with_player):
		player_collision.emit()

func _on_contact_hitbox_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_colliding_with_player = true

func _on_contact_hitbox_body_exited(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		is_colliding_with_player = false
