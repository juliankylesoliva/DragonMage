extends Breakable

class_name Turretome

enum TurretomeState {IDLE, ACTIVE, BURNED}

@export var ray_cast : RayCast2D

@export var on_screen_notifier : VisibleOnScreenNotifier2D

@export var anim_sprite : AnimatedSprite2D

@export var audio_stream_player : AudioStreamPlayer2D

@export var room_ref : Room

@export var magic_projectile_scene : PackedScene

@export var detection_range : float = 384

@export var attack_interval : float = 1

@export var burned_cooldown_duration : float = 5

@export var damage_type : String = "MAGIC"

var current_state : TurretomeState = TurretomeState.IDLE

var state_timer : float = 0

var player_ref : PlayerHub

func _process(delta: float):
	do_state_process(delta)

func set_to_state(state_enum : TurretomeState):
	match state_enum:
		TurretomeState.IDLE:
			current_state = TurretomeState.IDLE
			state_timer = 0
			anim_sprite.play("Idle")
			anim_sprite.modulate = Color.WHITE
		TurretomeState.ACTIVE:
			current_state = TurretomeState.ACTIVE
			state_timer = attack_interval
			anim_sprite.play("Active")
			anim_sprite.modulate = Color.WHITE
		TurretomeState.BURNED:
			current_state = TurretomeState.BURNED
			state_timer = burned_cooldown_duration
			anim_sprite.play("Idle")
			SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
			anim_sprite.modulate = Color.DARK_RED
		_:
			current_state = TurretomeState.IDLE
			state_timer = 0
			anim_sprite.play("Idle")
			anim_sprite.modulate = Color.WHITE

func do_state_process(delta : float):
	if (player_ref == null):
		get_player_ref()
	
	match current_state:
		TurretomeState.IDLE:
			if (player_ref.form.is_a_dragon() and is_player_in_range()):
				set_to_state(TurretomeState.ACTIVE)
		TurretomeState.ACTIVE:
			state_timer = move_toward(state_timer, 0, delta)
			if (state_timer <= 0):
				if (is_player_in_range()):
					spawn_projectile()
					state_timer = attack_interval
				else:
					set_to_state(TurretomeState.IDLE)
		TurretomeState.BURNED:
			state_timer = move_toward(state_timer, 0, delta)
			if (state_timer <= 0):
				set_to_state(TurretomeState.ACTIVE if player_ref.form.is_a_dragon() and is_player_in_range() else TurretomeState.IDLE)
		_:
			set_to_state(TurretomeState.IDLE)

func break_object(other : Object):
	if (current_state == TurretomeState.ACTIVE):
		return super.break_object(other)
	return false

func do_break():
	if (current_state == TurretomeState.ACTIVE):
		set_to_state(TurretomeState.BURNED)
		on_break.emit()

func get_player_ref():
	if (player_ref == null and room_ref != null and room_ref.level_ref != null and room_ref.level_ref.player_hub != null):
		player_ref = room_ref.level_ref.player_hub

func is_player_in_range():
	if (!room_ref.is_room_active or !on_screen_notifier.is_on_screen()):
		return
	
	if (player_ref != null):
		ray_cast.target_position = (player_ref.char_body.global_position - self.global_position)
		if (ray_cast.target_position.length() > detection_range):
			return false
		ray_cast.force_raycast_update()
		return !ray_cast.is_colliding()

func spawn_projectile():
	var temp_node : Node = magic_projectile_scene.instantiate()
	self.add_sibling(temp_node)
	var temp_projectile : EnemyProjectile = (temp_node as EnemyProjectile)
	temp_projectile.global_position = self.global_position
	temp_projectile.general_setup(ray_cast.target_position.normalized())
