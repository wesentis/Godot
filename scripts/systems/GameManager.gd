extends Node

@onready var player = $"../Player"
@onready var hud = $"../UI/HUD"
@onready var inventory = $"../UI/Inventory"
@onready var zombie_spawner = $"../ZombieSpawner"

func _ready():
	# Add player to group
	player.add_to_group("player")

	# Connect systems
	if hud:
		hud.set_player(player)
	if inventory:
		inventory.set_player(player)
	if zombie_spawner:
		zombie_spawner.set_player(player)

func _input(event):
	# Quick restart for testing
	if event.is_action_pressed("ui_accept") and not player.is_alive:
		get_tree().reload_current_scene()
