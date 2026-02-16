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

class Prefix:
	var name: String
	var color1: Color
	var color2: Color
	var color3: Color
	
	func _init(_name: String, _color1, _color2, _color3) -> void:
		name = _name
		color1 = _color1
		color2 = _color2
		color3 = _color3
		
class Postfix:
	var name: String
	var scene: PackedScene
	
	func _init(_name: String, _scene) -> void:
		name = _name
		scene = _scene
	
static var prefixes: Array[Prefix] = [
	Prefix.new("lux", Color("#FFFFAA"), Color("#FF6600"), Color("#CC2200")),
	Prefix.new("nox", Color("#1B3A3B"), Color("#0a3233"), Color("#032829")),
	Prefix.new("sol", Color("#9e4731"), Color("#cc7b1f"), Color("#c2a840")),
	Prefix.new("vis", Color("#9ecf74"), Color("#5d8c34"), Color("#214006")),
	Prefix.new("nix", Color("#dee8d5"), Color("#9fb5b2"), Color("#5c6967"))
]

static var postfixes: Array[Postfix] = [
	Postfix.new("pila", preload("res://spells/ball/ball.tscn")),
	Postfix.new("fulminis", preload("res://spells/bolt/bolt.tscn")),
	Postfix.new("imbris", preload("res://spells/ball/ball.tscn")),
	Postfix.new("fluctus", preload("res://spells/ball/ball.tscn")),
	Postfix.new("bombamagnamala", preload("res://spells/ball/ball.tscn")),
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
