extends Node2D

class_name MonsterSpawner

@export var monster_scene: PackedScene
@export var monster_configs: Array[MonsterConfig]

var active_monsters: Array[Monster]

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_new_monster)
	spawn_timer.start()
	
func spawn(config: MonsterConfig):
	var monster = monster_scene.instantiate()
	monster.init(config)
	add_child(monster)
	
	active_monsters.append(monster)
	
func _spawn_new_monster():
	var monster_config = _pick_random_monster()
	spawn(monster_config)
	
func _pick_random_monster():
	var random_index = randi_range(0, monster_configs.size() - 1)
	return monster_configs[random_index]
