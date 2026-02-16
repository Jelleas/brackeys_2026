class_name SpellConfigs

static func get_spell(prefix_name: String, postfix_name: String) -> Spell:
	return Spell.new(
		prefixes_by_name[prefix_name],
		postfixes_by_name[postfix_name]
	)

class Spell:
	var prefix: Prefix
	var postfix: Postfix
	
	func _init(_prefix: Prefix, _postfix: Postfix):
		prefix = _prefix
		postfix = _postfix
		
	func get_scene() -> PackedScene:
		return postfix.scene
		
	func get_damage() -> int:
		return int(postfix.base_damage * prefix.damage_multiplier)

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
	var scene: PackedScene
	var base_damage: int
	
	func _init(_name: String, _scene, _base_damage: int = 10) -> void:
		name = _name
		scene = _scene
		base_damage = _base_damage
	
static var prefixes: Array[Prefix] = [
	Prefix.new("lux", Color("#FFFFAA"), Color("#cc7b1f"), Color("#c2a840")),
	Prefix.new("nox", Color("#1B3A3B"), Color("#0a3233"), Color("#032829")),
	Prefix.new("sol", Color("#9e4731"), Color("#FF6600"), Color("#CC2200")),
	Prefix.new("vis", Color("#9ecf74"), Color("#5d8c34"), Color("#214006")),
	Prefix.new("nix", Color("#dee8d5"), Color("#9fb5b2"), Color("#5c6967"))
]

static var postfixes: Array[Postfix] = [
	Postfix.new("pila", preload("res://spells/ball/ball.tscn"), 20),
	Postfix.new("fulminis", preload("res://spells/bolt/bolt.tscn"), 40),
	Postfix.new("imbris", preload("res://spells/ball/ball.tscn"), 30),
	Postfix.new("fluctus", preload("res://spells/ball/ball.tscn"), 30),
	Postfix.new("bombamagnamala", preload("res://spells/ball/ball.tscn"), 75),
]

static var prefixes_by_name: Dictionary[String, Prefix] = associate_prefixes_by(prefixes, "name")
static var postfixes_by_name: Dictionary[String, Postfix] = associate_postfixes_by(postfixes, "name")

# Godot doesn't have generics so we need two of these functions or we get stuck with just Dictionary type
static func associate_prefixes_by(arr: Array, key_prop: String) -> Dictionary[String, Prefix]:
	var dict: Dictionary[String, Prefix] = {}
	for obj in arr:
		var key = obj[key_prop]
		dict[key] = obj
	return dict
	
static func associate_postfixes_by(arr: Array, key_prop: String) -> Dictionary[String, Postfix]:
	var dict: Dictionary[String, Postfix] = {}
	for obj in arr:
		var key = obj[key_prop]
		dict[key] = obj
	return dict
