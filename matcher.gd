class_name Matcher extends Node2D

var is_matching: bool = false
var _match: String = ""
var _word_to_match: String
var _prefixes_required: Array[String]

func _init(word_to_match: String, prefixes_required: Array[String]) -> void:
	_word_to_match = word_to_match

func on_prefix_match(prefix: String) -> void:
	is_matching = _prefixes_required.has(prefix)

func on_new_letter(letter: String) -> MatchState:
	if not is_matching: return MatchState.Disabled
	_match += letter
	if not _word_to_match.begins_with(_match):
		_match = ""
		return MatchState.Failed
		
	if _match == _word_to_match:
		return MatchState.Succeeded
	else:
		return MatchState.Pending
		
enum MatchState {
	Failed, Succeeded, Pending, Disabled
}
