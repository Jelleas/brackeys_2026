extends Node2D

func _ready():
	Bus.spell_matched.connect(_on_spell_matched)

func cast(spell: SpellConfigs.Spell):
	var projectile = spell.scene.instantiate()
	projectile.init(spell)
	add_child(projectile)

func _on_spell_matched(spell: SpellConfigs.Spell):
	cast(spell)
