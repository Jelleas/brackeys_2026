extends PanelContainer

var upgrade: Upgrader.Upgrade

var _match: String = ""

func instantiate(_upgrade: Upgrader.Upgrade):
	upgrade = _upgrade
	$UpgradeItemLabel.text = upgrade.activation

func _ready():
	Bus.key_typed.connect(_on_key_typed)

func _on_key_typed(key: String):
	if key == " ":
		return
	
	if upgrade.activation.substr(len(_match))[0] == " ":
		_match += " "
	
	_match += key
	
	if not upgrade.activation.begins_with(_match):
		_match = ""

	if _match == upgrade.activation:
		on_match()
	else:
		_set_label()

func _set_label():	
	var correct_color: Color = Color.GREEN
	var incorrect_color: Color = Color.BLACK

	var result: String = "[color=%s]%s[/color]" % [correct_color.to_html(), _match]

	var remainder: String = upgrade.activation.substr(len(_match))
	result += "[color=%s]%s[/color]" % [incorrect_color.to_html(), remainder]
	$UpgradeItemLabel.text = result

func on_match():
	# TODO
	_set_label()
	_match = ""
