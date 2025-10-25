extends CharacterBody3D

# Zombie stats
var max_health = 50.0
var health = 50.0
var damage = 10.0
var move_speed = 2.0
var attack_range = 1.5
var detection_range = 20.0
var attack_cooldown = 1.5

# State
var is_alive = true
var can_attack = true
var target = null

# References
@onready var navigation_agent = $NavigationAgent3D
@onready var attack_timer = $AttackTimer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if not is_alive:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Find player
	if target == null:
		find_target()

	if target and is_instance_valid(target):
		var distance_to_target = global_position.distance_to(target.global_position)

		# Check if target is in range
		if distance_to_target > detection_range:
			target = null
			velocity.x = 0
			velocity.z = 0
		elif distance_to_target <= attack_range:
			# Attack range - stop moving and attack
			velocity.x = 0
			velocity.z = 0
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
			if can_attack:
				attack()
		else:
			# Chase target
			navigation_agent.target_position = target.global_position
			var next_position = navigation_agent.get_next_path_position()
			var direction = (next_position - global_position).normalized()

			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed

			# Look at target
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func find_target():
	# Find player in the scene
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func attack():
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
		can_attack = false
		attack_timer.start()

func take_damage(amount):
	if not is_alive:
		return

	health -= amount
	if health <= 0:
		die()

func die():
	is_alive = false
	# Death animation would go here
	queue_free()

func _on_attack_timer_timeout():
	can_attack = true
