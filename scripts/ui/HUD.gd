extends Control

@onready var health_bar = $HealthBar
@onready var health_label = $HealthLabel
@onready var ammo_label = $AmmoLabel
@onready var weapon_label = $WeaponLabel
@onready var crosshair = $Crosshair
@onready var interaction_label = $InteractionLabel

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
	if player.current_weapon:
		ammo_label.text = "Ammo: %d" % player.ammo
		weapon_label.text = "Weapon: %s" % player.current_weapon
	else:
		ammo_label.text = "Ammo: --"
		weapon_label.text = "Weapon: None"

func check_interaction():
	if player.raycast.is_colliding():
		var collider = player.raycast.get_collider()
		if collider.has_method("pickup"):
			interaction_label.text = "[E] Pick up %s" % collider.item_name
			interaction_label.show()
		else:
			interaction_label.hide()
	else:
		interaction_label.hide()

func set_player(p):
	player = p
