class_name Tutorial extends CanvasLayer

var steps = []
var active_step = null

func _enter_tree() -> void:
	Bus.next_tutorial_step.connect(_on_next_tutorial_step)
	steps = [$Step1, $Step2]

func _ready() -> void:
	active_step = steps[0]
	active_step.start()
	
func _on_next_tutorial_step():
	var active_step_index = steps.find(active_step)
	active_step_index += 1
	
	if active_step_index >= steps.size():
		Bus.tutorial_over.emit()
		queue_free()
		return
	
	active_step = steps[active_step_index]
	active_step.start()
