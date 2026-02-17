extends PanelContainer

@export var spell_part_scene: PackedScene

var prefix_parts: Array[SpellPart] = []
var postfix_parts: Array[SpellPart] = []

var active_prefix: String = "";

func _ready():
	Bus.key_typed.connect(_on_key_typed)		
	Bus.new_upgrades_active.connect(_on_new_upgrades_active)

	Bus.register_tutorial.emit("Here you see your spells. Combine a word from the left page with a word from the right page.", self, 3)
	Bus.register_tutorial.emit("Words on the left of the page affect the type of the spell. Some monsters are resistant to some types", self, 4)
	initialize_spells()

func initialize_spells() -> void:
	for prefix in SpellConfigs.get_prefixes():
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(prefix.name, [])
		
		$MarginContainer/HBoxContainer/PrefixVBoxContainer.add_child(spell_part)

		prefix_parts.append(spell_part)

	for postfix in SpellConfigs.get_postfixes():
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(postfix.name, SpellConfigs.get_prefixes())
		
		$MarginContainer/HBoxContainer/PostfixVBoxContainer.add_child(spell_part)

		postfix_parts.append(spell_part)

func _on_new_upgrades_active(upgrades: Array[Upgrader.Upgrade]):
	for spell_part in postfix_parts:
		spell_part.on_new_upgrades_active(upgrades)
		
	var spell_names: Array[String]
	for spell_part in postfix_parts:
		spell_names.append(spell_part._word_to_match)

	Bus.new_spell_names.emit(spell_names)

func _on_key_typed(character: String):
	var new_prefix_activated: bool = false
	
	for prefix_part in prefix_parts:
		var result_state: SpellPart.MatchState = prefix_part.on_new_letter(character)
		
		if result_state == SpellPart.MatchState.Succeeded:
			active_prefix = prefix_part._word_to_match
			new_prefix_activated = true
	
	if new_prefix_activated:
		for postfix_part in postfix_parts:
			postfix_part.on_new_prefix(active_prefix)
	else:
		var any_pending: bool = false
		var any_succeeded: bool = false
		
		for postfix_part in postfix_parts:
			var result_state: SpellPart.MatchState = postfix_part.on_new_letter(character)
			
			if result_state == SpellPart.MatchState.Pending:
				any_pending = true
			elif result_state == SpellPart.MatchState.Succeeded:
				any_succeeded = true
				var spell = SpellConfigs.get_spell(active_prefix, postfix_part.original_word)
				Bus.spell_matched.emit(spell)
				_on_spell_matched()

		if active_prefix and (any_succeeded or not any_pending):
			_on_failed_postfix()
	
func _on_failed_postfix():
	active_prefix = ""
	for prefix_part in prefix_parts:
		prefix_part = prefix_part.unlock()
	
	for postfix_part in postfix_parts:
		postfix_part.on_reset_prefix()

func _on_spell_matched():
	active_prefix = ""
	for prefix_part in prefix_parts:
		prefix_part.reset()
	
	for postfix_part in postfix_parts:
		postfix_part.reset()
	
