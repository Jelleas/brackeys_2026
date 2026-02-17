extends Node2D

@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var voice_player: AudioStreamPlayer = $WizardVoice
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_matcher_scene: PackedScene = preload("res://label_matcher/label_matcher.tscn")

@export var health: int = 100
@export var max_health: int = 100

var _time_to_block: float = 2.0
var _block_words: Array[String] = ["shield", "block", "guard", "ward", "parry"]
var _is_blocking: bool = false
var _attacking_monster: Monster
var _block_timer: Timer
var _current_matcher: LabelMatcher

var _default_anim: String = "idle"
var _hit_anim: String = "hit"
var _spell_anim: String = "spell"

func _ready():
	Bus.spell_matched.connect(_on_spell_matched)
	Bus.monster_attacked.connect(_on_monster_attacked)
	Bus.monster_killed.connect(_on_monster_killed)
	anim.animation_finished.connect(_on_anim_finished)
	
	health_bar.max_value = max_health
	health_bar.value = health
	_create_healthbar()
	
	_block_timer = Timer.new()
	_block_timer.one_shot = true
	_block_timer.timeout.connect(_on_block_timeout)
	add_child(_block_timer)

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

func _start_block() -> void:
	_is_blocking = true

	var word = _block_words.pick_random()
	_current_matcher = label_matcher_scene.instantiate()
	_current_matcher.instantiate(word, _on_block_success)
	add_child(_current_matcher)
	_current_matcher.position = Vector2(-60, -80)

	_block_timer.wait_time = _time_to_block
	_block_timer.start()

func _end_block() -> void:
	_is_blocking = false
	_block_timer.stop()
	if _current_matcher:
		_current_matcher.queue_free()
		_current_matcher = null

func _on_block_success() -> void:
	_end_block()

func _on_block_timeout() -> void:
	_end_block()
	if is_instance_valid(_attacking_monster):
		_take_damage(_attacking_monster.damage)

func _take_damage(dmg: int) -> void:
	health -= dmg
	health_bar.value = health
	if health <= 0:
		health = 0
		Bus.wizard_killed.emit()
	else:
		_play_hit_sound()
		anim.play(_hit_anim)

func _play_hit_sound():
	voice_player.play()

func _on_monster_killed(monster: Monster) -> void:
	if _is_blocking and monster == _attacking_monster:
		_end_block()

func _on_monster_attacked(monster: Monster) -> void:
	if _is_blocking:
		_take_damage(monster.damage)
		return
	_attacking_monster = monster
	_start_block()
	
func _on_anim_finished() -> void:
	if anim.animation != _default_anim:
		anim.play(_default_anim)
