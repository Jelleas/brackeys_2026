extends Node

class_name WaveManager

@export var spawner: MonsterSpawner
@export var monsters_per_wave: int = 5
@export var wave_delay: float = 3.0

var current_wave: int = 0
var monsters_remaining: int = 0

func _ready() -> void:
	Bus.monster_killed.connect(_on_monster_killed)
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	var configs: Array[MonsterConfigs.MonsterType] = _build_wave()
	monsters_remaining = configs.size()
	spawner.spawn(configs)

func _build_wave() -> Array[MonsterConfigs.MonsterType]:
	var all_monsters = MonsterConfigs.get_monsters()
	var configs: Array[MonsterConfigs.MonsterType] = []
	for i in range(monsters_per_wave):
		var random_index = randi_range(0, all_monsters.size() - 1)
		configs.append(all_monsters[random_index].new())
	return configs

func _on_monster_killed(_monster: Monster) -> void:
	monsters_remaining -= 1
	if monsters_remaining <= 0:
		_on_wave_complete()

func _on_wave_complete() -> void:
	await get_tree().create_timer(wave_delay).timeout
	start_next_wave()
