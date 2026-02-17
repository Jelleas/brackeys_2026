extends PanelContainer

class_name Upgrader

var _upgrades: Array[Upgrade] = [
	Convert.new("o", "a"),
	Convert.new("bomba", "b"),
	Add.new("kip", [SpellConfigs.get_prefixes()[0]])
]

var _active_spell_names: Array[String] = [
	SpellConfigs.Pila.postfix.name,
	SpellConfigs.Fulminis.postfix.name,
	SpellConfigs.Imbris.postfix.name,
	SpellConfigs.Fluctus.postfix.name,
	SpellConfigs.Bombamagnamala.postfix.name,
]

var is_active: bool = true

var label_matchers: Array[LabelMatcher] = []

var all_active_upgrades: Array[Upgrade] = [];

func _ready():
	var scene: PackedScene = preload("res://label_matcher/label_matcher.tscn")
	
	for upgrade in _upgrades.slice(0, 3):
		var upgrade_item: LabelMatcher = scene.instantiate()
		upgrade_item.instantiate(upgrade.activation, _on_upgrade_matched.bind(upgrade))
		$VBoxContainer.add_child(upgrade_item)
		label_matchers.append(upgrade_item)

	Bus.new_spell_names.connect(_on_new_spell_names)
	Bus.spawn_upgrade.connect(_on_spawn_upgrade)
	
func _set_upgrades():
	if is_active:
		for i in range(3):
			var label_matcher = label_matchers[i]
			var upgrade = _upgrades[i]
			label_matcher.instantiate(upgrade.activation, _on_upgrade_matched.bind(upgrade))
			label_matcher.show()
	else:
		for label_matcher in label_matchers:
			label_matcher.hide()

func _on_spawn_upgrade(n_buffs: int, n_debuffs: int):
	var buffs: Array[Upgrade] = []
	for i in range(n_buffs):
		buffs.append(generate_buff())
	
	var debuffs: Array[Upgrade] = []
	for i in range(n_debuffs):
		debuffs.append(generate_debuff())
	
	_upgrades = buffs + debuffs
	_upgrades.shuffle()
	
	is_active = true
	
	_set_upgrades()

func _on_new_spell_names(spell_names: Array[String]):
	_active_spell_names = spell_names

func _on_upgrade_matched(upgrade: Upgrade):
	if not is_active:
		return
	
	all_active_upgrades.append(upgrade)
	is_active = false
	_set_upgrades()
	Bus.new_upgrades_active.emit(all_active_upgrades)

func generate_buff() -> Upgrade:
	return [
		Convert.new("o", "a"), 
		Convert.new("bomba", "b")
	].pick_random()

func generate_debuff() -> Upgrade:
	return [
		Add.new("kip", [SpellConfigs.get_prefixes()[0]])
	].pick_random()

class Upgrade:
	var activation: String
	var targets: Array[SpellConfigs.Prefix]
	
	func apply(text: String) -> String:
		assert(false)
		return ""

class Convert extends Upgrade:
	var from: String
	var to: String
	
	func _init(_from: String, _to: String, _targets: Array[SpellConfigs.Prefix] = []):
		from = _from
		to = _to
		activation = "convert " + from + " to " + to
		if targets:
			for t in targets:
				activation += " in " + t.name
		
	func apply(text: String) -> String:
		return text.replace(from, to)

class Add extends Upgrade:
	var addition: String
	
	func _init(_addition: String, _targets: Array[SpellConfigs.Prefix] = []):
		addition = _addition
		targets = _targets
		activation = "add " + addition
		if targets:
			for t in targets:
				activation += " in " + t.name

	func apply(text: String) -> String:
		return text + addition
