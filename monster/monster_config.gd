class_name MonsterConfigs

static func get_monster(monster_name: String) -> MonsterType:
	var monster_class = [Test, Test2].filter(
		func(c): return c.monster_name == monster_name
	)[0]
	return monster_class.new()

static func get_monsters() -> Array:
	return [Test, Test2]

class MonsterType:
	var name: String
	var health: int
	var damage: int
	var resistances: Array[SpellConfigs.Prefix]
	var experience: int
	var attack_interval: float

	func _init():
		assert(false)

class Test extends MonsterType:
	static var monster_name: String = "test"

	func _init():
		name = "test"
		health = 100
		damage = 10
		resistances = [SpellConfigs.get_prefix("lux")]
		experience = 10
		attack_interval = 2.0

class Test2 extends MonsterType:
	static var monster_name: String = "test2"

	func _init():
		name = "test2"
		health = 50
		damage = 20
		resistances = [SpellConfigs.get_prefix("nox")]
		experience = 5
		attack_interval = 2.0
