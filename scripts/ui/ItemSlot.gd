extends PanelContainer

@onready var item_icon = $VBoxContainer/ItemIcon
@onready var icon_label = $VBoxContainer/ItemIcon/IconLabel
@onready var item_name_label = $VBoxContainer/ItemName

var item_index: int = -1
var item_data: Dictionary = {}

signal item_used(index: int)
signal item_dropped(index: int)

func _ready():
	gui_input.connect(_on_gui_input)

func set_item(item: Dictionary, index: int):
	item_data = item
	item_index = index
	item_name_label.text = item.name

	# Set icon based on item type
	if item.type == "weapon":
		var weapon_data = item.data as WeaponData
		if weapon_data:
			icon_label.text = weapon_data.icon_emoji
			item_icon.color = Color.from_hsv(0.0, 0.0, 0.3)
	elif item.type == "health":
		icon_label.text = "❤"
		item_icon.color = Color(1, 0.2, 0.2, 1)
	else:
		icon_label.text = "📦"
		item_icon.color = Color(0.5, 0.5, 0.5, 1)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			show_context_menu()

func show_context_menu():
	var popup = PopupMenu.new()
	add_child(popup)

	# Different menu for different item types
	if item_data.type == "health":
		popup.add_item("Kullan (Can Doldur)", 0)
		popup.add_item("At", 1)
	elif item_data.type == "weapon":
		popup.add_item("Kuşan", 0)
		popup.add_item("At", 1)
	else:
		popup.add_item("Kullan", 0)
		popup.add_item("At", 1)

	popup.id_pressed.connect(_on_context_menu_choice)
	popup.popup_on_parent(Rect2(get_global_mouse_position(), Vector2.ZERO))

func _on_context_menu_choice(id: int):
	match id:
		0:  # Use
			item_used.emit(item_index)
		1:  # Drop
			item_dropped.emit(item_index)

# Drag & Drop functionality
func _get_drag_data(at_position: Vector2) -> Variant:
	if item_data.is_empty():
		return null

	# Create preview
	var preview = PanelContainer.new()
	var label = Label.new()
	label.text = icon_label.text
	label.add_theme_font_size_override("font_size", 48)
	preview.add_child(label)
	set_drag_preview(preview)

	return {
		"item": item_data,
		"source_slot": self,
		"item_index": item_index
	}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Can always drop data into inventory slots (for swapping)
	return typeof(data) == TYPE_DICTIONARY and data.has("item")

func _drop_data(at_position: Vector2, data: Variant):
	if typeof(data) == TYPE_DICTIONARY and data.has("item"):
		# This is handled by the Inventory script
		pass

func receive_item(item: Dictionary):
	# Used when swapping items from equipment slots
	item_data = item
	set_item(item, item_index)

func remove_item():
	item_data = {}
	icon_label.text = ""
	item_name_label.text = ""
	item_icon.color = Color(0.5, 0.5, 0.5, 0.3)
