extends LootBase

enum WeaponType {
	PISTOL,
	AR15,
	ROCKET_LAUNCHER
}

@export var weapon_type: WeaponType = WeaponType.PISTOL
var weapon_data: WeaponData = null

func _ready():
	super._ready()
	# Create weapon data based on type
	match weapon_type:
		WeaponType.PISTOL:
			weapon_data = WeaponData.create_pistol()
		WeaponType.AR15:
			weapon_data = WeaponData.create_ar15()
		WeaponType.ROCKET_LAUNCHER:
			weapon_data = WeaponData.create_rocket_launcher()

	item_name = weapon_data.weapon_name
	update_visual()

func set_weapon_data(data: WeaponData):
	weapon_data = data
	if weapon_data:
		item_name = weapon_data.weapon_name
		update_visual()

func update_visual():
	if not weapon_data:
		return

	# Update mesh size and color
	var mesh_instance = $MeshInstance3D as MeshInstance3D
	if mesh_instance and mesh_instance.mesh is BoxMesh:
		var box_mesh = mesh_instance.mesh as BoxMesh
		box_mesh.size = weapon_data.model_size

		var material = mesh_instance.get_active_material(0) as StandardMaterial3D
		if material:
			material.albedo_color = weapon_data.model_color

	# Update collision shape
	var collision_shape = $CollisionShape3D as CollisionShape3D
	if collision_shape and collision_shape.shape is BoxShape3D:
		var box_shape = collision_shape.shape as BoxShape3D
		box_shape.size = weapon_data.model_size

func pickup(player):
	if player.has_method("add_to_inventory"):
		player.add_to_inventory(weapon_data.weapon_name, "weapon", weapon_data)
		print("Picked up weapon: ", weapon_data.weapon_name)
		queue_free()
