extends Label

func _init() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	if not event.is_pressed():
		return
	
	var keycode = event.keycode
	
	if (keycode < KEY_A || keycode > KEY_Z) && keycode != KEY_SPACE:
		return
		
	var character = String.chr(event.keycode)
	
	if not event.shift_pressed:
		character = character.to_lower()
	
	Bus.key_typed.emit(character)
	
