extends PanelContainer

@export var spell_part_scene: PackedScene

var _prefixes: Array[String] = ["lux"];
var _postfixes: Array[String] = [];

var prefix_parts: Array[SpellPart] = [];

func _ready():
	Bus.key_typed.connect(_on_key_typed)
	initialize_spells()
	

func initialize_spells() -> void:
	for prefix in _prefixes:
		var spell_part: SpellPart = spell_part_scene.instantiate()
		
		spell_part.instantiate(prefix, [])
		
		$HBoxContainer/PrefixVBoxContainer.add_child(spell_part)

		prefix_parts.append(spell_part)

func _on_key_typed(character: String):
	for prefix_part in prefix_parts:
		prefix_part.on_new_letter(character)
