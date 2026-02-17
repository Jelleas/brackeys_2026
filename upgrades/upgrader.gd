extends PanelContainer

class_name Upgrader

var _upgrades: Array[Upgrade] = [
	Convert.new("o", "a"),
	Convert.new("bomba", "b"),
	Add.new("kip", [SpellConfigs.get_prefixes()[0]])
]

var all_active_upgrades: Array[Upgrade] = [];

func _ready():
	var scene: PackedScene = preload("res://label_matcher/label_matcher.tscn")
	
	Bus.register_tutorial.emit("Upgrades show up here. Do something with them.", self, 8)
	
	for upgrade in _upgrades.slice(0, 3):
		var upgrade_item: LabelMatcher = scene.instantiate()
		upgrade_item.instantiate(upgrade.activation, _on_upgrade_matched.bind(upgrade))
		$VBoxContainer.add_child(upgrade_item)

func _on_upgrade_matched(upgrade: Upgrade):
	all_active_upgrades.append(upgrade)
	Bus.new_upgrades_active.emit(all_active_upgrades)

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
