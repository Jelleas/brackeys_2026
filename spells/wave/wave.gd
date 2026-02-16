extends Node2D
var damage: int = 0
var wave_speed: float = 400.0
var max_range: float = 1200.0
var wave_x: float = 0.0
var hit_monsters: Array = []
var _done: bool = false

@onready var hit_area: Area2D = $HitArea

func init(spell: SpellConfigs.Spell, _target_pos: Vector2 = Vector2.ZERO) -> void:
	damage = spell.get_damage()
	_set_colors(spell.prefix.color1, spell.prefix.color2, spell.prefix.color3)

func _ready():
	hit_area.collision_layer = 2
	hit_area.collision_mask = 1
	hit_area.set_deferred("monitoring", true)
	hit_area.area_entered.connect(_on_area_entered)
	max_range = get_viewport_rect().size.x - global_position.x
	_generate_wave_points()
	
	$SprayParticles.emitting = true
	$TrailParticles.emitting = true

func _process(delta):
	if _done:
		return
	wave_x += wave_speed * delta
	hit_area.position.x = wave_x
	$WaveBody.position.x = wave_x
	$SprayParticles.position = Vector2(wave_x - 15, -55) 
	$TrailParticles.position = Vector2(wave_x - 60, 80)

	if wave_x >= max_range:
		_done = true
		_fade_and_destroy()

func _on_area_entered(area: Area2D):
	if area.is_in_group("monster"):
		var monster = area.get_parent() as Monster
		if monster and monster not in hit_monsters:
			monster.get_hit(damage)
			hit_monsters.append(monster)

func _generate_wave_points():
	$WaveBody.polygon = PackedVector2Array([
		# Base (right side, bottom)
		Vector2(25, 80),
		# Rising right side
		Vector2(25, 60),
		Vector2(22, 40),
		Vector2(18, 20),
		Vector2(12, 0),
		Vector2(5, -20),
		# Crest (curling over)
		Vector2(-3, -45),
		Vector2(-10, -60),
		Vector2(-18, -65),
		Vector2(-28, -60),
		Vector2(-35, -50),
		# Inside of curl
		Vector2(-30, -40),
		Vector2(-22, -32),
		Vector2(-12, -28),
		Vector2(-5, -20),
		# Inside body (falling back down)
		Vector2(-2, -5),
		Vector2(0, 15),
		Vector2(2, 35),
		Vector2(0, 55),
		# Base (left side, bottom) — trailing tail
		Vector2(-10, 75),
		Vector2(-30, 78),
		Vector2(-55, 80),
		Vector2(-80, 80),
	])

func _set_colors(color1: Color, color2: Color, color3: Color) -> void:
	$WaveBody.color = color1
	# Setup particle gradients similar to other spells
	var spray_mat = $SprayParticles.process_material as ParticleProcessMaterial
	var spray_gradient = Gradient.new()
	spray_gradient.colors = PackedColorArray([
		Color(color1.r, color1.g, color1.b, 0.8),
		Color(color2.r, color2.g, color2.b, 0.0),
	])
	spray_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var spray_tex = GradientTexture1D.new()
	spray_tex.gradient = spray_gradient
	spray_mat.color_ramp = spray_tex
	var trail_mat = $TrailParticles.process_material as ParticleProcessMaterial
	var trail_gradient = Gradient.new()
	trail_gradient.colors = PackedColorArray([
		Color(color2.r, color2.g, color2.b, 0.5),
		Color(color3.r, color3.g, color3.b, 0.0),
	])
	trail_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var trail_tex = GradientTexture1D.new()
	trail_tex.gradient = trail_gradient
	trail_mat.color_ramp = trail_tex

func _fade_and_destroy() -> void:
	$SprayParticles.emitting = false
	$TrailParticles.emitting = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
