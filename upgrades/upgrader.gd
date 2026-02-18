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
	
	_on_spawn_upgrade(2, 1)
	
func _set_upgrades():
	if is_active:
		for i in range(3):
			var label_matcher = label_matchers[i]
			var upgrade = _upgrades[i]
			label_matcher.instantiate(upgrade.activation, _on_upgrade_matched.bind(upgrade))
			label_matcher.show()
			label_matcher.start_timer()
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
		Convert.generate_buff(_active_spell_names)
	].pick_random()

func generate_debuff() -> Upgrade:
	return [
		Convert.generate_debuff(_active_spell_names),
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
		
	static func generate_buff(spell_names: Array[String]) -> Convert:
		var word: String = spell_names.pick_random()

		# 20% replace a single letter
		if (randi() % 5) == 0:
			var from_char := word.substr(randi() % word.length(), 1)
			var to_char := from_char
			while to_char == from_char:
				var w2: String = spell_names.pick_random()
				to_char = w2.substr(randi() % w2.length(), 1)
			return Convert.new(from_char, to_char)

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

		return Convert.new(from_sub, to_sub)
	
	static func generate_debuff(spell_names: Array[String]) -> Convert:
		var word := spell_names[randi() % spell_names.size()]

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

		return Convert.new(from_sub, to_sub)

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
