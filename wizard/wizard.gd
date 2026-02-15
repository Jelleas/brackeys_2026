extends Node2D

var ball_scene = preload("res://spells/ball/ball.tscn")
var bolt_scene = preload("res://spells/bolt/bolt.tscn")

var timer: float = 0.0
func _process(delta: float) -> void:
	timer += delta
	if timer >= 1.0:
		timer = 0.0
		#cast_spell(50.0, Color("#AAEEFF"), Color("#3388FF"), Color("#1122AA"))
		#cast_spell(50.0, Color("#FFFFAA"), Color("#FF6600"), Color("#CC2200"))
		cast_bolt(Color("#FFFFFF"), Color(0.3, 0.5, 1.0, 0.4))

func cast_spell(spell_range: float, center_color: Color, mid_color: Color, edge_color: Color):
	var ball = ball_scene.instantiate()
	ball.global_position = global_position
	get_tree().current_scene.add_child(ball)
	ball.setup_shape(spell_range)
	ball.set_colors(center_color, mid_color, edge_color)


func cast_bolt(core_color: Color, glow_color: Color):
	var bolt = bolt_scene.instantiate()
	bolt.global_position = global_position
	get_tree().current_scene.add_child(bolt)
	bolt.max_range = 800.0
	bolt.set_colors(core_color, glow_color)
