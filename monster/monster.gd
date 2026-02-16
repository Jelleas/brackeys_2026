extends Node2D

class_name Monster

signal monster_killed(monster: Monster)

@onready var monster_body: Area2D = $MonsterBody
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var voice_player = $MonsterVoice

var health: int = 100
var original_modulate: Color
var config: MonsterConfig
var damage: int = 10
var is_dead: bool = false

func _ready() -> void:
	original_modulate = modulate
	
	monster_body.collision_layer = 1
	monster_body.collision_mask = 2
	monster_body.monitoring = true
	monster_body.monitorable = true
	monster_body.add_to_group("monster")
	health_bar.max_value = config.health
	health_bar.value = config.health
	
	var sprite = $MonsterBody/Sprite2D
	var collision_shape = $MonsterBody/CollisionShape2D
	var tex_size = sprite.texture.get_size() * sprite.scale
	var shape = collision_shape.shape as CapsuleShape2D
	shape.radius = tex_size.x / 2.0
	shape.height = tex_size.y

func get_hit(incoming_hit: int):
	take_damage(incoming_hit)

func init(_config: MonsterConfig):
	config = _config
	health = config.health
	damage = config.damage

func take_damage(damage: int):
	health -= damage
	health_bar.value = health
	_play_hit_sound()
	if(health <= 0):
		is_dead = true
		monster_killed.emit(self)
		$MonsterBody.queue_free()

func _play_hit_sound():
	voice_player.play()
