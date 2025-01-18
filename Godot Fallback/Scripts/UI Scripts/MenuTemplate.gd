extends Node2D

class_name MenuTemplate

enum MenuDirection {NONE, UP, DOWN, RIGHT, LEFT}

@export var menu_cursor : MenuCursor

@export var max_selections : int = 3

@export var max_secondary_selections : int = 1

@export var enable_wraparound : bool = true

@export var enable_secondary_wraparound : bool = false

@export var direction_hold_time : float = 0.25

@export var direction_hold_repeat_interval : float = 0.10

var current_selection : int = 0

var current_secondary_selection : int = 0

var enable_input : bool = false

var previous_menu : MenuTemplate

var was_menu_just_activated : bool = false

var current_direction_hold_time : float = 0

var is_holding_a_direction : bool = false

var last_direction_pressed : MenuDirection = MenuDirection.NONE

func _process(_delta):
	if (self.visible and enable_input and !was_menu_just_activated):
		var left_pressed : bool = Input.is_action_just_pressed("Menu Left")
		var right_pressed : bool = Input.is_action_just_pressed("Menu Right")
		var up_pressed : bool = Input.is_action_just_pressed("Menu Up")
		var down_pressed : bool = Input.is_action_just_pressed("Menu Down")
		
		var left_held : bool = Input.is_action_pressed("Menu Left")
		var right_held : bool = Input.is_action_pressed("Menu Right")
		var up_held : bool = Input.is_action_pressed("Menu Up")
		var down_held : bool = Input.is_action_pressed("Menu Down")
		
		if (up_pressed or down_pressed or left_pressed or right_pressed):
			current_direction_hold_time = 0
			is_holding_a_direction = false
		
		var directions_pressed : int = 0
		directions_pressed += (1 if left_held else 0)
		directions_pressed += (1 if right_held else 0)
		directions_pressed += (1 if up_held else 0)
		directions_pressed += (1 if down_held else 0)
		
		if (directions_pressed == 1):
			var target_hold_time : float = (direction_hold_repeat_interval if is_holding_a_direction else direction_hold_time)
			current_direction_hold_time = move_toward(current_direction_hold_time, target_hold_time, _delta)
			if (current_direction_hold_time >= target_hold_time):
				current_direction_hold_time = 0
				is_holding_a_direction = true
				left_pressed = left_held
				right_pressed = right_held
				up_pressed = up_held
				down_pressed = down_held
		else:
			current_direction_hold_time = 0
			is_holding_a_direction = false
		
		if (Input.is_action_just_pressed("Menu Confirm")):
			on_selection_confirm()
		elif(Input.is_action_just_pressed("Menu Cancel")):
			on_menu_cancel()
		elif (Input.is_action_just_pressed("Menu Misc 1")):
			on_menu_misc_1()
		elif (Input.is_action_just_pressed("Menu Misc 2")):
			on_menu_misc_2()
		elif (Input.is_action_just_pressed("Change Form")):
			on_change_form()
		elif ((up_pressed or down_pressed) and !(up_pressed and down_pressed)):
			if (up_pressed):
				on_up_pressed()
			elif (down_pressed):
				on_down_pressed()
			else:
				pass
		elif ((left_pressed or right_pressed) and !(left_pressed and right_pressed)):
			if (left_pressed):
				on_left_pressed()
			elif (right_pressed):
				on_right_pressed()
			else:
				pass
		else:
			pass
	
	if (was_menu_just_activated):
		was_menu_just_activated = false

func set_previous_menu(m: MenuTemplate):
	previous_menu = m

func activate_menu():
	self.set_visible(true)
	enable_input = true
	on_menu_activation()
	was_menu_just_activated = true

func deactivate_menu():
	self.set_visible(false)
	enable_input = false
	on_menu_deactivation()

func set_enable_input(b : bool):
	enable_input = b

func on_menu_activation():
	pass

func on_menu_deactivation():
	pass

func reset_selection():
	current_selection = 0
	on_selection_reset()

func reset_secondary_selection():
	current_secondary_selection = 0
	on_selection_reset()

func on_up_pressed():
	pass

func on_down_pressed():
	pass

func on_left_pressed():
	pass

func on_right_pressed():
	pass

func on_selection_wraparound(_increment : bool = false):
	pass

func on_secondary_selection_wraparound(_increment : bool = false):
	pass

func increment_selection():
	if (current_selection < (max_selections - 1) or enable_wraparound):
		current_selection += 1
		if (current_selection >= max_selections):
			current_selection = 0
			on_selection_wraparound(true)
		on_selection_change()

func decrement_selection():
	if (current_selection > 0 or enable_wraparound):
		current_selection -= 1
		if (current_selection < 0):
			current_selection = (max_selections - 1)
			on_selection_wraparound(false)
		on_selection_change()

func increment_secondary_selection():
	if (current_secondary_selection < (max_secondary_selections - 1) or enable_secondary_wraparound):
		current_secondary_selection += 1
		if (current_secondary_selection >= max_secondary_selections):
			current_secondary_selection = 0
			on_secondary_selection_wraparound(true)
		on_secondary_selection_change()

func decrement_secondary_selection():
	if (current_secondary_selection > 0 or enable_secondary_wraparound):
		current_secondary_selection -= 1
		if (current_secondary_selection < 0):
			current_secondary_selection = (max_secondary_selections - 1)
			on_secondary_selection_wraparound(false)
		on_secondary_selection_change()

func on_selection_reset():
	pass

func on_selection_change():
	pass

func on_secondary_selection_change():
	pass

func on_selection_confirm():
	pass

func on_menu_cancel():
	pass

func on_menu_misc_1():
	pass

func on_menu_misc_2():
	pass

func on_change_form():
	pass
