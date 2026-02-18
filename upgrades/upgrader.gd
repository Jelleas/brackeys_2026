extends PanelContainer

class_name Upgrader

var _upgrade_labels: Array[UpgradeLabelPair] = []

var _active_spell_names: Array[String] = [
	SpellConfigs.Pila.postfix.name,
	SpellConfigs.Fulminis.postfix.name,
	SpellConfigs.Imbris.postfix.name,
	SpellConfigs.Fluctus.postfix.name,
	SpellConfigs.Bombamagnamala.postfix.name,
]

var is_active: bool = false

var all_active_upgrades: Array[Upgrade] = [];

func _ready():
	var scene: PackedScene = preload("res://label_matcher/label_matcher.tscn")
	
	var dummy_upgrades = [
		Convert.generate_buff(_active_spell_names),
		Convert.generate_buff(_active_spell_names),
		Convert.generate_buff(_active_spell_names)
	]
	
	for upgrade in dummy_upgrades:
		var label_matcher: LabelMatcher = scene.instantiate()
		_upgrade_labels.append(UpgradeLabelPair.new(
			label_matcher,
			_on_upgrade_matched, 
			_on_upgrade_timeout
		))
		_upgrade_labels[-1].set_upgrade(upgrade)
		_upgrade_labels[-1].deactivate()
		$VBoxContainer.add_child(label_matcher)

	Bus.new_spell_names.connect(_on_new_spell_names)
	Bus.spawn_upgrade.connect(_on_spawn_upgrade)

func _on_spawn_upgrade(is_buff: bool):
	var upgrade = generate_buff() if is_buff else generate_debuff()
	
	is_active = true

	# if there is a spot, spawn an upgrade
	for pair in _upgrade_labels:
		if not pair.is_active:
			pair.set_upgrade(upgrade)
			break

func _on_new_spell_names(spell_names: Array[String]):
	_active_spell_names = spell_names

func _on_upgrade_matched(upgrade: Upgrade):
	if not is_active:
		return
	
	if upgrade.is_buff:
		all_active_upgrades.append(upgrade)
	
	for pair in _upgrade_labels:
		if pair.upgrade == upgrade:
			pair.deactivate()
	
	if upgrade.is_buff:
		Bus.new_upgrades_active.emit(all_active_upgrades)

func _on_upgrade_timeout(upgrade: Upgrade):
	if not upgrade.is_buff:
		all_active_upgrades.append(upgrade)
		
	for pair in _upgrade_labels:
		if pair.upgrade == upgrade:
			pair.deactivate()
	
	if not upgrade.is_buff:
		Bus.new_upgrades_active.emit(all_active_upgrades)
		
func generate_buff(_targets: Array[SpellConfigs.Prefix] = []) -> Upgrade:
	return [
		Convert.generate_buff
	].pick_random().call(_active_spell_names, _targets)

func generate_debuff(_targets: Array[SpellConfigs.Prefix] = []) -> Upgrade:
	return [
		Convert.generate_debuff,
		Add.generate_debuff,
		Repeat.generate_debuff
	].pick_random().call(_active_spell_names, _targets)

class UpgradeLabelPair:
	var upgrade: Upgrade
	var label_matcher: LabelMatcher
	var is_active: bool
	var on_upgrade_matched: Callable
	var on_upgrade_timeout: Callable
	
	func _init(
		_label_matcher: LabelMatcher,
		_on_upgrade_matched: Callable,
		_on_upgrade_timeout: Callable
	):
		is_active = true
		label_matcher = _label_matcher
		on_upgrade_matched = _on_upgrade_matched
		on_upgrade_timeout = _on_upgrade_timeout
		
	func set_upgrade(_upgrade: Upgrade):
		is_active = true
		upgrade = _upgrade

		label_matcher.instantiate(
			upgrade.activation, 
			on_upgrade_matched.bind(upgrade),
			Color(0.3, 1.0, 0.3) if upgrade.is_buff else Color(1.0, 0.2, 0.2)
		)

		label_matcher.start_timer(25, on_upgrade_timeout.bind(upgrade))
		label_matcher.show()

	func deactivate():
		is_active = false
		label_matcher.hide()
		label_matcher.stop_timer()

class Upgrade:
	var activation: String
	var targets: Array[SpellConfigs.Prefix]
	var is_buff: bool
	
	func apply(text: String) -> String:
		assert(false)
		return ""

class Convert extends Upgrade:
	var from: String
	var to: String
	
	func _init(_from: String, _to: String, _is_buff: bool, _targets: Array[SpellConfigs.Prefix] = []):
		from = _from
		to = _to
		is_buff = _is_buff
		activation = from + " to " + to
		if targets:
			for t in targets:
				activation += " in " + t.name
		
	func apply(text: String) -> String:
		return text.replace(from, to)
		
	static func generate_buff(spell_names: Array[String], _targets: Array[SpellConfigs.Prefix] = []) -> Convert:
		var word: String = spell_names.pick_random()

		# 20% replace a single letter
		if (randi() % 5) == 0:
			var from_char := word.substr(randi() % word.length(), 1)
			var to_char := from_char
			while to_char == from_char:
				var w2: String = spell_names.pick_random()
				to_char = w2.substr(randi() % w2.length(), 1)
			return Convert.new(from_char, to_char, true, _targets)

		# 80% replace longer substring with a shorter substring
		var from_len := 2
		var max_from_len := word.length()
		if max_from_len > 2:
			var w := pow(randf(), 2.0) # bias toward 0
			from_len = 2 + int(floor(w * (max_from_len - 1))) # 2..max_from_len, shorter more likely
		else:
			from_len = max_from_len # length 1–2 words, just use full

		var from_start := randi() % (word.length() - from_len + 1)
		var from_sub := word.substr(from_start, from_len)

		var to_len := 1 + randi() % (from_len - 1)
		var to_start := randi() % (from_sub.length() - to_len + 1)
		var to_sub := from_sub.substr(to_start, to_len)

		return Convert.new(from_sub, to_sub, true, _targets)
	
	static func generate_debuff(spell_names: Array[String], _targets: Array[SpellConfigs.Prefix] = []) -> Convert:
		var word: String = spell_names.pick_random()

		var max_from_len: int = max(1, word.length() - 1)
		var from_len := 1
		if max_from_len > 1:
			var w := pow(randf(), 2.0)
			from_len = 1 + int(floor(w * max_from_len))

		var from_start := randi() % (word.length() - from_len + 1)
		var from_sub := word.substr(from_start, from_len)

		var extra_len := 1 + int(randi() % (from_len + 3))
		var to_len := from_len + extra_len
		var to_sub: String = Upgrader._random_string(to_len)

		return Convert.new(from_sub, to_sub, false, _targets)

class Add extends Upgrade:
	var addition: String
	
	func _init(_addition: String, _targets: Array[SpellConfigs.Prefix] = []):
		addition = _addition
		is_buff = false
		targets = _targets
		activation = "add " + addition
		if targets:
			for t in targets:
				activation += " in " + t.name

	static func generate_debuff(spell_names: Array[String], _targets: Array[SpellConfigs.Prefix] = []) -> Add:
		var _addition: String = Upgrader._random_string(randi() % 3 + 1)
		return Add.new(_addition, _targets)

	func apply(text: String) -> String:
		return text + addition
		
class Repeat extends Upgrade:
	var repetition: String

	func _init(_repetition: String, _targets: Array[SpellConfigs.Prefix] = []):
		repetition = _repetition
		is_buff = false
		targets = _targets
		activation = "repeat " + repetition
		if targets:
			for t in targets:
				activation += " in " + t.name
		
	static func generate_debuff(spell_names: Array[String], _targets: Array[SpellConfigs.Prefix] = []) -> Repeat:
		var _word: String = spell_names.pick_random()
		var _repetition: String = _word[randi() % _word.length()]
		return Repeat.new(_repetition, _targets)
		
	func apply(text: String) -> String:
		return text.replace(repetition, repetition + repetition)
		
static func _random_string(length: int) -> String:
	var vowels := "aeiou"
	var consonants := "bcdfghjklmnpqrstvwxyz"

	var result := ""
	var last_was_vowel := false
	var vowel_count := 0

	for i in range(length):
		var remaining := length - i

		# Ensure we don't end up with too few vowels overall
		var need_vowel := vowel_count == 0 and remaining <= 3

		var use_vowel := false
		if need_vowel:
			use_vowel = true
		elif last_was_vowel:
			# After a vowel, prefer consonant
			use_vowel = randf() < 0.35
		else:
			# After a consonant, prefer vowel
			use_vowel = randf() < 0.65

		var c := ""
		if use_vowel:
			c = vowels[randi() % vowels.length()]
			last_was_vowel = true
			vowel_count += 1
		else:
			c = consonants[randi() % consonants.length()]
			last_was_vowel = false

		result += c

	return result
