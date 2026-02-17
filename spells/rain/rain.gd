extends Node2D

var damage: int = 0
var duration: float = 4.0
var tick_interval: float = 0.5
var cloud_y_offset: float = -200.0
var _target_global_pos: Vector2 = Vector2.ZERO
var damage_timer: Timer
var spell: SpellConfigs.Spell

@onready var damage_area: Area2D = $DamageArea

func _ready():
	global_position = Vector2(_target_global_pos.x, _target_global_pos.y + cloud_y_offset)
	
	damage_area.collision_layer = 2
	damage_area.collision_mask = 1
	damage_area.set_deferred("monitoring", true)
	damage_area.position = Vector2(0, -cloud_y_offset)
	
	damage_timer = Timer.new()
	damage_timer.wait_time = tick_interval
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_on_damage_tick)
	add_child(damage_timer)
	damage_timer.start()
	
	$CloudParticles.emitting = true
	$RainParticles.emitting = true
	
	await get_tree().create_timer(duration).timeout
	_fade_and_destroy()

func init(_spell: SpellConfigs.Spell, target_pos: Vector2) -> void:
	spell = _spell
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
		Color(color3.r, color3.g, color3.b, 0.3),
	])
	rain_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var rain_grad_tex = GradientTexture1D.new()
	rain_grad_tex.gradient = rain_gradient
	rain_mat.color_ramp = rain_grad_tex

func _on_damage_tick() -> void:
	var areas = damage_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("monster"):
			var monster = area.get_parent() as Monster
			if monster:
				monster.get_hit(spell)

func _fade_and_destroy() -> void:
	damage_timer.stop()
	$RainParticles.emitting = false
	$CloudParticles.emitting = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
