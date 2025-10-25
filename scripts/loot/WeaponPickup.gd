extends LootBase

@export var weapon_type = "Pistol"
@export var ammo_amount = 30

func _ready():
	super._ready()
	item_name = weapon_type

func pickup(player):
	if player.has_method("add_to_inventory"):
		player.add_to_inventory(weapon_type)
		player.current_weapon = weapon_type
		player.ammo += ammo_amount
		player.max_ammo = ammo_amount
		queue_free()
