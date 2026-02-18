extends Container

var _position = Vector2(520, 260)
	
func start():
	global_position = _position
	$Continue.instantiate("Type this to start", _on_continue)
	$Spotlight.instantiate($Continue.get_global_rect())
	$Spotlight.show()
	show()

func stop():
	Bus.next_tutorial_step.emit()
	queue_free()

func _on_continue():
	stop()
