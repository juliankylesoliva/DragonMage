extends Breakable

class_name Fyerlarm

@export var anim_sprite : AnimatedSprite2D

@export var soundwave_sprite : AnimatedSprite2D

@export var audio_stream_player : AudioStreamPlayer2D

@export var windup_duration : float = 2

@export var attack_duration : float = 1

@export var cooldown_duration : float = 3

@export var enemy_knockback_strength : float = 512

@export var soundwave_scale_curve : Curve

@export var windup_sound : AudioStream

@export var attack_sound : AudioStream

@export var starting_windup_pitch : float = 1

@export var target_windup_pitch : float = 3

@export_color_no_alpha var windup_color : Color = Color.WHITE

@export_color_no_alpha var cooldown_color : Color = Color.WHITE

var bodies_in_hitbox : Array

var current_state : int = 0

var state_timer : float = 0

func _process(delta):
	do_state_process(delta)

func set_to_state(num : int):
	match num:
		0:
			current_state = num
			can_enemy_projectiles_hit = true
			anim_sprite.play("Idle")
			anim_sprite.modulate = Color.WHITE
			state_timer = 0
		1:
			current_state = num
			can_enemy_projectiles_hit = false
			anim_sprite.play("Windup")
			SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
			audio_stream_player.stream = windup_sound
			audio_stream_player.pitch_scale = 1
			audio_stream_player.play()
			state_timer = windup_duration
		2:
			current_state = num
			anim_sprite.play("Attack")
			audio_stream_player.stream = attack_sound
			audio_stream_player.pitch_scale = 1
			audio_stream_player.play()
			anim_sprite.modulate = Color.WHITE
			state_timer = attack_duration
		3:
			current_state = num
			anim_sprite.play("Cooldown")
			audio_stream_player.stop()
			anim_sprite.modulate = cooldown_color
			state_timer = cooldown_duration
		_:
			current_state = num
			can_enemy_projectiles_hit = true
			anim_sprite.play("Idle")
			anim_sprite.modulate = Color.WHITE
			state_timer = 0

func do_state_process(delta : float):
	if (state_timer > 0):
		state_timer = move_toward(state_timer, 0, delta)
	
	match current_state:
		1:
			anim_sprite.modulate = lerp(Color.WHITE, windup_color, (windup_duration - state_timer) / windup_duration)
			audio_stream_player.pitch_scale = lerpf(starting_windup_pitch, target_windup_pitch, (windup_duration - state_timer) / windup_duration)
			if (state_timer <= 0):
				set_to_state(2)
		2:
			resolve_hitbox_bodies()
			soundwave_sprite.scale = (soundwave_scale_curve.sample((attack_duration - state_timer) / attack_duration) * Vector2.ONE)
			if (state_timer <= 0):
				set_to_state(3)
		3:
			if (state_timer <= 0):
				set_to_state(0)
		_:
			set_to_state(0)

func resolve_hitbox_bodies():
	for body in bodies_in_hitbox:
		if (body.has_meta("Tag") and body.get_meta("Tag") == "Enemy" and (body is Enemy)):
			var temp_enemy : Enemy = (body as Enemy)
			if(temp_enemy.defeat_enemy("HAZARD")):
				temp_enemy.body.velocity += (enemy_knockback_strength * (temp_enemy.body.global_position - self.global_position).normalized())
		elif (body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
			var player_temp : PlayerHub = null
		
			for child in body.get_children():
				if (child is PlayerHub):
					player_temp = (child as PlayerHub)
					break
			
			if (player_temp != null and player_temp.damage.can_take_damage()):
				var direction = (player_temp.char_body.global_position.x - global_position.x)
				direction = (1.0 if direction >= 0 else -1.0)
				if (player_temp.damage.take_damage(direction, true)):
					SoundFactory.play_sound_by_name("enemy_contact_impact", player_temp.char_body.global_position)
					EffectFactory.get_effect("EnemyContactImpact", player_temp.char_body.global_position)
				elif (player_temp.damage.is_player_parrying()):
					state_timer = 0
				else:
					pass
		else:
			pass

func break_object(other : Object):
	if (current_state == 0):
		return super.break_object(other)
	return false

func do_break():
	if (current_state == 0):
		set_to_state(1)
		on_break.emit()

func _on_attack_area_body_entered(body):
	if (!bodies_in_hitbox.has(body)):
		bodies_in_hitbox.append(body)

func _on_attack_area_body_exited(body):
	if (bodies_in_hitbox.has(body)):
		bodies_in_hitbox.erase(body)
