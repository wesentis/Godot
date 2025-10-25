extends Node3D

@export var zombie_scene: PackedScene
@export var spawn_interval = 10.0
@export var max_zombies = 10
@export var spawn_radius = 30.0

@onready var spawn_timer = $SpawnTimer
var player = null
var current_zombie_count = 0

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func set_player(p):
	player = p

func _on_spawn_timer_timeout():
	# Count current zombies
	current_zombie_count = get_tree().get_nodes_in_group("zombie").size()

	if current_zombie_count < max_zombies and player:
		spawn_zombie()

func spawn_zombie():
	if not zombie_scene:
		return

	# Random position around player
	var angle = randf() * TAU
	var distance = spawn_radius + randf() * 10.0
	var offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
	var spawn_pos = player.global_position + offset
	spawn_pos.y = 1.0  # Spawn at ground level

	var zombie = zombie_scene.instantiate()
	get_parent().add_child(zombie)
	zombie.global_position = spawn_pos
	zombie.target = player
