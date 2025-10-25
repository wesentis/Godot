extends CharacterBody3D

# Movement
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

# Player stats
var max_health = 100.0
var health = 100.0
var is_alive = true

# States
var is_crouching = false
var current_speed = WALK_SPEED

# Inventory
var inventory = []
var current_weapon = null
var ammo = 0
var max_ammo = 30

# References
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/InteractRayCast
@onready var weapon_model = $Head/Camera3D/WeaponHolder/WeaponModel

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_weapon_visibility()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_alive:
		return

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	# Handle Sprint
	if Input.is_action_pressed("sprint") and not is_crouching:
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED

	# Handle Crouch
	if Input.is_action_pressed("crouch"):
		if not is_crouching:
			is_crouching = true
			current_speed = CROUCH_SPEED
			head.position.y = 0.3
	else:
		if is_crouching:
			is_crouching = false
			head.position.y = 0.6

	# Handle Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Handle Interaction
	if Input.is_action_just_pressed("interact"):
		interact()

	# Handle Shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# Handle Reload
	if Input.is_action_just_pressed("reload"):
		reload()

	move_and_slide()

func interact():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider != null and collider.has_method("pickup"):
			collider.pickup(self)

func shoot():
	if current_weapon and ammo > 0:
		ammo -= 1
		# Create a raycast for shooting
		var space_state = get_world_3d().direct_space_state
		var from = camera.global_position
		var to = from + (-camera.global_transform.basis.z * 100)
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = 4 # Zombie layer

		var result = space_state.intersect_ray(query)
		if result and result.has("collider") and result.collider != null:
			if result.collider.has_method("take_damage"):
				result.collider.take_damage(25)

func reload():
	ammo = max_ammo

func take_damage(damage):
	if not is_alive:
		return

	health -= damage
	if health <= 0:
		health = 0
		die()

func heal(amount):
	health = min(health + amount, max_health)

func add_to_inventory(item_name):
	inventory.append(item_name)
	print("Added to inventory: ", item_name)

func update_weapon_visibility():
	if weapon_model:
		weapon_model.visible = (current_weapon != null)

func die():
	is_alive = false
	# Game over logic here
	get_tree().reload_current_scene()
