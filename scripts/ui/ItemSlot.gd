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
