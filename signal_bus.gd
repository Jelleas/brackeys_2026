extends Node

class_name SignalBus

signal key_typed(typed: String)
signal spell_matched(spell: SpellConfigs.Spell)

signal monster_killed(monster: Monster)
signal monster_attacked(monster: Monster)
signal wizard_killed()

signal new_upgrades_active(upgrades: Array[Upgrader.Upgrade])
signal new_spell_names(spell_names: Array[String])

signal spawn_upgrade(n_buffs: int, n_debuffs: int) # n_buffs + n_debuffs == 3
