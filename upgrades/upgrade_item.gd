extends PanelContainer

var upgrade: Upgrader.Upgrade

func instantiate(_upgrade: Upgrader.Upgrade):
	upgrade = _upgrade
	$RichTextLabel.text = upgrade.activation
