extends Node

const MAX_VOLUME : int = 100

const MIN_VOLUME : int = 0

const MASTER_BUS_NAME : String = "Master"

const MUSIC_BUS_NAME : String = "Music"

const SFX_BUS_NAME : String = "SFX"

const VALUE_TO_PERCENT : float = 100

var enable_glide_toggle : bool = false

var enable_crouch_toggle : bool = false

var enable_quick_restart_toggle : bool = false

var enable_clear_timer_toggle : bool = false

var enable_safety_mode_toggle : bool = false

var master_volume : int = 100

var music_volume : int = 80

var sfx_volume : int = 75

func _ready():
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

func switch_glide_toggle():
	enable_glide_toggle = !enable_glide_toggle

func switch_crouch_toggle():
	enable_crouch_toggle = !enable_crouch_toggle

func switch_quick_restart_toggle():
	enable_quick_restart_toggle = !enable_quick_restart_toggle

func switch_clear_timer_toggle():
	enable_clear_timer_toggle = !enable_clear_timer_toggle

func switch_safety_mode_toggle():
	enable_safety_mode_toggle = !enable_safety_mode_toggle

func update_control_options(hub : PlayerHub):
	hub.jumping.enable_glide_toggle = self.enable_glide_toggle
	hub.jumping.enable_infinite_midair_abilities = self.enable_safety_mode_toggle
	hub.movement.enable_crouch_toggle = self.enable_crouch_toggle
	hub.damage.disable_defeat = self.enable_safety_mode_toggle

func set_master_volume(vol : int):
	master_volume = (MAX_VOLUME if vol > MAX_VOLUME else MIN_VOLUME if vol < MIN_VOLUME else vol)
	set_volume(MASTER_BUS_NAME, master_volume)

func increase_master_volume():
	master_volume += (1 if master_volume < MAX_VOLUME else 0)
	set_volume(MASTER_BUS_NAME, master_volume)

func decrease_master_volume():
	master_volume -= (1 if master_volume > MIN_VOLUME else 0)
	set_volume(MASTER_BUS_NAME, master_volume)

func get_master_volume_text():
	return "{value}%".format({"value" : master_volume})

func set_music_volume(vol : int):
	music_volume = (MAX_VOLUME if vol > MAX_VOLUME else MIN_VOLUME if vol < MIN_VOLUME else vol)
	set_volume(MUSIC_BUS_NAME, music_volume)

func increase_music_volume():
	music_volume += (1 if music_volume < MAX_VOLUME else 0)
	set_volume(MUSIC_BUS_NAME, music_volume)

func decrease_music_volume():
	music_volume -= (1 if music_volume > MIN_VOLUME else 0)
	set_volume(MUSIC_BUS_NAME, music_volume)

func get_music_volume_text():
	return "{value}%".format({"value" : music_volume})

func set_sfx_volume(vol : int):
	sfx_volume = (MAX_VOLUME if vol > MAX_VOLUME else MIN_VOLUME if vol < MIN_VOLUME else vol)
	set_volume(SFX_BUS_NAME, sfx_volume)

func increase_sfx_volume():
	sfx_volume += (1 if sfx_volume < MAX_VOLUME else 0)
	set_volume(SFX_BUS_NAME, sfx_volume)

func decrease_sfx_volume():
	sfx_volume -= (1 if sfx_volume > MIN_VOLUME else 0)
	set_volume(SFX_BUS_NAME, sfx_volume)

func get_sfx_volume_text():
	return "{value}%".format({"value" : sfx_volume})

func set_volume(bus_name : String, vol : int):
	var v : float = (MAX_VOLUME if vol > MAX_VOLUME else MIN_VOLUME if vol < MIN_VOLUME else vol)
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	v /= MAX_VOLUME
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(v))
