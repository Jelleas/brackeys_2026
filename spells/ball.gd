extends Area2D

var target:Area2D = null
var damage: int
var mat

func _ready():
	monitoring = true
	monitorable = true
	collision_layer = 2
	collision_mask = 1
	add_to_group("projectile")

func set_colors(center_color: Color, mid_color: Color, edge_color: Color):
	$Sprite2D.modulate = center_color

	mat = $GPUParticles2D.process_material as ParticleProcessMaterial
	
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		center_color,
		mid_color,
		Color(edge_color.r, edge_color.g, edge_color.b, 0.0)
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])

	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex

func setup_shape(range: float):
	$CollisionShape2D.shape.radius = range
	mat = $GPUParticles2D.process_material as ParticleProcessMaterial
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = range
	$GPUParticles2D.emitting = true

func destroy():
	queue_free()
