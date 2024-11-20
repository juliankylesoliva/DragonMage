extends Node

class_name BossDragonfruitSpawner

@export var dragonfruits : Array[TemperDragonFruit]

@export var boss : Boss

@export var room_origin : Room

@export var player : PlayerHub

@export_enum("Closest:0", "Farthest:1", "Random:2") var selection_type : int = 0

func _process(_delta):
	if (room_origin.is_room_active and boss.is_activated and player.temper.is_form_locked() and check_dragonfruits_spawned() <= 0):
		match selection_type:
			0:
				spawn_closest()
			1:
				spawn_farthest()
			2:
				spawn_random()
			_:
				spawn_random()

func check_dragonfruits_spawned():
	var sum : int = 0
	for d in dragonfruits:
		if (d.visible):
			sum += 1
	return sum

func spawn_closest():
	var closest : TemperDragonFruit = null
	var saved_distance : float = -1
	for d in dragonfruits:
		var current_distance : float = d.global_position.distance_to(player.char_body.global_position)
		if (closest == null or current_distance < saved_distance):
			saved_distance = current_distance
			closest = d
	
	if (closest != null):
		closest.do_respawn(true)

func spawn_farthest():
	var farthest : TemperDragonFruit = null
	var saved_distance : float = -1
	for d in dragonfruits:
		var current_distance : float = d.global_position.distance_to(player.char_body.global_position)
		if (farthest == null or current_distance > saved_distance):
			saved_distance = current_distance
			farthest = d
	
	if (farthest != null):
		farthest.do_respawn(true)

func spawn_random():
	if (dragonfruits.size() > 0):
		dragonfruits.pick_random().do_respawn(true)
