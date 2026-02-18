extends Node

class_name SignalBus

signal key_typed(typed: String)
signal spell_matched(spell: SpellConfigs.Spell)
signal prefix_matched(prefix: String)
signal postfix_failed()

signal monster_killed(monster: Monster)
signal monster_attacked(monster: Monster)
signal wizard_killed()

signal new_upgrades_active(upgrades: Array[Upgrader.Upgrade])
signal new_spell_names(spell_names: Array[String])

signal spawn_upgrade(is_buff: bool)

signal new_game()
signal tutorial_over()

signal next_tutorial_step()
