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
	if typeof(data) == TYPE_DICTIONARY and data.has("item"):
		return can_equip_item(data.item)
	return false

func _drop_data(at_position: Vector2, data: Variant):
	if typeof(data) == TYPE_DICTIONARY and data.has("item"):
		var item = data.item
		if can_equip_item(item):
			# If slot already has an item, swap them
			if has_item:
				var old_item = unequip_item()
				if data.has("source_slot"):
					data.source_slot.receive_item(old_item)
			equip_item(item)

			# Remove from source
			if data.has("source_slot"):
				data.source_slot.remove_item()

			# If item came from inventory (has item_index), remove it from player inventory
			if data.has("item_index") and data.item_index >= 0:
				var player = get_player()
				if player and player.inventory.size() > data.item_index:
					player.inventory.remove_at(data.item_index)
					print("Removed item from inventory index ", data.item_index)

func _get_drag_data(at_position: Vector2) -> Variant:
	if not has_item:
		return null

	# Create preview
	var preview = PanelContainer.new()
	var label = Label.new()
	label.text = icon_label.text
	label.add_theme_font_size_override("font_size", 48)
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
	# Navigate up to CharacterPanel then to get player reference
	var char_panel = get_parent().get_parent()
	if char_panel and char_panel.has_method("set_player"):
		return char_panel.player
	return null

func receive_item(item: Dictionary):
	# This is used when swapping from equipment slot
	# For now we don't allow putting items back
	pass
