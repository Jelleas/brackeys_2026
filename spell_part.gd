class_name SpellPart extends RichTextLabel

var is_prefix_part = false
var is_matching: bool = false
var _match: String = ""
var _word_to_match: String
var _prefixes_required: Array[String]

var _lock = false

func instantiate(word_to_match: String, prefixes_required: Array[String]) -> void:
	_word_to_match = word_to_match
	
	if prefixes_required.is_empty():
		is_matching = true;
		is_prefix_part = true;
		
	_prefixes_required = prefixes_required
	_set_label()

func unlock():
	_lock = false
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
	var correct_color = Color.GREEN
	var incorrect_color = Color.GRAY

	var result = "[color=%s]%s[/color]" % [correct_color.to_html(), _match]

	var remainder = _word_to_match.substr(len(_match))
	result += "[color=%s]%s[/color]" % [incorrect_color.to_html(), remainder]
	self.text = result

func on_match():
	_set_label()
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector2(2, 2), 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	if not is_prefix_part:
		tween.tween_callback(_reset_match)
	else:
		_lock = true


enum MatchState {
	Failed, Succeeded, Pending, Disabled, Locked
}
