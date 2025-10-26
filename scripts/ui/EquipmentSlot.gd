extends PanelContainer

enum SlotType {
	WEAPON_1,
	WEAPON_2,
	WEAPON_3,
	HELMET,
	CHEST,
	BOOTS
}

@onready var item_icon = $VBoxContainer/ItemIcon
@onready var icon_label = $VBoxContainer/ItemIcon/IconLabel
@onready var slot_label = $VBoxContainer/SlotLabel

@export var slot_type: SlotType = SlotType.WEAPON_1
var equipped_item: Dictionary = {}
var has_item: bool = false

signal item_equipped(slot_type: SlotType, item: Dictionary)
signal item_unequipped(slot_type: SlotType)

func _ready():
	update_slot_label()
	clear_slot()

func update_slot_label():
	match slot_type:
		SlotType.WEAPON_1:
			slot_label.text = "Weapon 1"
		SlotType.WEAPON_2:
			slot_label.text = "Weapon 2"
		SlotType.WEAPON_3:
			slot_label.text = "Weapon 3"
		SlotType.HELMET:
			slot_label.text = "Helmet"
		SlotType.CHEST:
			slot_label.text = "Chest"
		SlotType.BOOTS:
			slot_label.text = "Boots"

func can_equip_item(item: Dictionary) -> bool:
	# Check if item type matches slot type
	if item.type == "weapon":
		return slot_type in [SlotType.WEAPON_1, SlotType.WEAPON_2, SlotType.WEAPON_3]
	elif item.type == "helmet":
		return slot_type == SlotType.HELMET
	elif item.type == "chest":
		return slot_type == SlotType.CHEST
	elif item.type == "boots":
		return slot_type == SlotType.BOOTS
	return false

func equip_item(item: Dictionary):
	if not can_equip_item(item):
		return

	equipped_item = item
	has_item = true
	update_visual()
	item_equipped.emit(slot_type, item)

func unequip_item() -> Dictionary:
	var item = equipped_item
	equipped_item = {}
	has_item = false
	clear_slot()
	item_unequipped.emit(slot_type)
	return item

func clear_slot():
	icon_label.text = ""
	item_icon.color = Color(0.2, 0.2, 0.2, 0.5)
	has_item = false

func update_visual():
	if not has_item:
		clear_slot()
		return

	if equipped_item.type == "weapon":
		var weapon_data = equipped_item.data as WeaponData
		if weapon_data:
			icon_label.text = weapon_data.icon_emoji
			item_icon.color = Color.from_hsv(0.0, 0.0, 0.3)
	elif equipped_item.type in ["helmet", "chest", "boots"]:
		icon_label.text = "🛡"
		item_icon.color = Color(0.5, 0.5, 0.6, 1)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	print("=== _can_drop_data CALLED ===")
	print("Data type: ", typeof(data))

	if typeof(data) == TYPE_DICTIONARY:
		print("Data keys: ", data.keys())
		if data.has("item"):
			print("Item name: ", data.item.name)
			print("Item type: ", data.item.type)
			var can_equip = can_equip_item(data.item)
			if can_equip:
				print("✅ CAN EQUIP ", data.item.name, " to ", slot_label.text)
			else:
				print("❌ CANNOT EQUIP ", data.item.name, " to ", slot_label.text)
			return can_equip

	print("❌ Invalid data format")
	return false

func _drop_data(at_position: Vector2, data: Variant):
	if typeof(data) == TYPE_DICTIONARY and data.has("item"):
		var item = data.item
		if can_equip_item(item):
			print("=== EQUIPPING ITEM ===")
			print("Item: ", item.name, " to slot: ", slot_label.text)

			# Get player reference
			var player = get_player()
			if not player:
				print("ERROR: Could not get player reference!")
				return

			# If slot already has an item, return it to inventory
			if has_item:
				var old_item = unequip_item()
				print("Slot already had item: ", old_item.name)
				player.add_to_inventory(old_item.name, old_item.type, old_item.data)
				print("Returned old item to inventory")

			# Update visual in slot FIRST
			equip_item(item)

			# Update player's equipped weapons array
			var slot_index = get_slot_index()
			if slot_index >= 0 and item.type == "weapon" and item.has("data"):
				var weapon_data = item.data as WeaponData
				player.equipped_weapons[slot_index] = weapon_data
				print("Updated player.equipped_weapons[", slot_index, "] = ", weapon_data.weapon_name)

				# Switch to this weapon (this will update the visual model)
				player.switch_weapon(slot_index)
				print("Switched to weapon slot ", slot_index)

			# If item came from inventory, remove it from player inventory
			if data.has("item_index") and data.item_index >= 0:
				if data.item_index < player.inventory.size():
					player.inventory.remove_at(data.item_index)
					print("Removed item from inventory index ", data.item_index)

			# Remove from source slot visual
			if data.has("source_slot"):
				data.source_slot.remove_item()

			# Update inventory display
			var inv = get_parent_inventory()
			if inv:
				inv.update_inventory_display()
				print("Inventory display updated")
			else:
				print("WARNING: Could not find inventory to update")
			print("=== EQUIPPING COMPLETE ===")

func get_slot_index() -> int:
	match slot_type:
		SlotType.WEAPON_1:
			return 0
		SlotType.WEAPON_2:
			return 1
		SlotType.WEAPON_3:
			return 2
		_:
			return -1

func get_parent_inventory():
	# Get CharacterPanel first
	var char_panel = get_parent().get_parent()
	if char_panel and char_panel.has("inventory_ref"):
		if char_panel.inventory_ref:
			print("✅ Inventory found via CharacterPanel.inventory_ref")
			return char_panel.inventory_ref
		else:
			print("❌ CharacterPanel.inventory_ref is null")
	else:
		print("❌ Could not find CharacterPanel or inventory_ref")

	return null

func _get_drag_data(at_position: Vector2) -> Variant:
	if not has_item:
		print("Cannot drag - no item equipped")
		return null

	print("=== DRAGGING FROM EQUIPMENT ===")
	print("Item: ", equipped_item.name, " from slot: ", slot_label.text)

	# Create simple preview
	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(100, 100)

	var label = Label.new()
	label.text = icon_label.text
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(100, 100)

	preview.add_child(label)
	set_drag_preview(preview)

	return {
		"item": equipped_item,
		"source_slot": self
	}

func remove_item():
	equipped_item = {}
	has_item = false
	clear_slot()

func get_player():
	# Navigate up to CharacterPanel
	# EquipmentSlot → VBoxContainer → MarginContainer → CharacterPanel
	var current = get_parent()
	while current != null:
		if current.has_method("set_player") and current.has("player"):
			if current.player:
				print("✅ Found player via ", current.name)
				return current.player
			else:
				print("⚠️ Found CharacterPanel but player is null")
				return null
		current = current.get_parent()

	print("❌ Could not find CharacterPanel with player!")
	return null

func receive_item(item: Dictionary):
	# This is used when swapping from equipment slot to equipment slot
	print("Receiving item in equipment slot: ", item.name)
	equipped_item = item
	has_item = true
	update_visual()
	item_equipped.emit(slot_type, item)
