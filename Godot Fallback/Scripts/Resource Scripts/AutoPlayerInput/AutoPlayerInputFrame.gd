extends Resource

class_name AutoPlayerInputFrame

@export_range(1, 3600) var duration : int = 1
@export var left : bool = false
@export var right : bool = false
@export var up : bool = false
@export var down : bool = false
@export var jump : bool = false
@export var glide : bool = false
@export var attack : bool = false
@export var change : bool = false
@export var crouch : bool = false
@export var fairy : bool = false
@export var interact : bool = false

func is_equal_to(other : AutoPlayerInputFrame):
	return (self.left == other.left
	and self.right == other.right
	and self.up == other.up
	and self.down == other.down
	and self.jump == other.jump
	and self.glide == other.glide
	and self.attack == other.attack
	and self.change == other.change
	and self.crouch == other.crouch
	and self.fairy == other.fairy
	and self.interact == other.interact)
