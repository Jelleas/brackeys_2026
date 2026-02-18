extends CanvasLayer

func start():
	Bus.prefix_matched.connect(_on_prefix_matched)
	Bus.postfix_failed.connect(_on_postfix_failed)
	Bus.spell_matched.connect(_on_spell_matched)

	_highlight_prefix()
	show()

func _highlight_prefix():
	var prefix: Rect2 = get_parent().get_parent().find_child("PrefixVBoxContainer").get_children()[0].get_global_rect()
	$Spotlight.instantiate(prefix)
	$Spotlight.show()
	
func _highlight_postfix():
	var postfix: Rect2 = get_parent().get_parent().find_child("PostfixVBoxContainer").get_children()[0].get_global_rect()
	$Spotlight.instantiate(postfix)
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
