extends Breakable

class_name BreakableCycle

@export var room_ref : Room

@export var fragments_scene_magic : PackedScene = null

@export var fragments_scene_fire : PackedScene = null

@export var anim_sprite : AnimatedSprite2D

@export var on_screen : VisibleOnScreenNotifier2D

@export_enum("MAGIC", "FIRE") var starting_type : String = "MAGIC"

@export var cycle_interval : float = 1

var current_cycle_time : float = 0

func _ready():
	anim_sprite.animation_finished.connect(_on_animation_finished)
	if (room_ref != null):
		room_ref.room_activated.connect(initialize)
	initialize()

func _physics_process(delta):
	if (room_ref != null and room_ref.is_room_active):
		if (current_cycle_time > 0):
			current_cycle_time = move_toward(current_cycle_time, 0, delta)
			if (current_cycle_time <= 0):
				if (breakable_by == "MAGIC"):
					anim_sprite.play("ReinforcedMagicToFire" if break_durablility > 1 else "BreakableMagicToFire")
					if (on_screen.is_on_screen()):
						SoundFactory.play_sound_by_name("transformation_draelyn", node_2d.global_position, -6, 2)
					breakable_by = "FIRE"
				else:
					anim_sprite.play("ReinforcedFireToMagic" if break_durablility > 1 else "BreakableFireToMagic")
					if (on_screen.is_on_screen()):
						SoundFactory.play_sound_by_name("transformation_magli", node_2d.global_position, -6, 2)
					breakable_by = "MAGIC"

func do_break():
	SoundFactory.play_sound_by_name(break_sound, node_2d.global_position, -4)
	if (fragments_scene_magic != null and fragments_scene_fire != null and fragments_scene != null):
		var instance = null
		match breakable_by:
			"MAGIC":
				instance = fragments_scene_magic.instantiate()
			"FIRE":
				instance = fragments_scene_fire.instantiate()
			_:
				instance = fragments_scene.instantiate()
		add_sibling(instance)
		(instance as Node2D).global_position = node_2d.global_position
		(instance as CPUParticles2D).emitting = true
	on_break.emit()
	queue_free()

func initialize():
	match starting_type:
		"MAGIC":
			anim_sprite.play("ReinforcedMagic" if break_durablility > 1 else "BreakableMagic")
			breakable_by = "MAGIC"
		"FIRE":
			anim_sprite.play("ReinforcedFire" if break_durablility > 1 else "BreakableFire")
			breakable_by = "FIRE"
		_:
			anim_sprite.play("Reinforced" if break_durablility > 1 else "Breakable")
			breakable_by = "ANY"
	current_cycle_time = cycle_interval

func _on_animation_finished():
	match anim_sprite.animation:
		"BreakableMagicToFire":
			anim_sprite.play("BreakableFire")
			current_cycle_time = cycle_interval
		"BreakableFireToMagic":
			anim_sprite.play("BreakableMagic")
			current_cycle_time = cycle_interval
		"ReinforcedMagicToFire":
			anim_sprite.play("ReinforcedFire")
			current_cycle_time = cycle_interval
		"ReinforcedFireToMagic":
			anim_sprite.play("ReinforcedMagic")
			current_cycle_time = cycle_interval
		_:
			pass
