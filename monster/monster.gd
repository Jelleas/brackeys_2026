extends Node2D

class_name Monster

@onready var monster_body: Area2D = $MonsterBody
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var voice_player: AudioStreamPlayer = $MonsterVoice
@onready var anim: AnimatedSprite2D = $MonsterBody/AnimatedSprite2D

var health: int = 100
var original_modulate: Color
var config: MonsterConfigs.MonsterType
var damage: int = 10
var is_dead: bool = false
var attack_timer: Timer
var foreshadow_timer: Timer

func _ready() -> void:
	original_modulate = modulate
	
	monster_body.collision_layer = 1
	monster_body.collision_mask = 2
	monster_body.set_deferred("monitoring", true)
	monster_body.set_deferred("monitorable", true)
	monster_body.add_to_group("monster")
	health_bar.max_value = config.health
	health_bar.value = config.health
	
	_create_healthbar()
	_create_resistance_bar()
	
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer)
	foreshadow_timer = Timer.new()
	foreshadow_timer.one_shot = true
	foreshadow_timer.timeout.connect(_on_foreshadow_timer)
	anim.animation_finished.connect(_on_animation_finished)
	add_child(attack_timer)
	add_child(foreshadow_timer)

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

func _create_resistance_bar() -> void:
	var container = $ResistanceTracker
	container.size.y = 16
	container.position = Vector2(-50, -85)
	
	for prefix in config.resistances:
		var tex_rect = TextureRect.new()
		var tex = GradientTexture2D.new()
		tex.width = 16
		tex.height = 16
		tex.gradient = Gradient.new()
		tex.gradient.colors = PackedColorArray([prefix.color1, prefix.color1])
		tex_rect.texture = tex
		tex_rect.custom_minimum_size = Vector2(16, 16)
		container.add_child(tex_rect)

func init(_config: MonsterConfigs.MonsterType):
	config = _config
	health = config.health
	damage = config.damage

func get_hit(spell: SpellConfigs.Spell):
	if is_dead:
		return
	take_damage(spell)

func take_damage(spell: SpellConfigs.Spell):
	var damage = spell.get_damage()
	if spell.prefix.name in config.resistances.map(func(res): return res.name):
		damage = damage / 2
		
	health -= damage
	health_bar.value = health
	_play_hit_sound()
	if(health <= 0):
		anim.play("death")
		is_dead = true
		Bus.monster_killed.emit(self)
	else:
		anim.play("hit")

func _play_hit_sound():
	voice_player.play()

func start_attacking() -> void:
	foreshadow_timer.wait_time = config.attack_interval
	attack_timer.wait_time = 2.0
	foreshadow_timer.start()

func stop_attacking() -> void:
	attack_timer.stop()
	foreshadow_timer.stop()

func _on_attack_timer() -> void:
	if is_dead:
		return
	anim.play("attack")
	Bus.monster_attacked.emit(self)
	foreshadow_timer.start()
	
func _on_foreshadow_timer() -> void:
	if is_dead:
		return
	Bus.monster_foreshadow_attack.emit(self)
	attack_timer.start()
	
func _on_animation_finished():
	if anim.animation != "death":
		anim.play("idle")
