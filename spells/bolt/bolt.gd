extends Node2D

@export var bolt_speed := 3000.0
@export var max_range := 800.0
@export var lifetime := 0.5
@export var bolt_segments := 12
@export var bolt_offset := 25.0
@export var flicker_interval := 0.04

var damage: int = 0
var _end_x := 0.0
var _fully_extended := false
var _lifetime_timer := 0.0
var _flicker_timer := 0.0

func _ready():
	$GPUParticles2D.emitting = false

func _process(delta: float):
	if not _fully_extended:
		_end_x += bolt_speed * delta
		if _end_x >= max_range:
			_end_x = max_range
			_fully_extended = true
			$GPUParticles2D.position = Vector2(_end_x, 0)
			$GPUParticles2D.emitting = true
			$EndPoint/CollisionShape2D.shape.radius = 20.0
			$EndPoint.position = Vector2(_end_x, 0)
			$EndPoint.monitoring = true
	else:
		_lifetime_timer += delta
		if _lifetime_timer >= lifetime:
			queue_free()
			return
		var alpha = 1.0 - (_lifetime_timer / lifetime)
		$BoltLine.modulate.a = alpha
		$GlowLine.modulate.a = alpha
	_flicker_timer += delta

	if _flicker_timer >= flicker_interval:
		_flicker_timer = 0.0
		_regenerate_bolt()

func _regenerate_bolt():
	var start = Vector2.ZERO
	var end = Vector2(_end_x, 0)
	var points: PackedVector2Array = [start]
	for i in range(1, bolt_segments):
		var t = float(i) / bolt_segments
		var mid = start.lerp(end, t)
		mid.y += randf_range(-bolt_offset, bolt_offset)
		points.append(mid)
	points.append(end)
	$BoltLine.points = points
	$GlowLine.points = points

func set_colors(core_color: Color, glow_color: Color):
	$BoltLine.default_color = core_color
	$GlowLine.default_color = glow_color
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		core_color,
		glow_color,
		Color(glow_color.r, glow_color.g, glow_color.b, 0.0)
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = gradient
	$GPUParticles2D.process_material.color_ramp = grad_tex

func destroy():
	queue_free()
