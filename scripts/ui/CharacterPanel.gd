extends Panel

@onready var weapon_slot_1 = $MarginContainer/VBoxContainer/WeaponSlot1
@onready var weapon_slot_2 = $MarginContainer/VBoxContainer/WeaponSlot2
@onready var weapon_slot_3 = $MarginContainer/VBoxContainer/WeaponSlot3
@onready var helmet_slot = $MarginContainer/VBoxContainer/HelmetSlot
@onready var chest_slot = $MarginContainer/VBoxContainer/ChestSlot
@onready var boots_slot = $MarginContainer/VBoxContainer/BootsSlot

var player = null
var inventory_ref = null

func _ready():
	print("🔵 CharacterPanel._ready() called")
	print("   player at _ready: ", player)

	# Connect equipment slot signals
	weapon_slot_1.item_equipped.connect(_on_weapon_equipped.bind(0))
	weapon_slot_2.item_equipped.connect(_on_weapon_equipped.bind(1))
	weapon_slot_3.item_equipped.connect(_on_weapon_equipped.bind(2))

	weapon_slot_1.item_unequipped.connect(_on_weapon_unequipped.bind(0))
	weapon_slot_2.item_unequipped.connect(_on_weapon_unequipped.bind(1))
	weapon_slot_3.item_unequipped.connect(_on_weapon_unequipped.bind(2))

	# Get inventory reference
	inventory_ref = get_node_or_null("../../..")
	if inventory_ref:
		print("CharacterPanel: Inventory reference found")
	else:
		print("CharacterPanel: WARNING - Could not find inventory")

func set_player(p):
	print("🔵 CharacterPanel.set_player() called")
	print("   New player: ", p)
	player = p
	print("   player property after set: ", player)
	update_from_player()

func update_from_player():
	print("🔵 CharacterPanel.update_from_player() called")
	print("   player: ", player)
	if not player:
		print("   ❌ player is null, returning")
		return

	print("   player.equipped_weapons: ", player.equipped_weapons)

	# Update weapon slots from player's equipped weapons
	var slots = [weapon_slot_1, weapon_slot_2, weapon_slot_3]
	for i in range(3):
		if player.equipped_weapons[i] != null:
			var weapon_data = player.equipped_weapons[i]
			var item = {
				"name": weapon_data.weapon_name,
				"type": "weapon",
				"data": weapon_data
			}
			print("   Updating slot ", i, " with ", weapon_data.weapon_name)
			slots[i].equip_item(item)
		else:
			print("   Clearing slot ", i)
			slots[i].clear_slot()

func _on_weapon_equipped(slot_type, item: Dictionary, slot_index: int):
	if not player:
		return

	# Equip weapon to player
	if item.type == "weapon" and item.has("data"):
		var weapon_data = item.data as WeaponData
		player.equipped_weapons[slot_index] = weapon_data

		# Auto-switch to this weapon
		player.switch_weapon(slot_index)
		print("Equipped ", weapon_data.weapon_name, " to slot ", slot_index + 1)

		# Notify inventory to update (in case item came from inventory)
		notify_inventory_update()

func _on_weapon_unequipped(slot_type, slot_index: int):
	if not player:
		return

	player.equipped_weapons[slot_index] = null

	# If this was the active weapon, clear it
	if player.current_weapon_slot == slot_index:
		player.current_weapon_data = null
		player.ammo = 0
		player.update_weapon_model()

	print("Unequipped weapon from slot ", slot_index + 1)

func get_equipped_item(slot_index: int) -> Dictionary:
	var slots = [weapon_slot_1, weapon_slot_2, weapon_slot_3]
	if slot_index >= 0 and slot_index < slots.size():
		return slots[slot_index].equipped_item
	return {}

func notify_inventory_update():
	# Notify parent inventory to update
	var inventory = get_node_or_null("../../..")
	if inventory and inventory.has_method("update_inventory_display"):
		inventory.update_inventory_display()
