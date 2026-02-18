extends CanvasLayer

var target: Rect2
@onready var dimmer: ColorRect = $ColorRect
@onready var mat: ShaderMaterial = dimmer.material

var _position = Vector2(420, 420)

func instantiate(_target: Rect2):
	target = _target
	_update_hole()

func _process(_dt: float) -> void:
	if is_instance_valid(target):
		_update_hole()

func _update_hole() -> void:
	var r: Rect2 = target
	var center := r.position + r.size * 0.5
	mat.set_shader_parameter("hole_center", center)
	mat.set_shader_parameter("hole_size", r.size)
