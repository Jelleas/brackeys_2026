class_name SpellPart extends RichTextLabel

var is_prefix_part: bool = false
var is_matching: bool = false
var original_word: String
var _match: String = ""
var _word_to_match: String
var _prefixes_required: Array[String]

var _lock: bool = false

func _ready():
	# Wait one frame so the Control knows its final size
	await get_tree().process_frame
	pivot_offset = size / 2.0
	
	Bus.new_upgrades_active.connect(_on_new_upgrades_active)

func instantiate(word_to_match: String, prefixes_required: Array[SpellConfigs.Prefix]) -> void:
	original_word = word_to_match
	_word_to_match = original_word
	
	if prefixes_required.is_empty():
		is_matching = true
		is_prefix_part = true
		
	_prefixes_required = []
	for p in prefixes_required:
		_prefixes_required.append(p.name)
	_set_label()

func reset():
	_lock = false
	_match = ""
	
	if is_prefix_part:
		is_matching = true
	else:
		is_matching = false
	
	_set_label()

func unlock():
	if _lock:
		_lock = false
		_reset_match()

func _on_new_upgrades_active(upgrades: Array[Upgrader.Upgrade]) -> void:
	if is_prefix_part:
		return
	
	var relevant_upgrades: Array[Upgrader.Upgrade] = []
	for upgrade in upgrades:
		if upgrade.targets == [] or self.is_matching:
			relevant_upgrades.append(upgrade)
	
	if not relevant_upgrades:
		return
	
	_word_to_match = original_word
	for upgrade in relevant_upgrades:
		_word_to_match = upgrade.apply(_word_to_match)

	_reset_match()

func on_reset_prefix() -> void:
	if not is_prefix_part:
		is_matching = false
	_reset_match()

func on_new_prefix(prefix: String) -> void:
	is_matching = _prefixes_required.has(prefix)
	_reset_match()

func on_new_letter(letter: String) -> MatchState:
	if _lock:
		return MatchState.Locked
	
	if not is_matching:
		return MatchState.Disabled
	
	_match += letter
	
	if not _word_to_match.begins_with(_match):	
		if not is_prefix_part:
			is_matching = false;
			_reset_match()
			return MatchState.Failed
		elif _word_to_match.begins_with(letter):
			_match = letter
			_set_label()
			return MatchState.Pending
		else:
			_reset_match()
			return MatchState.Failed
	
	if _match == _word_to_match:
		on_match()
		return MatchState.Succeeded
	else:
		_set_label()
		return MatchState.Pending
		
func _reset_match():
	_match = ""
	_set_label()
		
func _set_label():	
	var correct_color: Color = Color.GREEN
	var incorrect_color: Color = Color.BLACK

	var result: String = "[color=%s]%s[/color]" % [correct_color.to_html(), _match]

	var remainder: String = _word_to_match.substr(len(_match))
	result += "[color=%s]%s[/color]" % [incorrect_color.to_html(), remainder]
	self.text = result

func on_match():
	_set_label()
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	if not is_prefix_part:
		tween.tween_callback(_reset_match)
	else:
		_lock = true


enum MatchState {
	Failed, Succeeded, Pending, Disabled, Locked
}
