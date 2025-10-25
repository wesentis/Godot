extends Node2D

@onready var goal = $Goal
@onready var win_label = $UI/WinLabel

func _ready():
	win_label.hide()
	if goal:
		goal.goal_reached.connect(_on_goal_reached)

func _on_goal_reached():
	win_label.show()
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
