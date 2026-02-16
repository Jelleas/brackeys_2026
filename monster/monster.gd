extends Node2D

class_name Monster

@onready var monster_body: Area2D = $MonsterBody
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var voice_player = $MonsterVoice

var health: int = 100
var original_modulate: Color
var config: MonsterConfig
var damage: int = 10
var is_dead: bool = false
var attack_timer: Timer

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
	
	var sprite = $MonsterBody/Sprite2D
	var collision_shape = $MonsterBody/CollisionShape2D
	var tex_size = sprite.texture.get_size() * sprite.scale
	var shape = collision_shape.shape as CapsuleShape2D
	shape.radius = tex_size.x / 2.0
	shape.height = tex_size.y
	
	attack_timer = Timer.new()
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer)
	add_child(attack_timer)

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

func init(_config: MonsterConfig):
	config = _config
	health = config.health
	damage = config.damage

func get_hit(incoming_hit: int):
	if is_dead:
		return
	take_damage(incoming_hit)

func take_damage(damage: int):
	health -= damage
	health_bar.value = health
	_play_hit_sound()
	if(health <= 0):
		is_dead = true
		Bus.monster_killed.emit(self)

func _play_hit_sound():
	voice_player.play()

func start_attacking() -> void:
	attack_timer.wait_time = config.attack_interval
	attack_timer.start()

func stop_attacking() -> void:
	attack_timer.stop()

func _on_attack_timer() -> void:
	if is_dead:
		return
	Bus.monster_attacked.emit(damage)
