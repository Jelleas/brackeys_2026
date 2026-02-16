extends PanelContainer

@export var spell_part_scene: PackedScene

var prefix_parts: Array[SpellPart] = []
var postfix_parts: Array[SpellPart] = []

var active_prefix: String = "";

func _ready():
	Bus.key_typed.connect(_on_key_typed)
	initialize_spells()

func initialize_spells() -> void:
	for prefix in SpellConfigs.prefixes:
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(prefix.name, [])
		
		$MarginContainer/HBoxContainer/PrefixVBoxContainer.add_child(spell_part)

		prefix_parts.append(spell_part)

	for postfix in SpellConfigs.postfixes:
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(postfix.name, SpellConfigs.prefixes)
		
		$MarginContainer/HBoxContainer/PostfixVBoxContainer.add_child(spell_part)

		postfix_parts.append(spell_part)

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
				Bus.spell_matched.emit(active_prefix, postfix_part._word_to_match)
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
	
