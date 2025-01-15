extends Resource

class_name AutoPlayerInputSequence

@export var starting_mode : PlayerForm.CharacterMode = PlayerForm.CharacterMode.MAGE
@export var loop : bool = false
@export var loop_from_starting_position = false
@export var resume_player_control = false
@export var frames : Array[AutoPlayerInputFrame]
@export var position_list : Array[Vector2]

func get_position_list_index(current_frame : int, current_timer : int):
	var sum : int = -1
	if (position_list != null and !position_list.is_empty() and current_frame >= 0 and current_frame < frames.size() and current_timer > 0):
		for i in (current_frame + 1):
			sum += frames[i].duration
		sum -= current_timer
	return sum
