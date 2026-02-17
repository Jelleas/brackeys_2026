extends Node

class_name WaveManager

@export var spawner: MonsterSpawner
@export var monsters_per_wave: int = 5

var current_wave: int = 0
var monsters_remaining: int = 0

func _ready() -> void:
	Bus.monster_killed.connect(_on_monster_killed)
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	var monsters: Array[MonsterConfigs.MonsterType] = _build_wave()
	monsters_remaining = monsters.size()
	spawner.spawn(monsters)

func _build_wave() -> Array[MonsterConfigs.MonsterType]:
	var monsters: Array[MonsterConfigs.MonsterType] = []
	for i in range(monsters_per_wave):
		var monster = MonsterConfigs.get_monsters()[0].new()
		_apply_modifiers(monster)
		monsters.append(monster)

	return monsters

func _apply_modifiers(monster: MonsterConfigs.MonsterType) -> MonsterConfigs.MonsterType:
	var wave_modifier: float = 1.0 + current_wave * 0.1
	monster.health = int(monster.health * wave_modifier)
	monster.experience = int(monster.experience * wave_modifier)
	
	var tier: int = current_wave / 5
	var max_resistances: int = clampi(ceili(tier / 2.0), 0, 5)
	var chance: float = minf(tier * 0.15, 1.0)
	var resistances: Array[SpellConfigs.Prefix] = []
	var all_prefixes = SpellConfigs.get_prefixes()
	var available = all_prefixes.duplicate()

	for i in range(max_resistances):
		if randf() < chance and available.size() > 0:
			var idx = randi_range(0, available.size() - 1)
			monster.resistances.append(available[idx])
			available.remove_at(idx)

	return monster


func _on_monster_killed(_monster: Monster) -> void:
	monsters_remaining -= 1
	if monsters_remaining <= 0:
		_on_wave_complete()

func _on_wave_complete() -> void:
	start_next_wave()
