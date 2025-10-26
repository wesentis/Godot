extends Resource
class_name WeaponData

enum WeaponType {
	PISTOL,
	AR15,
	ROCKET_LAUNCHER
}

@export var weapon_name: String = "Weapon"
@export var weapon_type: WeaponType = WeaponType.PISTOL
@export var damage: int = 25
@export var max_ammo: int = 30
@export var fire_rate: float = 0.5  # Seconds between shots
@export var reload_time: float = 2.0
@export var is_projectile: bool = false  # True for rocket launcher
@export var projectile_speed: float = 30.0
@export var explosion_radius: float = 0.0

# Visual properties
@export var model_size: Vector3 = Vector3(0.8, 0.2, 1.5)
@export var model_color: Color = Color(0.1, 0.1, 0.1)
@export var icon_emoji: String = "🔫"

static func create_pistol() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "Pistol"
	data.weapon_type = WeaponType.PISTOL
	data.damage = 25
	data.max_ammo = 12
	data.fire_rate = 0.5
	data.reload_time = 1.5
	data.is_projectile = false
	data.model_size = Vector3(0.6, 0.15, 1.0)
	data.model_color = Color(0.1, 0.1, 0.1)
	data.icon_emoji = "🔫"
	return data

static func create_ar15() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "AR15"
	data.weapon_type = WeaponType.AR15
	data.damage = 35
	data.max_ammo = 30
	data.fire_rate = 0.15  # Faster fire rate
	data.reload_time = 2.5
	data.is_projectile = false
	data.model_size = Vector3(0.8, 0.25, 2.0)
	data.model_color = Color(0.2, 0.15, 0.1)
	data.icon_emoji = "🔫"
	return data

static func create_rocket_launcher() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "Rocket Launcher"
	data.weapon_type = WeaponType.ROCKET_LAUNCHER
	data.damage = 100
	data.max_ammo = 4
	data.fire_rate = 2.0  # Slow fire rate
	data.reload_time = 3.0
	data.is_projectile = true
	data.projectile_speed = 30.0
	data.explosion_radius = 5.0
	data.model_size = Vector3(1.2, 0.4, 2.5)
	data.model_color = Color(0.3, 0.3, 0.2)
	data.icon_emoji = "🚀"
	return data
