class_name MonsterConfigs

static func get_monster(monster_name: String) -> MonsterType:
	var monster_class = [Test].filter(
		func(c): return c.monster_name == monster_name
	)[0]
	return monster_class.new()

static func get_monsters() -> Array:
	return [Test]

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
	static var monster_name: String = "test2"

	func _init():
		name = "test"
		health = 50
		damage = 5
		resistances = []
		experience = 1
		attack_interval = 5.0
