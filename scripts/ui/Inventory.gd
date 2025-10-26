extends Control

@onready var items_container = $Panel/ItemsContainer
@onready var close_button = $Panel/CloseButton

var player = null
var item_slot_scene = preload("res://scenes/ui/ItemSlot.tscn")

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	visible = !visible
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		update_inventory_display()
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
	for item in player.inventory:
		var slot = item_slot_scene.instantiate()
		items_container.add_child(slot)
		slot.set_item(item)

func set_player(p):
	player = p

func _on_close_button_pressed():
	toggle_inventory()
