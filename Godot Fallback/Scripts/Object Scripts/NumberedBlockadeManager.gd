extends Node

class_name NumberedBlockadeManager

const MAX_GROUPS : int = 4

@export var tilemap_group_1 : Array[TileMapLayer]

@export var tilemap_group_2 : Array[TileMapLayer]

@export var tilemap_group_3 : Array[TileMapLayer]

@export var tilemap_group_4 : Array[TileMapLayer]

var groups_unlocked : int = 0

func unlock_next_group():
	if (groups_unlocked < 0):
		groups_unlocked = 0
	
	if (groups_unlocked < MAX_GROUPS):
		groups_unlocked += 1
		update_group_collisions()

func set_groups_unlocked(g : int):
	if (g > MAX_GROUPS):
		groups_unlocked = MAX_GROUPS
	elif (g < 0):
		groups_unlocked = 0
	else:
		groups_unlocked = g
	update_group_collisions()

func update_group_collisions():
	if (groups_unlocked >= 4):
		for t in tilemap_group_4:
			if (t.enabled):
				t.enabled = false
	
	if (groups_unlocked >= 3):
		for t in tilemap_group_3:
			if (t.enabled):
				t.enabled = false
	
	if (groups_unlocked >= 2):
		for t in tilemap_group_2:
			if (t.enabled):
				t.enabled = false
	
	if (groups_unlocked >= 1):
		for t in tilemap_group_1:
			if (t.enabled):
				t.enabled = false
