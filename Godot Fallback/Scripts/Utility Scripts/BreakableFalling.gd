extends Breakable

class_name BreakableFalling

const REINFORCED_ARRAY_INDEX : int = 3

const ANY_TYPE_ARRAY_INDEX : int = 0

const MAGIC_TYPE_ARRAY_INDEX : int = 1

const FIRE_TYPE_ARRAY_INDEX : int = 2

const SUMMON_PREFIX : String = "Summon"

const BREAKABLE_DURABILITY : int = 1

const REINFORCED_DURABILITY : int = 2

const BREAKABLE_SOUND : String = "object_block_breakable"

const REINFORCED_SOUND : String = "object_block_reinforced"

@export var fragments_list : Array[PackedScene]

@export var sprite_anim : AnimatedSprite2D

@export var visible_on_screen : VisibleOnScreenNotifier2D

@export var audio_stream_player : AudioStreamPlayer2D

@export var gravity_scale : float = 2

@export var max_fall_speed : float = 320

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_velocity : Vector2 = Vector2.ZERO

var player_ref : PlayerHub = null

func _ready():
	self.set_visible(false)

func _physics_process(delta: float):
	if (self.visible and !sprite_anim.is_playing()):
		current_velocity.y = move_toward(current_velocity.y, max_fall_speed, base_gravity * gravity_scale * delta)
		self.global_position += (current_velocity * delta)
		
		if (player_ref != null and player_ref.damage.can_take_damage()):
			var direction = (player_ref.char_body.global_position.x - global_position.x)
			direction = (1.0 if direction >= 0 else -1.0)
			if (player_ref.damage.take_damage(direction)):
				SoundFactory.play_sound_by_name("enemy_contact_impact", player_ref.char_body.global_position)
				EffectFactory.get_effect("EnemyContactImpact", player_ref.char_body.global_position)
				self.do_break()
			elif (player_ref.damage.is_player_parrying()):
				self.do_break()
			else:
				pass
		
		if (!visible_on_screen.is_on_screen()):
			self.queue_free()

func setup(reinforced : bool = false, type : String = "ANY"):
	self.set_visible(true)
	match type:
		"MAGIC":
			if (reinforced):
				fragments_scene = fragments_list[REINFORCED_ARRAY_INDEX + MAGIC_TYPE_ARRAY_INDEX]
				sprite_anim.play("SummonReinforcedMagic")
			else:
				fragments_scene = fragments_list[MAGIC_TYPE_ARRAY_INDEX]
				sprite_anim.play("SummonBreakableMagic")
			breakable_by = type
		"FIRE":
			if (reinforced):
				fragments_scene = fragments_list[REINFORCED_ARRAY_INDEX + FIRE_TYPE_ARRAY_INDEX]
				sprite_anim.play("SummonReinforcedFire")
			else:
				fragments_scene = fragments_list[FIRE_TYPE_ARRAY_INDEX]
				sprite_anim.play("SummonBreakableFire")
			breakable_by = type
		"ANY":
			if (reinforced):
				fragments_scene = fragments_list[REINFORCED_ARRAY_INDEX]
				sprite_anim.play("SummonReinforced")
			else:
				fragments_scene = fragments_list[ANY_TYPE_ARRAY_INDEX]
				sprite_anim.play("SummonBreakable")
			breakable_by = type
		_:
			if (reinforced):
				fragments_scene = fragments_list[REINFORCED_ARRAY_INDEX]
				sprite_anim.play("SummonReinforced")
			else:
				fragments_scene = fragments_list[ANY_TYPE_ARRAY_INDEX]
				sprite_anim.play("SummonBreakable")
			breakable_by = "ANY"
	break_durablility = (REINFORCED_DURABILITY if reinforced else BREAKABLE_DURABILITY)
	break_sound = (REINFORCED_SOUND if reinforced else BREAKABLE_SOUND)
	audio_stream_player.play()

func break_object(other : Object):
	if (self.visible):
		super.break_object(other)

func _on_attack_area_body_entered(body: Node2D):
	if (player_ref == null and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		for child in body.get_children():
			if (child is PlayerHub):
				player_ref = (child as PlayerHub)
				break

func _on_attack_area_body_exited(body: Node2D):
	if (player_ref != null and body.has_meta("Tag") and body.get_meta("Tag") == "Player"):
		player_ref = null
