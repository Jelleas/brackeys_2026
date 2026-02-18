class_name LabelMatcher extends PanelContainer

var _string_to_match: String
var _original_string: String

var _match: String = ""
var _on_match_callback: Callable
var _is_listening: bool = true

func instantiate(string_to_match: String, on_match_callback: Callable):
	_original_string = string_to_match
	_string_to_match = _original_string.to_lower()
	$LabelMatcherLabel.text = string_to_match
	_on_match_callback = on_match_callback

func start_timer(new_duration: float = -1.0):
	$LabelMatcherLabel/TimerBorder.start_timer(new_duration)

func start_listening(): 
	_is_listening = true
	
func stop_listening(): 
	_is_listening = false

func _ready():
	Bus.key_typed.connect(_on_key_typed)

func _on_key_typed(key: String) -> void:
	if not _is_listening: return
	
	if key == " ":
		return
	
	key = key.to_lower()
	
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

	var result: String = "[color=%s]%s[/color]" % [correct_color.to_html(), _original_string.substr(0, len(_match))]

	var remainder: String = _string_to_match.substr(len(_match))
	result += "[color=%s]%s[/color]" % [incorrect_color.to_html(), remainder]
	$LabelMatcherLabel.text = result

func on_match():
	_on_match_callback.call()
	_match = ""
	_set_label()
