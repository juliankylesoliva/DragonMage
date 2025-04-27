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

var button_prompt_label : ButtonPromptTextLabel

func _ready():
	if (warp_dummy != null and self.room_origin != null and self.room_destination != null):
		warp_dummy.room_origin = self.room_origin
		warp_dummy.room_destination = self.room_destination
		warp_dummy.room_entrance_index = self.room_entrance_index
	
	if (button_prompt is ButtonPromptTextLabel):
		button_prompt_label = (button_prompt as ButtonPromptTextLabel)
	
	if (is_locked):
		button_prompt_label.set_raw_text(locked_prompt)
	else:
		button_prompt_label.set_raw_text(enter_prompt)

func on_player_entered():
	if (is_locked):
		if (player.inventory.has_key()):
			button_prompt_label.set_raw_text(unlock_prompt)
		else:
			button_prompt_label.set_raw_text(locked_prompt)
		pass
	else:
		button_prompt_label.set_raw_text(enter_prompt)

func interact(hub : PlayerHub):
	if (player != null and hub == player):
		if (is_locked):
			if (hub.inventory.has_key()):
				hub.inventory.remove_key()
				is_locked = false
				button_prompt_label.set_raw_text(enter_prompt)
				SoundFactory.play_sound_by_name("object_block_breakable", self.global_position, 0, 1)
			else:
				SoundFactory.play_sound_by_name("enemy_dragoon_projectile_destroy", self.global_position, 0, 1)
		else:
			warp_dummy._on_body_entered(hub.char_body)
