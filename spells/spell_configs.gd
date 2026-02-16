class_name SpellConfigs

static func get_spell(prefix_name: String, postfix_name: String) -> Spell:
	var spell_class = [Pila, Fulminis, Imbris, Fluctus, Bombamagnamala].filter(
		func (c): return c.postfix.name == postfix_name
	)[0]
	
	var prefix = _prefixes.filter(
		func (p): return p.name == prefix_name
	)[0]
	
	return spell_class.new(prefix)
	
class Spell:
	var prefix: Prefix
	var name: String
	var _base_damage: int
	var scene: PackedScene
	
	func _init(_prefix: Prefix):
		assert(false)

	func get_damage() -> int:
		return int(_base_damage * prefix.damage_multiplier)

class Pila extends Spell:
	static var postfix: Postfix = Postfix.new("pila")
	
	func _init(_prefix: Prefix):
		prefix = _prefix
		_base_damage = 20
		scene = preload("res://spells/ball/ball.tscn")
		name = prefix.name + " " + postfix.name
		
class Fulminis extends Spell:
	static var postfix: Postfix = Postfix.new("fulminis")
	
	func _init(_prefix: Prefix):
		prefix = _prefix
		_base_damage = 40
		scene = preload("res://spells/bolt/bolt.tscn")
		name = prefix.name + " " + postfix.name

class Imbris extends Spell:
	static var postfix: Postfix = Postfix.new("imbris")

	func _init(_prefix: Prefix):
		prefix = _prefix
		_base_damage = 30
		scene = preload("res://spells/rain/rain.tscn")
		name = prefix.name + " " + postfix.name

class Fluctus extends Spell:
	static var postfix: Postfix = Postfix.new("fluctus")

	func _init(_prefix: Prefix):
		prefix = _prefix
		_base_damage = 30
		scene = preload("res://spells/wave/wave.tscn")
		name = prefix.name + " " + postfix.name
		
class Bombamagnamala extends Spell:
	static var postfix: Postfix = Postfix.new("bombamagnamala")

	func _init(_prefix: Prefix):
		prefix = _prefix
		_base_damage = 75
		scene = preload("res://spells/ball/ball.tscn")
		name = prefix.name + " " + postfix.name

class Prefix:
	var name: String
	var color1: Color
	var color2: Color
	var color3: Color
	var damage_multiplier: float
	
	func _init(_name: String, _color1: Color, _color2: Color, _color3: Color, _damage_multiplier := 1.0) -> void:
		name = _name
		color1 = _color1
		color2 = _color2
		color3 = _color3
		damage_multiplier = _damage_multiplier

class Postfix:
	var name: String
	
	func _init(_name):
		name = _name

static func get_postfixes() -> Array[Postfix]:
	var postfixes: Array[Postfix] = []
	
	for c in [Pila, Fulminis, Imbris, Fluctus, Bombamagnamala]:
		postfixes.append(c.postfix)
	
	return postfixes

static func get_prefixes() -> Array[Prefix]:
	return _prefixes

static var _prefixes: Array[Prefix] = [
	Prefix.new("lux", Color("#FFFFAA"), Color("#cc7b1f"), Color("#c2a840")),
	Prefix.new("nox", Color("#1B3A3B"), Color("#0a3233"), Color("#032829")),
	Prefix.new("sol", Color("#9e4731"), Color("#FF6600"), Color("#CC2200")),
	Prefix.new("vis", Color("#9ecf74"), Color("#5d8c34"), Color("#214006")),
	Prefix.new("nix", Color("#dee8d5"), Color("#9fb5b2"), Color("#5c6967"))
]


	
