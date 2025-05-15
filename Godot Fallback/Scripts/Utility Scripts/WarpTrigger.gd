extends Area2D

class_name WarpTrigger

const PLAYER_HITBOX_RADIUS : int = 8

@export var room_origin : Room

@export var room_destination : Room

@export var room_entrance_index : int = 0

@export var collision_shape : CollisionShape2D

@export_enum("NORMAL:0", "WALL:1") var warp_mode : int = 0

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
		hub.set_respawn_position(destination_coords)
		
		if (hub.fairy.fairy_ref != null):
			hub.fairy.fairy_ref.snap_to_target_node()
		
		hub.camera.saved_y_position = hub.collisions.get_ground_point().y
		hub.camera.snap_camera_to_player()
		
		if (warp_mode == 1 and (hub.state_machine.current_state.name == "WallSliding" or hub.state_machine.current_state.name == "WallClimbing")):
			hub.char_body.global_position.x += (((collision_shape.shape.get_rect().size.x / 2) - PLAYER_HITBOX_RADIUS) * hub.movement.get_facing_value())
			if (hub.state_machine.current_state.name == "WallSliding"):
				hub.camera.update_x_lookahead(get_physics_process_delta_time())
		
		if (room_destination != room_origin):
			room_origin.deactivate_room()
		
		room_destination.room_activated.emit()
	elif (body is MagicBlastProjectile):
		body.queue_free()
	else:
		pass
