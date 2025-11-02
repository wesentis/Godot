extends Control

@onready var items_container = $CenterContainer/HBoxContainer/InventoryPanel/MarginContainer/VBoxContainer/ScrollContainer/ItemsContainer
@onready var close_button = $CenterContainer/HBoxContainer/InventoryPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var character_panel = $CenterContainer/HBoxContainer/CharacterPanel

var player = null
var item_slot_scene = preload("res://scenes/ui/ItemSlot.tscn")

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	visible = !visible
	print("🟢 Inventory toggled, visible: ", visible)
	if visible:
		print("   character_panel: ", character_panel)
		print("   character_panel.player: ", character_panel.player if character_panel else "N/A")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		update_inventory_display()
		if character_panel:
			print("   Calling character_panel.update_from_player()")
			character_panel.update_from_player()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false

func update_inventory_display():
	# Clear existing slots
	for child in items_container.get_children():
		child.queue_free()

	if not player:
		return

	# Create slots for each item
	for i in range(player.inventory.size()):
		var item = player.inventory[i]
		var slot = item_slot_scene.instantiate()
		items_container.add_child(slot)
		slot.set_item(item, i)

		# Connect signals
		slot.item_used.connect(_on_item_used)
		slot.item_dropped.connect(_on_item_dropped)

func _on_item_used(item_index: int):
	if player and player.has_method("use_item"):
		player.use_item(item_index)
		update_inventory_display()
		if character_panel:
			character_panel.update_from_player()

func _on_item_dropped(item_index: int):
	if player and player.has_method("drop_item"):
		player.drop_item(item_index)
		update_inventory_display()
		if character_panel:
			character_panel.update_from_player()

func set_player(p):
	print("🟢 Inventory.set_player() called")
	print("   Player: ", p)
	print("   character_panel exists: ", character_panel != null)
	player = p
	if character_panel:
		print("   Calling character_panel.set_player()")
		character_panel.set_player(p)
	else:
		print("   ❌ ERROR: character_panel is null!")

func _on_close_button_pressed():
	toggle_inventory()
