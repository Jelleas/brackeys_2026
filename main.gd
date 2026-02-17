class_name Main extends Node2D

@export var game_scene: PackedScene

@onready var game_screen: CanvasLayer = $GameScreen

func _ready() -> void:
	Bus.wizard_killed.connect(_on_wizard_killed)
	Bus.new_game.connect(_on_new_game)
	Bus.tutorial_over.connect(_on_tutorial_over)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = true
	
func _on_wizard_killed():
	if game_screen:
		game_screen.queue_free()
	
func _on_new_game():
	game_screen = game_scene.instantiate()
	add_child(game_screen)
	
func _on_tutorial_over():
	get_tree().paused = false
