extends CanvasLayer

@onready var _continue_matcher: LabelMatcher = $PanelContainer/VBoxContainer/Continue

func _ready() -> void:
	visible = false
	_continue_matcher.instantiate("Retry", _on_continue)
	_continue_matcher.stop_listening()
	Bus.wizard_killed.connect(_on_wizard_killed)
	
func _on_continue() -> void:
	Bus.new_game.emit()
	var tween: Tween = create_tween()
	tween.tween_property($PanelContainer, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(func(): visible = false)
	_continue_matcher.stop_listening()
	
func _on_wizard_killed() -> void:
	visible = true
	$PanelContainer.modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property($PanelContainer, "modulate", Color.WHITE, 0.2)
	_continue_matcher.start_listening()
