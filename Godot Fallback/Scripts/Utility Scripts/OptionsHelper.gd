extends Node

var enable_glide_toggle : bool = false

var enable_crouch_toggle : bool = false

func switch_glide_toggle():
	enable_glide_toggle = !enable_glide_toggle

func switch_crouch_toggle():
	enable_crouch_toggle = !enable_crouch_toggle

func update_control_options(hub : PlayerHub):
	hub.jumping.enable_glide_toggle = self.enable_glide_toggle
	hub.movement.enable_crouch_toggle = self.enable_crouch_toggle
