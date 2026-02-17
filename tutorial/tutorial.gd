class_name Tutorial extends CanvasLayer

@onready var dimmer: ColorRect = $ColorRect
@onready var mat: ShaderMaterial = dimmer.material

var target: Rect2
var tutorials: Array[TutorialEntry] = []
var tut_index: int = 0

func _enter_tree() -> void:
	tutorials.append(TutorialEntry.new("Welcome. Everything will be done through typing. Type 'continue' to go to the next step.", self, 0))
	Bus.register_tutorial.connect(_on_register_tutorial)

func _ready() -> void:
	$Continue.instantiate("continue", _on_continue)
	call_deferred("_start_tutorial")
	
func _on_register_tutorial(text: String, node: Node, order: int):
	tutorials.append(TutorialEntry.new(text, node, order))
	
func _on_continue() -> void:
	tut_index += 1
	if tut_index == tutorials.size():
		Bus.tutorial_over.emit()
		queue_free()
		return
	show_tutorial_step()
	
func _start_tutorial():
	print("starting tutorial")
	tutorials.sort_custom(func(a, b): return a.order < b.order)
	show_tutorial_step()
	
func show_tutorial_step():
	var tut: TutorialEntry = tutorials[tut_index]
	var rect: Rect2 
	if tut.node is Control:
		print("control detected")
		rect = tut.node.get_global_rect()
	else:
		rect = Rect2(640, 720, 1, 1)
	$Label.text = tut.text
	await get_tree().process_frame
	var label_rect: Rect2 = $Label.get_rect()
	var label_pos: Vector2 = Vector2(rect.get_center().x, rect.position.y) + label_rect.size * Vector2.UP + label_rect.size * Vector2.LEFT * 0.5
	if label_pos.x < 0: label_pos.x = 0
	if label_pos.x > 1280-label_rect.size.x: label_pos.x = 1280-label_rect.size.x
	$Label.global_position = label_pos
	set_target(rect)

func set_target(rect: Rect2) -> void:
	target = rect
	_update_hole()

func _process(_dt: float) -> void:
	if is_instance_valid(target):
		_update_hole()

func _update_hole() -> void:
	var r: Rect2 = target
	var center := r.position + r.size * 0.5
	mat.set_shader_parameter("hole_center", center)
	mat.set_shader_parameter("hole_size", r.size)

class TutorialEntry:
	var text: String
	var node: Node
	var order: int
	
	func _init(_text: String, _node: Node, _order: int) -> void:
		text = _text
		node = _node
		order = _order
