extends PanelContainer

@export var spell_part_scene: PackedScene

var _prefixes: Array[String] = ["lux", "nox", "sol", "vis", "nix"]
var _postfixes: Array[String] = ["pila", "fulminis", "imbris", "fluctus", "dyslexia", "bombamagnamala"]

var prefix_parts: Array[SpellPart] = []
var postfix_parts: Array[SpellPart] = []

var active_prefix: String = "";

func _ready():
	Bus.key_typed.connect(_on_key_typed)
	initialize_spells()

func initialize_spells() -> void:
	for prefix in _prefixes:
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(prefix, [])
		
		$HBoxContainer/PrefixVBoxContainer.add_child(spell_part)

		prefix_parts.append(spell_part)

	for postfix in _postfixes:
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(postfix, _prefixes)
		
		$HBoxContainer/PostfixVBoxContainer.add_child(spell_part)

		postfix_parts.append(spell_part)

func _on_key_typed(character: String):
	var new_prefix_activated = false
	
	for prefix_part in prefix_parts:
		var result_state: SpellPart.MatchState = prefix_part.on_new_letter(character)
		
		if result_state == SpellPart.MatchState.Succeeded:
			active_prefix = prefix_part._word_to_match
			new_prefix_activated = true
	
	if new_prefix_activated:
		for postfix_part in postfix_parts:
			postfix_part.on_new_prefix(active_prefix)
	else:
		var any_pending = false
		var any_succeeded = false
		
		for postfix_part in postfix_parts:
			var result_state = postfix_part.on_new_letter(character)
			
			if result_state == SpellPart.MatchState.Pending:
				any_pending = true
			elif result_state == SpellPart.MatchState.Succeeded:
				any_succeeded = true

		if active_prefix and (any_succeeded or not any_pending):
			_full_reset()			
	
func _full_reset():
	active_prefix = ""
	for prefix_part in prefix_parts:
		prefix_part = prefix_part.unlock()
	
	for postfix_part in postfix_parts:
		postfix_part.on_reset_prefix()
