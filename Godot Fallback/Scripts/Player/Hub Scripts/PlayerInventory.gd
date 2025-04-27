extends Node

class_name PlayerInventory

@export var hub : PlayerHub

var keys : int = 0

func add_key():
	keys += 1

func remove_key():
	if (keys > 0):
		keys -= 1

func has_key():
	return (keys > 0)
