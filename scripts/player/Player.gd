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

# Inventory - stores items as dictionaries {type, name, data}
var inventory = []
var equipped_weapons = [null, null, null]  # 3 weapon slots
var current_weapon_slot = 0
var current_weapon_data: WeaponData = null
var ammo = 0
var last_shot_time = 0.0

# References
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/InteractRayCast
@onready var weapon_holder = $Head/Camera3D/WeaponHolder/WeaponModel
@onready var weapon_body = $Head/Camera3D/WeaponHolder/WeaponModel/Body
@onready var weapon_barrel = $Head/Camera3D/WeaponHolder/WeaponModel/Barrel
@onready var muzzle_flash = $Head/Camera3D/WeaponHolder/WeaponModel/Barrel/MuzzleFlash

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_weapon_model()

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

	# Handle Weapon Switching
	if Input.is_action_just_pressed("ui_text_1"):
		switch_weapon(0)
	elif Input.is_action_just_pressed("ui_text_2"):
		switch_weapon(1)
	elif Input.is_action_just_pressed("ui_text_3"):
		switch_weapon(2)

	move_and_slide()

func interact():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider != null and collider.has_method("pickup"):
			collider.pickup(self)

func shoot():
	if not current_weapon_data or ammo <= 0:
		return

	# Check fire rate
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_shot_time < current_weapon_data.fire_rate:
		return

	last_shot_time = current_time
	ammo -= 1

	# Muzzle flash effect
	if muzzle_flash:
		muzzle_flash.restart()

	# Check if weapon uses projectiles (rocket launcher)
	if current_weapon_data.is_projectile:
		shoot_projectile()
	else:
		shoot_raycast()

func shoot_raycast():
	# Create a raycast for shooting
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * 100)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 4 # Zombie layer

	var result = space_state.intersect_ray(query)
	if result and result.has("collider") and result.collider != null:
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(current_weapon_data.damage)

func shoot_projectile():
	# Spawn rocket projectile
	var rocket_scene = load("res://scenes/projectiles/Rocket.tscn")
	var rocket = rocket_scene.instantiate()
	get_tree().root.add_child(rocket)

	# Position at barrel
	var barrel_position = muzzle_flash.global_position if muzzle_flash else camera.global_position
	rocket.global_position = barrel_position

	# Set direction and properties
	rocket.direction = -camera.global_transform.basis.z
	rocket.damage = current_weapon_data.damage
	rocket.explosion_radius = current_weapon_data.explosion_radius
	rocket.speed = current_weapon_data.projectile_speed

func reload():
	if current_weapon_data:
		ammo = current_weapon_data.max_ammo

func take_damage(damage):
	if not is_alive:
		return

	health -= damage
	if health <= 0:
		health = 0
		die()

func heal(amount):
	health = min(health + amount, max_health)

func add_to_inventory(item_name, item_type = "generic", item_data = null):
	var item = {
		"name": item_name,
		"type": item_type,  # "weapon", "health", "generic"
		"data": item_data
	}
	inventory.append(item)
	print("Added to inventory: ", item_name)

func use_item(item_index: int):
	if item_index < 0 or item_index >= inventory.size():
		return

	var item = inventory[item_index]

	if item.type == "weapon":
		print("Silahı kuşanmak için karakter panelindeki bir slota sürükleyin!")
		# Weapons are now equipped via drag & drop to CharacterPanel
	elif item.type == "health":
		use_health_item(item_index)

func use_health_item(item_index: int):
	if item_index < 0 or item_index >= inventory.size():
		return

	var item = inventory[item_index]
	heal(50)  # Heal 50 HP
	inventory.remove_at(item_index)
	print("Used health pack")

func equip_weapon_from_inventory(item_index: int):
	if item_index < 0 or item_index >= inventory.size():
		return

	var item = inventory[item_index]
	if item.type != "weapon":
		return

	# Find empty weapon slot
	var slot_index = -1
	for i in range(equipped_weapons.size()):
		if equipped_weapons[i] == null:
			slot_index = i
			break

	# If no empty slot, replace current weapon
	if slot_index == -1:
		slot_index = current_weapon_slot

	equipped_weapons[slot_index] = item.data
	switch_weapon(slot_index)

	# Remove from inventory
	inventory.remove_at(item_index)
	print("Equipped weapon to slot ", slot_index + 1)

func switch_weapon(slot_index: int):
	if slot_index < 0 or slot_index >= equipped_weapons.size():
		return

	if equipped_weapons[slot_index] == null:
		return

	current_weapon_slot = slot_index
	current_weapon_data = equipped_weapons[slot_index]
	ammo = current_weapon_data.max_ammo
	update_weapon_model()
	print("Switched to weapon slot ", slot_index + 1, ": ", current_weapon_data.weapon_name)

func update_weapon_model():
	if not weapon_holder or not weapon_body or not weapon_barrel:
		print("ERROR: Weapon model parts not found!")
		return

	if current_weapon_data:
		print("=== UPDATING WEAPON MODEL ===")
		print("Weapon: ", current_weapon_data.weapon_name)
		print("Model size: ", current_weapon_data.model_size)
		print("Model color: ", current_weapon_data.model_color)

		weapon_holder.visible = true

		# Update weapon body mesh
		if weapon_body.mesh is BoxMesh:
			var box_mesh = weapon_body.mesh as BoxMesh
			box_mesh.size = current_weapon_data.model_size
			print("Updated body mesh size")

		# Update weapon body material
		var body_material = weapon_body.get_active_material(0) as StandardMaterial3D
		if body_material:
			body_material.albedo_color = current_weapon_data.model_color
			print("Updated body material color")

		# Update barrel size (proportional to body)
		if weapon_barrel.mesh is BoxMesh:
			var barrel_mesh = weapon_barrel.mesh as BoxMesh
			barrel_mesh.size = Vector3(0.1, 0.1, current_weapon_data.model_size.z * 0.3)
			print("Updated barrel mesh size")

		print("Weapon model visible and updated!")
	else:
		weapon_holder.visible = false
		print("No weapon equipped, hiding model")

func drop_item(item_index: int):
	if item_index < 0 or item_index >= inventory.size():
		return

	var item = inventory[item_index]

	# Create the appropriate pickup item in the world
	var pickup_scene = null
	if item.type == "weapon":
		pickup_scene = load("res://scenes/loot/WeaponPickup.tscn")
	elif item.type == "health":
		pickup_scene = load("res://scenes/loot/HealthPack.tscn")

	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		get_tree().root.add_child(pickup)

		# Position in front of player
		var drop_position = global_position + (-global_transform.basis.z * 2.0)
		drop_position.y = global_position.y
		pickup.global_position = drop_position

		# Set weapon data if it's a weapon
		if item.type == "weapon" and pickup.has_method("set_weapon_data"):
			pickup.set_weapon_data(item.data)

	# Remove from inventory
	inventory.remove_at(item_index)
	print("Dropped item: ", item.name)

func update_weapon_visibility():
	update_weapon_model()

func die():
	is_alive = false
	# Game over logic here
	get_tree().reload_current_scene()
