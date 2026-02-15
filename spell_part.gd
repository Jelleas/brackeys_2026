class_name SpellPart extends RichTextLabel

var is_matching: bool = false
var _match: String = ""
var _word_to_match: String
var _prefixes_required: Array[String]

func instantiate(word_to_match: String, prefixes_required: Array[String]) -> void:
	_word_to_match = word_to_match
	
	if prefixes_required.is_empty():
		is_matching = true;

func on_prefix_match(prefix: String) -> void:
	is_matching = _prefixes_required.has(prefix)

func on_new_letter(letter: String) -> MatchState:
	if not is_matching:
		return MatchState.Disabled
	
	_match += letter
	
	if not _word_to_match.begins_with(_match):
		_match = ""
		
		if not _prefixes_required.is_empty():
			is_matching = false;

		_set_label()
		return MatchState.Failed
	
	if _match == _word_to_match:
		on_match()
		return MatchState.Succeeded
	else:
		_set_label()
		return MatchState.Pending
		
func _set_label():
	self.text = _match

func on_match():
	_match = ""
	_set_label()
		
enum MatchState {
	Failed, Succeeded, Pending, Disabled
}
