class_name LabelMatcher extends PanelContainer

var _string_to_match: String

var _match: String = ""
var _on_match_callback: Callable

func instantiate(string_to_match: String, on_match_callback: Callable):
	_string_to_match = string_to_match
	$LabelMatcherLabel.text = string_to_match
	_on_match_callback = on_match_callback

func _ready():
	Bus.key_typed.connect(_on_key_typed)

func _on_key_typed(key: String) -> void:
	if key == " ":
		return
	
	# You get spaces for free, no need to type them
	while _string_to_match.substr(len(_match))[0] == " ":
		_match += " "
	
	_match += key
	
	if not _string_to_match.begins_with(_match):
		_match = ""

	if _match == _string_to_match:
		on_match()
	else:
		_set_label()

func _set_label():	
	var correct_color: Color = Color.GREEN
	var incorrect_color: Color = Color.BLACK

	var result: String = "[color=%s]%s[/color]" % [correct_color.to_html(), _match]

	var remainder: String = _string_to_match.substr(len(_match))
	result += "[color=%s]%s[/color]" % [incorrect_color.to_html(), remainder]
	$LabelMatcherLabel.text = result

func on_match():
	_on_match_callback.call()
	_match = ""
	_set_label()
