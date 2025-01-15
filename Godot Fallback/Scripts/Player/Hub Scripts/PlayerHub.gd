extends Node

class_name PlayerHub

@export var debug_enable_input_recording : bool = false
@export var debug_enable_position_recording : bool = false
@export var debug_recording_name : String = "demo_sample"
@export var auto_sequence : AutoPlayerInputSequence = null

@export var state_machine : PlayerStateMachine
@export var collisions : PlayerCollisions
@export var buffers : PlayerBuffers
@export var movement : PlayerMovement
@export var jumping : PlayerJumping
@export var fairy : PlayerFairy
@export var attacks : PlayerAttacks
@export var temper : PlayerTemper
@export var form : PlayerForm
@export var damage : PlayerDamage
@export var interaction : PlayerInteraction
@export var stomp : PlayerStomp
@export var animation : PlayerAnimation
@export var sprite_trail : PlayerSpriteTrail
@export var camera : PlayerCamera
@export var audio : AudioHandler

@export var char_body : CharacterBody2D
@export var char_sprite : AnimatedSprite2D
@export var collision_shape : CollisionShape2D
@export var stream_player : AudioStreamPlayer2D
@export var visibility : VisibleOnScreenNotifier2D

@export var raycast_dl : RayCast2D
@export var raycast_dm : RayCast2D
@export var raycast_dr : RayCast2D
@export var raycast_ledge_l : RayCast2D
@export var raycast_ledge_r : RayCast2D

@export var raycast_ul : RayCast2D
@export var raycast_um : RayCast2D
@export var raycast_ur : RayCast2D
@export var raycast_ceiling_l : RayCast2D
@export var raycast_ceiling_r : RayCast2D

@export var raycast_wall_top_l : RayCast2D
@export var raycast_wall_mid_l : RayCast2D
@export var raycast_wall_bot_l : RayCast2D
@export var raycast_wall_top_r : RayCast2D
@export var raycast_wall_mid_r : RayCast2D
@export var raycast_wall_bot_r : RayCast2D

var current_respawn_position : Vector2 = Vector2.ZERO

var is_deactivated : bool = false

var force_stand : bool = false

var is_auto_mode_active : bool = false

var current_auto_input_vector : Vector2 = Vector2.ZERO

var current_auto_sequence_index : int = -1

var current_auto_frame_timer : int = 0

var prev_auto_input_dictionary : Dictionary = {"Move Left": false, "Move Right": false, "Move Up": false, "Move Down": false, "Jump": false, "Glide": false, "Attack": false, "Change Form": false, "Crouch": false, "Fairy Ability": false, "Interact": false}

var current_auto_input_dictionary : Dictionary = {"Move Left": false, "Move Right": false, "Move Up": false, "Move Down": false, "Jump": false, "Glide": false, "Attack": false, "Change Form": false, "Crouch": false, "Fairy Ability": false, "Interact": false}

var is_recording_inputs : bool = false

var current_recording : AutoPlayerInputSequence

func _ready():
	if (auto_sequence != null):
		if (auto_sequence.starting_mode != self.form.current_mode):
			self.form.change_mode(auto_sequence.starting_mode)
		is_auto_mode_active = true
		set_respawn_position(self.char_body.global_position)

func _process(_delta):
	OptionsHelper.update_control_options(self)
	read_auto_sequence()
	if (debug_enable_input_recording and Input.is_action_just_pressed("Record Inputs")):
		if (!is_recording_inputs):
			start_recording_inputs()
		else:
			stop_recording_inputs()
	record_auto_sequence()

func get_input_vector():
	var input_vector = Vector2.ZERO
	
	if (force_stand):
		return input_vector
	
	if (!is_auto_mode_active):
		input_vector.x = ((1 if Input.is_action_pressed("Move Right") or Input.is_action_pressed("Move Right (Pad)") else 0) - (1 if Input.is_action_pressed("Move Left") or Input.is_action_pressed("Move Left (Pad)") else 0))
		input_vector.y = ((1 if Input.is_action_pressed("Move Up") or Input.is_action_pressed("Move Up (Pad)") else 0) - (1 if Input.is_action_pressed("Move Down") or Input.is_action_pressed("Move Down (Pad)") else 0))
	else:
		input_vector.x = ((1 if self.is_action_pressed("Move Right") else 0) - (1 if self.is_action_pressed("Move Left") else 0))
		input_vector.y = ((1 if self.is_action_pressed("Move Up") else 0) - (1 if self.is_action_pressed("Move Down") else 0))
	
	return input_vector

func set_auto_input_vector(v : Vector2):
	current_auto_input_vector = Vector2.ZERO
	if (is_auto_mode_active):
		current_auto_input_vector = v

func is_action_just_pressed(action_name : StringName):
	if (!is_auto_mode_active):
		return Input.is_action_just_pressed(action_name)
	else:
		return (prev_auto_input_dictionary.has(action_name) and current_auto_input_dictionary.has(action_name) and !prev_auto_input_dictionary[action_name] and current_auto_input_dictionary[action_name])

func is_action_pressed(action_name : StringName):
	if (!is_auto_mode_active):
		return Input.is_action_pressed(action_name)
	else:
		return (current_auto_input_dictionary.has(action_name) and current_auto_input_dictionary[action_name])

func is_action_just_released(action_name : StringName):
	if (!is_auto_mode_active):
		return Input.is_action_just_released(action_name)
	else:
		return (prev_auto_input_dictionary.has(action_name) and current_auto_input_dictionary.has(action_name) and prev_auto_input_dictionary[action_name] and !current_auto_input_dictionary[action_name])

func set_respawn_position(pos : Vector2):
	current_respawn_position = pos

func do_respawn():
	char_body.global_position = current_respawn_position

func set_deactivation(b : bool):
	is_deactivated = b

func set_force_stand(b : bool):
	force_stand = b

func play_auto_sequence(s : AutoPlayerInputSequence):
	reset_auto_input_dictionary()
	prev_auto_input_dictionary = current_auto_input_dictionary.duplicate(true)
	auto_sequence = s
	current_auto_sequence_index = 0
	set_auto_input_dictionary(auto_sequence.frames[0])
	if (auto_sequence.starting_mode != self.form.current_mode):
		self.form.change_mode(auto_sequence.starting_mode)
	is_auto_mode_active = true

func stop_auto_sequence():
	reset_auto_input_dictionary()
	prev_auto_input_dictionary = current_auto_input_dictionary.duplicate(true)
	do_respawn()

func turn_off_auto_mode():
	reset_auto_input_dictionary()
	prev_auto_input_dictionary = current_auto_input_dictionary.duplicate(true)
	is_auto_mode_active = false

func read_auto_sequence():
	if (auto_sequence != null and is_auto_mode_active and current_auto_sequence_index < auto_sequence.frames.size()):
		prev_auto_input_dictionary = current_auto_input_dictionary.duplicate(true)
		if (current_auto_frame_timer > 0):
			current_auto_frame_timer -= 1
		else:
			current_auto_sequence_index += 1
			if (current_auto_sequence_index >= auto_sequence.frames.size()):
				if (!auto_sequence.loop):
					reset_auto_input_dictionary()
					is_auto_mode_active = !auto_sequence.resume_player_control
					return
				else:
					current_auto_sequence_index = 0
					if (auto_sequence.starting_mode != self.form.current_mode):
						self.form.change_mode(auto_sequence.starting_mode)
					if (auto_sequence.loop_from_starting_position):
						do_respawn()
			set_auto_input_dictionary(auto_sequence.frames[current_auto_sequence_index])
		var position_list_index : int = auto_sequence.get_position_list_index(current_auto_sequence_index, current_auto_frame_timer)
		if (position_list_index >= 0):
			self.char_body.global_position = auto_sequence.position_list[position_list_index]

func record_auto_sequence():
	if (!is_recording_inputs):
		return
	
	var new_frame : AutoPlayerInputFrame = AutoPlayerInputFrame.new()
	new_frame.duration = 1
	new_frame.left = (self.get_input_vector().x < 0)
	new_frame.right = (self.get_input_vector().x > 0)
	new_frame.up = (self.get_input_vector().y > 0)
	new_frame.down = (self.get_input_vector().y < 0)
	new_frame.jump = Input.is_action_pressed("Jump")
	new_frame.glide = Input.is_action_pressed("Glide")
	new_frame.attack = Input.is_action_pressed("Attack")
	new_frame.change = Input.is_action_pressed("Change Form")
	new_frame.crouch = Input.is_action_pressed("Crouch")
	new_frame.fairy = Input.is_action_pressed("Fairy Ability")
	new_frame.interact = Input.is_action_pressed("Interact")
	
	if (!current_recording.frames.is_empty() and current_recording.frames.back().is_equal_to(new_frame)):
		current_recording.frames.back().duration += 1
	else:
		current_recording.frames.push_back(new_frame)
	
	if (debug_enable_position_recording):
		current_recording.position_list.push_back(self.char_body.global_position)

func start_recording_inputs():
	current_recording = AutoPlayerInputSequence.new()
	current_recording.starting_mode = self.form.current_mode
	is_recording_inputs = true

func stop_recording_inputs():
	is_recording_inputs = false
	var save_result = ResourceSaver.save(current_recording, "res://Scripts/Resource Scripts/AutoPlayerInput/%s.tres" % debug_recording_name)
	if (save_result != OK):
		print_debug(save_result)

func reset_auto_input_dictionary():
	current_auto_sequence_index = auto_sequence.frames.size()
	current_auto_input_dictionary["Move Left"] = false
	current_auto_input_dictionary["Move Right"] = false
	current_auto_input_dictionary["Move Up"] = false
	current_auto_input_dictionary["Move Down"] = false
	current_auto_input_dictionary["Jump"] = false
	current_auto_input_dictionary["Glide"] = false
	current_auto_input_dictionary["Attack"] = false
	current_auto_input_dictionary["Change Form"] = false
	current_auto_input_dictionary["Crouch"] = false
	current_auto_input_dictionary["Fairy Ability"] = false
	current_auto_input_dictionary["Interact"] = false

func set_auto_input_dictionary(new_frame : AutoPlayerInputFrame):
	current_auto_frame_timer = new_frame.duration
	current_auto_input_dictionary["Move Left"] = new_frame.left
	current_auto_input_dictionary["Move Right"] = new_frame.right
	current_auto_input_dictionary["Move Up"] = new_frame.up
	current_auto_input_dictionary["Move Down"] = new_frame.down
	current_auto_input_dictionary["Jump"] = new_frame.jump
	current_auto_input_dictionary["Glide"] = new_frame.glide
	current_auto_input_dictionary["Attack"] = new_frame.attack
	current_auto_input_dictionary["Change Form"] = new_frame.change
	current_auto_input_dictionary["Crouch"] = new_frame.crouch
	current_auto_input_dictionary["Fairy Ability"] = new_frame.fairy
	current_auto_input_dictionary["Interact"] = new_frame.interact

func reset_player():
	movement.reset_crouch_state()
	movement.reset_current_horizontal_velocity()
	char_body.velocity = Vector2.ZERO
	jumping.landing_reset()
	fairy.reset_starting_magic()
	fairy.reset_fairy()
	form.change_to_starting_mode()
	temper.set_starting_temper_level()
	stomp.reset_stomp_combo()
