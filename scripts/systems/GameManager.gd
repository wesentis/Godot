extends Node

@onready var player = $"../Player"
@onready var hud = $"../UI/HUD"
@onready var inventory = $"../UI/Inventory"
@onready var zombie_spawner = $"../ZombieSpawner"

func _ready():
	print("🟡 GameManager._ready() called")
	print("   Player node: ", player)

	# Add player to group
	player.add_to_group("player")

	# Connect systems
	if hud:
		print("   Setting player for HUD")
		hud.set_player(player)
	if inventory:
		print("   Setting player for Inventory")
		inventory.set_player(player)
	if zombie_spawner:
		print("   Setting player for ZombieSpawner")
		zombie_spawner.set_player(player)

	print("🟡 GameManager._ready() DONE")

func _input(event):
	# Quick restart for testing
	if event.is_action_pressed("ui_accept") and not player.is_alive:
		get_tree().reload_current_scene()
