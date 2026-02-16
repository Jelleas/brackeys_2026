extends Node2D

var damage: int = 0
var duration: float = 4.0
var tick_interval: float = 0.5
var cloud_y_offset: float = -100.0
var _target_global_pos: Vector2 = Vector2.ZERO

func _ready():
	global_position = Vector2(_target_global_pos.x, _target_global_pos.y + cloud_y_offset)

func init(spell: SpellConfigs.Spell, target_pos: Vector2) -> void:
	damage = spell.get_damage()
	_target_global_pos = target_pos
	_set_colors(spell.prefix.color1, spell.prefix.color2, spell.prefix.color3)

func _set_colors(color1: Color, color2: Color, color3: Color) -> void:
	var cloud_mat = $CloudParticles.process_material as ParticleProcessMaterial
	var cloud_gradient = Gradient.new()
	cloud_gradient.colors = PackedColorArray([
		Color(color1.r, color1.g, color1.b, 0.6),
		Color(color2.r, color2.g, color2.b, 0.3),
	])
	cloud_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var cloud_grad_tex = GradientTexture1D.new()
	cloud_grad_tex.gradient = cloud_gradient
	cloud_mat.color_ramp = cloud_grad_tex

	var rain_mat = $RainParticles.process_material as ParticleProcessMaterial
	var rain_gradient = Gradient.new()
	rain_gradient.colors = PackedColorArray([
		Color(color2.r, color2.g, color2.b, 0.8),
		Color(color3.r, color3.g, color3.b, 0.0),
	])
	rain_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var rain_grad_tex = GradientTexture1D.new()
	rain_grad_tex.gradient = rain_gradient
	rain_mat.color_ramp = rain_grad_tex

func _on_damage_tick() -> void:
	var areas = $DamageArea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("monster"):
			var monster = area.get_parent() as Monster
			if monster:
				monster.get_hit(damage)

func _fade_and_destroy() -> void:
	$DamageTimer.stop()
	$RainParticles.emitting = false
	$CloudParticles.emitting = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
