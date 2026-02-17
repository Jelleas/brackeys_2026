extends Node2D

class_name MonsterSpawner

@export var monster_scene: PackedScene
@export var max_visible: int = 4
@export var slot_start_position: Vector2
@export var slot_spacing: float = 200
@export var queue_size: int = 10

var monster_queue: Array[MonsterConfigs.MonsterType] = []
var visible_monsters: Array = []

func _ready() -> void:
	Bus.monster_killed.connect(_on_monster_killed)

func spawn(configs: Array[MonsterConfigs.MonsterType]) -> void:
	monster_queue = configs
	_fill_slots()

func _fill_slots() -> void:
	while visible_monsters.size() < max_visible and not monster_queue.is_empty():
		var config = monster_queue.pop_front()
		var monster = monster_scene.instantiate()
		monster.init(config)
		var index = visible_monsters.size()
		monster.position = slot_start_position + Vector2(index * slot_spacing, 0)
		add_child(monster)
		visible_monsters.append(monster)
	_update_front_attacker()
	_disable_monster_hit_box()

func _reposition_monsters() -> void:
	for i in range(visible_monsters.size()):
		var target_pos = slot_start_position + Vector2(i * slot_spacing, 0)
		var tween = visible_monsters[i].create_tween()
		tween.tween_property(visible_monsters[i], "position", target_pos, 0.3)

func _update_front_attacker() -> void:
	for monster in visible_monsters:
		if is_instance_valid(monster):
			monster.stop_attacking()
	if visible_monsters.size() > 0 and is_instance_valid(visible_monsters[0]):
		visible_monsters[0].start_attacking()

func get_front_slot_global_position() -> Vector2:
	return global_position + slot_start_position

func get_second_slot_global_position() -> Vector2:
	if visible_monsters.size() >= 2:
		return visible_monsters[1].global_position
	return get_front_slot_global_position()

func _disable_monster_hit_box() -> void:
	for monster in visible_monsters:
		if is_instance_valid(monster):
			monster.get_node("MonsterBody/CollisionShape2D").set_deferred("disabled", false)
	if visible_monsters.size() >= max_visible and is_instance_valid(visible_monsters[max_visible - 1]):
		visible_monsters[max_visible - 1].get_node("MonsterBody/CollisionShape2D").set_deferred("disabled", true)

func _on_monster_killed(monster: Monster) -> void:
	var index = visible_monsters.find(monster)
	if index == -1:
		return
	visible_monsters.remove_at(index)
	monster.queue_free()
	_reposition_monsters()
	_disable_monster_hit_box()
	_update_front_attacker()
	call_deferred("_fill_slots")
