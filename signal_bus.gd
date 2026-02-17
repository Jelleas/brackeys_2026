extends Node

class_name SignalBus

signal key_typed(typed: String)
signal spell_matched(spell: SpellConfigs.Spell)

signal monster_killed(monster: Monster)
signal monster_attacked(monster: Monster)
signal wizard_killed()

signal new_game()
