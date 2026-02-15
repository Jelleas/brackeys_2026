extends Node2D

var ball_scene = preload("res://spells/ball/ball.tscn")
var bolt_scene = preload("res://spells/bolt/bolt.tscn")

#cast_spell(50.0, Color("#AAEEFF"), Color("#3388FF"), Color("#1122AA"))
#cast_spell(50.0, Color("#FFFFAA"), Color("#FF6600"), Color("#CC2200"))
#cast_bolt(Color("#FFFFFF"), Color(0.3, 0.5, 1.0, 0.4))

func _ready():
	Bus.spell_matched.connect(_on_spell_matched)

func cast_ball(center_color: Color, mid_color: Color, edge_color: Color):
	var spell_range = 50.0
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

func _on_spell_matched(spell_prefix: String, spell_suffix):
	var color1
	var color2
	var color3 
	if spell_prefix == "lux":
		color1 = Color("#FFFFAA")
		color2 = Color("#FF6600")
		color3 = Color("#CC2200")
	
	if spell_suffix == "pila":
		cast_ball(color1, color2, color3)
