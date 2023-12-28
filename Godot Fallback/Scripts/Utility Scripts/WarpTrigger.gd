extends Node2D

class_name WarpTrigger

@export var room_origin : Room

@export var room_destination : Room

@export var room_entrance_index : int = 0

func _on_body_entered(body):
	if (body is CharacterBody2D and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		var hub : PlayerHub = null
		for child in body.get_children():
			if (child is PlayerHub):
				hub = (child as PlayerHub)
				break
		
		if (hub == null):
			return
		
		(hub.attacks.get_attack_by_name("MagicBlast") as MagicBlastAttack).destroy_projectile()
		
		var destination_coords : Vector2 = room_destination.get_room_entrance_coordinates(room_entrance_index)
		if (room_destination != room_origin):
			room_destination.activate_room()
		
		hub.char_body.global_position = destination_coords
		
		hub.camera.saved_y_position = hub.collisions.get_ground_point().y
		hub.camera.snap_camera_to_player()
		
		if (room_destination != room_origin):
			room_origin.deactivate_room()
	elif (body is MagicBlastProjectile):
		body.queue_free()
	else:
		pass
