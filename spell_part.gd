class_name SpellPart extends RichTextLabel

var is_matching: bool = false
var _match: String = ""
var _word_to_match: String
var _prefixes_required: Array[String]

func instantiate(word_to_match: String, prefixes_required: Array[String]) -> void:
	_word_to_match = word_to_match
	
	if prefixes_required.is_empty():
		is_matching = true;
		
	_set_label()

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
	var correct_color = Color.GREEN
	var incorrect_color = Color.GRAY
	
	var result = "[color=%s]%s[/color]" % [correct_color.to_html(), _match]
	
	var remainder = _word_to_match.substr(len(_match))
	result += "[color=%s]%s[/color]" % [incorrect_color.to_html(), remainder]
	
	print(result)
	self.text = result

func on_match():
	_match = ""
	_set_label()
		
enum MatchState {
	Failed, Succeeded, Pending, Disabled
}
