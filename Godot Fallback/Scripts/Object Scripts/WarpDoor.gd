extends Interactable

class_name WarpDoor

@export var warp_dummy : WarpTrigger

@export var room_origin : Room

@export var room_destination : Room

@export var room_entrance_index : int = 0

@export var is_locked : bool = false

@export var enter_prompt : String = "[center][Interact] Enter"

@export var locked_prompt : String = "[center]Locked!"

@export var unlock_prompt : String = "[center][Interact] Unlock"

func _ready():
	if (warp_dummy != null and self.room_origin != null and self.room_destination != null):
		warp_dummy.room_origin = self.room_origin
		warp_dummy.room_destination = self.room_destination
		warp_dummy.room_entrance_index = self.room_entrance_index
	
	if (is_locked):
		button_prompt.text = locked_prompt
	else:
		button_prompt.text = enter_prompt

func on_player_enter():
	if (is_locked):
		# TODO: if player has a key, then show unlock prompt, else show locked prompt
		if (true):
			button_prompt.text = unlock_prompt
		else:
			button_prompt.text = locked_prompt
		pass
	else:
		button_prompt.text = enter_prompt

func interact(hub : PlayerHub):
	if (player != null and hub == player):
		if (is_locked):
			# TODO: if player has key, then use it, unlock, and change to enter prompt
			if (true):
				is_locked = false
				button_prompt.text = enter_prompt
		else:
			warp_dummy._on_body_entered(hub.char_body)
