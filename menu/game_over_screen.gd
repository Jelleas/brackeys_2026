extends CanvasLayer

func _ready() -> void:
	$PanelContainer/VBoxContainer/Continue.instantiate("Retry", _on_continue)
	
func _on_continue() -> void:
	print("Retrying")