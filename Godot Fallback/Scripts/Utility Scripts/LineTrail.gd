extends Line2D

class_name LineTrail

var queue : Array

@export var max_length : int = 10

var node_to_follow : Node = null

func _process(_delta):
	if (node_to_follow != null):
		var pos = (node_to_follow as Node2D).global_position
	
		queue.push_front(pos)
		
		if (queue.size() > max_length):
			queue.pop_back()
		
		clear_points()
		
		for point in queue:
			add_point(point)
	else:
		queue.clear()
		clear_points()
	

func set_node_to_follow(the_node : Node):
	node_to_follow = the_node
