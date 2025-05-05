extends Interactable

class_name WarpDoor

@export var warp_dummy : WarpTrigger

@export var door_texture_override : Texture2D = null

@export var lock_textures : Array[Texture2D]

@export var door_sprite : Sprite2D

@export var lock_sprite : Sprite2D

@export var room_origin : Room

@export var room_destination : Room

@export var room_entrance_index : int = 0

@export var is_locked : bool = false

@export_enum("KEY:0", "ENEMIES DEFEATED:1") var lock_type : int = 0

@export var enemies_to_defeat : int = 0

@export var enter_prompt : String = "[center][Interact] Enter"

@export var locked_prompt : String = "[center]Locked!"

@export var enemy_locked_prompt : String = "Defeat {amount} more!"

@export var unlock_prompt : String = "[center][Interact] Unlock"

var button_prompt_label : ButtonPromptTextLabel

func _ready():
	if (warp_dummy != null and self.room_origin != null and self.room_destination != null):
		warp_dummy.room_origin = self.room_origin
		warp_dummy.room_destination = self.room_destination
		warp_dummy.room_entrance_index = self.room_entrance_index
	
	if (door_texture_override != null):
		door_sprite.texture = door_texture_override
	
	if (button_prompt is ButtonPromptTextLabel):
		button_prompt_label = (button_prompt as ButtonPromptTextLabel)
	
	if (is_locked):
		lock_sprite.texture = lock_textures[lock_type]
		lock_sprite.set_visible(true)
		button_prompt_label.set_raw_text(locked_prompt)
	else:
		lock_sprite.set_visible(false)
		button_prompt_label.set_raw_text(enter_prompt)

func on_player_entered():
	if (is_locked):
		if (can_unlock()):
			button_prompt_label.set_raw_text(unlock_prompt)
		else:
			if (lock_type == 1):
				var enemy_num : int = (enemies_to_defeat - room_origin.level_ref.get_total_enemies_defeated())
				button_prompt_label.set_raw_text(enemy_locked_prompt.format({"amount" : enemy_num}))
			else:
				button_prompt_label.set_raw_text(locked_prompt)
		pass
	else:
		button_prompt_label.set_raw_text(enter_prompt)

func interact(hub : PlayerHub):
	if (player != null and hub == player):
		if (is_locked):
			if (can_unlock()):
				if (lock_type == 0):
					hub.inventory.remove_key()
				is_locked = false
				lock_sprite.set_visible(false)
				button_prompt_label.set_raw_text(enter_prompt)
				SoundFactory.play_sound_by_name("object_block_breakable", self.global_position, 0, 1)
			else:
				SoundFactory.play_sound_by_name("enemy_dragoon_projectile_destroy", self.global_position, 0, 1)
		else:
			warp_dummy._on_body_entered(hub.char_body)

func can_unlock():
	return ((player.inventory.has_key() and lock_type == 0) or (room_origin.level_ref.get_total_enemies_defeated() >= enemies_to_defeat and lock_type == 1))
