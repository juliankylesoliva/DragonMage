extends Interactable

@export var textbox : Textbox

@export var sprite : AnimatedSprite2D

@export_multiline var textbox_strings : Array[String]

@export var num_blink_animations : int = 3

@export var min_blink_time : float = 3

@export var max_blink_time : float = 4

var current_blink_timer : float = 0

func _process(_delta):
	if (textbox != null):
		if (player != null):
			button_prompt.set_visible(textbox.current_state == Textbox.TextboxState.READY)

func _physics_process(delta):
	if (player != null):
		var x_diff : float = (player.char_body.global_position.x - self.global_position.x)
		if (x_diff != 0):
			sprite.set_flip_h(x_diff < 0)
	
	update_blink_timer(delta)
	if (!sprite.is_playing()):
		if (!check_blink_animation()):
			sprite.play("KnigelStand")

func interact(hub : PlayerHub):
	if (player != null and hub == player):
		if (textbox != null):
			if (textbox.current_state == Textbox.TextboxState.READY):
				for s in textbox_strings:
					textbox.queue_text(TextPromptParser.parse_text(s))
			else:
				textbox.advance_textbox()

func on_player_exited():
	if (textbox != null):
		textbox.clear_all_text()

func check_blink_animation():
	if (num_blink_animations <= 0):
		return false
	
	if (current_blink_timer <= 0):
		var blink_anim_num = (randi() % num_blink_animations)
		sprite.play("KnigelStandBlink{num}".format({"num": blink_anim_num}))
		set_blink_timer()
		return true
	
	return false

func update_blink_timer(delta):
	if (num_blink_animations <= 0):
		return
	
	current_blink_timer = move_toward(current_blink_timer, 0, delta)

func set_blink_timer():
	current_blink_timer = randf_range(min_blink_time, max_blink_time)
