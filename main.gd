class_name Main extends Node2D

@export var game_scene: PackedScene

@onready var game_screen: CanvasLayer = $GameScreen

var upgrade_time: float = 15.0
var upgrade_timer: Timer

func _ready() -> void:
	Bus.wizard_killed.connect(_on_wizard_killed)
	Bus.new_game.connect(_on_new_game)
	Bus.tutorial_over.connect(_on_tutorial_over)
	await get_tree().process_frame
	await get_tree().process_frame
	init_timer()
	get_tree().paused = true

func init_timer():
	upgrade_timer = Timer.new()
	upgrade_timer.wait_time = upgrade_time
	upgrade_timer.one_shot = false
	upgrade_timer.autostart = true
	add_child(upgrade_timer)
	upgrade_timer.timeout.connect(_on_upgrade_timer_timeout)
	
func _on_wizard_killed():
	if game_screen:
		game_screen.queue_free()
	
func _on_new_game():
	game_screen = game_scene.instantiate()
	add_child(game_screen)
	
func _on_tutorial_over():
	get_tree().paused = false

func _on_upgrade_timer_timeout():
	# 50/50 debuff / buff
	Bus.spawn_upgrade.emit(randi() % 2 == 0)
