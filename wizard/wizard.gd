extends Node2D

@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var voice_player: AudioStreamPlayer = $WizardVoice
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var health: int = 100
@export var max_health: int = 100

var _default_anim: String = "idle"
var _hit_anim: String = "hit"
var _spell_anim: String = "spell"

func _ready():
	Bus.spell_matched.connect(_on_spell_matched)
	Bus.monster_attacked.connect(_on_monster_attacked)
	anim.animation_finished.connect(_on_anim_finished)
	
	health_bar.max_value = max_health
	health_bar.value = health
	
	_create_healthbar()

func _create_healthbar() -> void:
	var under_tex = GradientTexture2D.new()
	under_tex.width = 100
	under_tex.height = 10
	under_tex.gradient = Gradient.new()
	under_tex.gradient.colors = PackedColorArray([Color(0.2, 0.2, 0.2), Color(0.2, 0.2, 0.2)])
	health_bar.texture_under = under_tex

	var progress_tex = GradientTexture2D.new()
	progress_tex.width = 100
	progress_tex.height = 10
	progress_tex.gradient = Gradient.new()
	progress_tex.gradient.colors = PackedColorArray([Color(0.8, 0.1, 0.1), Color(0.8, 0.1, 0.1)])
	health_bar.texture_progress = progress_tex

	health_bar.position = Vector2(-50, 70)
	health_bar.size = Vector2(100, 10)

func cast(spell: SpellConfigs.Spell):
	var spawner = get_parent().get_node("MonsterSpawner") as MonsterSpawner
	var target_pos: Vector2
	if spell is SpellConfigs.Bombamagnamala:
		target_pos = spawner.get_second_slot_global_position()
	else:
		target_pos = spawner.get_front_slot_global_position()

	var projectile = spell.scene.instantiate()
	projectile.init(spell, target_pos)
	add_child(projectile)
	anim.play(_spell_anim)

func _on_spell_matched(spell: SpellConfigs.Spell):
	cast(spell)

func _play_hit_sound():
	voice_player.play()

func _on_monster_attacked(dmg: int) -> void:
	health -= dmg
	health_bar.value = health
	if health <= 0:
		health = 0
		Bus.wizard_killed.emit()
	else:
		_play_hit_sound()
		anim.play(_hit_anim)
	
func _on_anim_finished() -> void:
	if anim.animation != _default_anim:
		anim.play(_default_anim)