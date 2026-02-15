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


func setup_shape(range: float):
	$CollisionShape2D.shape.radius = range
	mat = $GPUParticles2D.process_material as ParticleProcessMaterial
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = range
	$GPUParticles2D.emitting = true

func destroy():
	queue_free()
