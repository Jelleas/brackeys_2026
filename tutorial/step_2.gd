extends CanvasLayer

var prefix_target: Rect2 = Rect2(395, 385, 80, 50)
var postfix_target: Rect2 = Rect2(790, 385, 100, 50)

func start():
	Bus.prefix_matched.connect(_on_prefix_matched)
	Bus.postfix_failed.connect(_on_postfix_failed)
	Bus.spell_matched.connect(_on_spell_matched)

	_highlight_prefix()
	show()

func _highlight_prefix():
	$Spotlight.instantiate(prefix_target)
	$Spotlight.show()
	
func _highlight_postfix():
	$Spotlight.instantiate(postfix_target)
	$Spotlight.show()

func stop():
	Bus.next_tutorial_step.emit()
	queue_free()

func _on_prefix_matched(prefix: String):
	if prefix.to_lower() == "lux":
		_highlight_postfix()

func _on_postfix_failed():
	_highlight_prefix()

func _on_spell_matched(spell: SpellConfigs.Spell):
	if spell.prefix.name.to_lower() == "lux" and spell.postfix.name.to_lower() == "pila":
		stop()
