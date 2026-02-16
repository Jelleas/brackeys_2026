extends Node2D

var damage: int = 0
var pool_duration: float = 4.0
var pool_tick_interval: float = 0.5
var fall_speed: float = 800.0
var _target_global_pos: Vector2 = Vector2.ZERO
var _phase: int = 0  # 0=falling, 1=exploding, 2=pool
var _fall_start_y: float = -200.0
var damage_timer: Timer

func init(spell: SpellConfigs.Spell, target_pos: Vector2 = Vector2.ZERO) -> void:
	damage = spell.get_damage()
	_target_global_pos = target_pos
	_set_colors(spell.prefix.color1, spell.prefix.color2, spell.prefix.color3)

func _ready():
	global_position = _target_global_pos if _target_global_pos != Vector2.ZERO else get_viewport_rect().size * 0.5

	# Start with the falling orb
	$FallingOrb.position = Vector2(0, _fall_start_y)
	$FallingOrb.visible = true
	$FallingOrb/OrbTrail.emitting = true

	# Everything else off
	$ShockwaveLeft.emitting = false
	$ShockwaveRight.emitting = false
	$ExplosionFlash.emitting = false
	$MushroomStem.emitting = false
	$MushroomCap.emitting = false
	$PoolParticles.emitting = false

	# DamageArea setup
	$DamageArea.collision_layer = 2
	$DamageArea.collision_mask = 1
	$DamageArea.set_deferred("monitoring", false)

	_phase = 0

func _process(delta):
	if _phase == 0:
		$FallingOrb.position.y += fall_speed * delta
		if $FallingOrb.position.y >= 0:
			$FallingOrb.position.y = 0
			_on_impact()

	elif _phase == 2:
		# Pulse the pool dots' alpha for an irradiating glow effect
		var t = Time.get_ticks_msec() / 1000.0
		var pulse = 0.4 + 0.25 * sin(t * 3.0)
		$PoolParticles.modulate.a = pulse

func _on_impact():
	_phase = 1
	$FallingOrb.visible = false
	$FallingOrb/OrbTrail.emitting = false

	# --- Immediate: central flash + shockwave left/right ---
	$ExplosionFlash.emitting = true
	$ShockwaveLeft.emitting = true
	$ShockwaveRight.emitting = true

	# --- Slight delay: mushroom stem begins rising ---
	await get_tree().create_timer(0.1).timeout
	$MushroomStem.emitting = true

	# --- Cap blooms when stem reaches the top ---
	await get_tree().create_timer(0.55).timeout
	$MushroomCap.emitting = true

	# --- Pool / irradiating dots appear as the debris settles ---
	await get_tree().create_timer(0.2).timeout
	$PoolParticles.emitting = true
	_phase = 2

	# Enable damage area and do the initial explosion hit
	$DamageArea.set_deferred("monitoring", true)
	_do_explosion_damage()

	# Start tick damage timer
	damage_timer = Timer.new()
	damage_timer.wait_time = pool_tick_interval
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_on_damage_tick)
	add_child(damage_timer)
	damage_timer.start()

	# Pool duration countdown
	await get_tree().create_timer(pool_duration).timeout
	_fade_and_destroy()

func _do_explosion_damage():
	await get_tree().create_timer(0.1).timeout
	var areas = $DamageArea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("monster"):
			var monster = area.get_parent() as Monster
			if monster:
				monster.get_hit(damage * 2)

func _on_damage_tick() -> void:
	var areas = $DamageArea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("monster"):
			var monster = area.get_parent() as Monster
			if monster:
				monster.get_hit(damage)

func _set_colors(color1: Color, color2: Color, color3: Color) -> void:
	# --- Orb (spell colors) ---
	$FallingOrb/OrbSprite.modulate = color1

	var orb_mat = $FallingOrb/OrbTrail.process_material as ParticleProcessMaterial
	_apply_gradient(orb_mat, [
		[color1, 0.0],
		[Color(color2.r, color2.g, color2.b, 0.4), 1.0],
	])

	# --- Explosion flash (fixed fiery colors: white-hot core -> orange -> fade) ---
	var flash_mat = $ExplosionFlash.process_material as ParticleProcessMaterial
	_apply_gradient(flash_mat, [
		[Color(1.0, 1.0, 0.9, 0.15), 0.0],
		[Color(1.0, 0.6, 0.1, 0.08), 0.25],
		[Color(0.8, 0.2, 0.0, 0.0), 1.0],
	])

	# --- Shockwave left & right (fixed fiery: bright orange -> dark red/smoke -> fade) ---
	for node_name in ["ShockwaveLeft", "ShockwaveRight"]:
		var sw_mat = get_node(node_name).process_material as ParticleProcessMaterial
		_apply_gradient(sw_mat, [
			[Color(1.0, 0.7, 0.15, 0.9), 0.0],
			[Color(0.85, 0.3, 0.05, 0.6), 0.4],
			[Color(0.3, 0.1, 0.05, 0.0), 1.0],
		])

	# --- Mushroom stem (spell colors) ---
	var stem_mat = $MushroomStem.process_material as ParticleProcessMaterial
	_apply_gradient(stem_mat, [
		[Color(color2.r, color2.g, color2.b, 0.7), 0.0],
		[Color(color3.r, color3.g, color3.b, 0.5), 0.6],
		[Color(color3.r, color3.g, color3.b, 0.0), 1.0],
	])

	# --- Mushroom cap (spell colors) ---
	var cap_mat = $MushroomCap.process_material as ParticleProcessMaterial
	_apply_gradient(cap_mat, [
		[Color(color1.r, color1.g, color1.b, 0.8), 0.0],
		[Color(color2.r, color2.g, color2.b, 0.5), 0.5],
		[Color(color3.r, color3.g, color3.b, 0.0), 1.0],
	])

	# --- Pool / irradiating dots (spell colors) ---
	var pool_mat = $PoolParticles.process_material as ParticleProcessMaterial
	_apply_gradient(pool_mat, [
		[Color(color2.r, color2.g, color2.b, 0.35), 0.0],
		[Color(color3.r, color3.g, color3.b, 0.25), 0.5],
		[Color(color2.r, color2.g, color2.b, 0.1), 1.0],
	])

## Helper: build a Gradient + GradientTexture1D and assign it as color_ramp.
## stops is an Array of [Color, float] pairs.
func _apply_gradient(mat: ParticleProcessMaterial, stops: Array) -> void:
	var gradient = Gradient.new()
	var colors: PackedColorArray = PackedColorArray()
	var offsets: PackedFloat32Array = PackedFloat32Array()
	for stop in stops:
		colors.append(stop[0])
		offsets.append(stop[1])
	gradient.colors = colors
	gradient.offsets = offsets
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex

func _fade_and_destroy() -> void:
	if damage_timer:
		damage_timer.stop()
	$PoolParticles.emitting = false
	$MushroomStem.emitting = false
	$MushroomCap.emitting = false
	$ShockwaveLeft.emitting = false
	$ShockwaveRight.emitting = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
