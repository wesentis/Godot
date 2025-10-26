extends RigidBody3D

var damage: int = 100
var explosion_radius: float = 5.0
var speed: float = 30.0
var direction: Vector3 = Vector3.FORWARD

func _ready():
	linear_velocity = direction * speed
	# Auto destroy after 10 seconds
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	# Check for collision
	pass

func _on_body_entered(body):
	explode()

func explode():
	# Find all enemies in explosion radius
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = explosion_radius
	query.shape = sphere
	query.transform = Transform3D(Basis(), global_position)
	query.collision_mask = 0b00000100  # Layer 3 (Zombies)

	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)

	# Create explosion effect (simple sphere for now)
	create_explosion_effect()

	queue_free()

func create_explosion_effect():
	# Create a temporary visual effect
	var explosion = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = explosion_radius
	sphere_mesh.height = explosion_radius * 2
	explosion.mesh = sphere_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.5, 0, 0.5)
	material.emission_enabled = true
	material.emission = Color(1, 0.3, 0, 1)
	material.emission_energy_multiplier = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	explosion.material_override = material

	get_tree().root.add_child(explosion)
	explosion.global_position = global_position

	# Fade out and destroy
	var tween = create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, 0.5)
	tween.tween_callback(explosion.queue_free)
