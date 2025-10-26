extends Control

@onready var health_bar = $HealthBar
@onready var health_label = $HealthLabel
@onready var ammo_label = $AmmoLabel
@onready var weapon_label = $WeaponLabel
@onready var crosshair = $Crosshair
@onready var interaction_label = $InteractionLabel
@onready var inventory_label = $InventoryLabel

var player = null

func _ready():
	interaction_label.hide()

func _process(_delta):
	if player:
		update_hud()
		check_interaction()

func update_hud():
	# Update health
	health_bar.value = player.health
	health_label.text = "HP: %d/%d" % [player.health, player.max_health]

	# Update ammo
	if player.current_weapon_data:
		ammo_label.text = "Ammo: %d/%d" % [player.ammo, player.current_weapon_data.max_ammo]
		weapon_label.text = "Weapon: %s (Slot %d)" % [player.current_weapon_data.weapon_name, player.current_weapon_slot + 1]
	else:
		ammo_label.text = "Ammo: --"
		weapon_label.text = "Weapon: None"

	# Update equipped weapons display
	var weapons_text = "Weapons: "
	for i in range(player.equipped_weapons.size()):
		var weapon = player.equipped_weapons[i]
		if weapon:
			var marker = " [%d]" % (i + 1)
			if i == player.current_weapon_slot:
				marker = " *%d*" % (i + 1)
			weapons_text += weapon.weapon_name + marker + " "

	# Update inventory count
	if player.inventory.size() > 0:
		inventory_label.text = weapons_text + " | Items: %d (TAB)" % player.inventory.size()
	else:
		inventory_label.text = weapons_text + " | Items: Empty"

func check_interaction():
	if player.raycast.is_colliding():
		var collider = player.raycast.get_collider()
		if collider != null and collider.has_method("pickup"):
			interaction_label.text = "[E] Pick up %s" % collider.item_name
			interaction_label.show()
		else:
			interaction_label.hide()
	else:
		interaction_label.hide()

func set_player(p):
	player = p
