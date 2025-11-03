extends TileMapLayer

class_name SwitchingBlockade

@export var room_ref : Room

@export_enum("MAGE:0", "DRAGON:1", "OUTLINES:2") var solid_form : int = 2

var player_ref : PlayerHub = null

func _physics_process(_delta: float):
	if (solid_form == 2):
		return
	
	if (player_ref == null and room_ref.level_ref != null and room_ref.level_ref.player_hub != null):
		player_ref = room_ref.level_ref.player_hub
	
	if (player_ref != null):
		self.enabled = (solid_form == player_ref.form.current_mode)
