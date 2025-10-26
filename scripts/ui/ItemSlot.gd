extends PanelContainer

@onready var item_icon = $VBoxContainer/ItemIcon
@onready var icon_label = $VBoxContainer/ItemIcon/IconLabel
@onready var item_name_label = $VBoxContainer/ItemName

func set_item(item_name: String):
	item_name_label.text = item_name

	# Set icon based on item type
	if "Pistol" in item_name or "Weapon" in item_name:
		icon_label.text = "🔫"
		item_icon.color = Color(0.3, 0.3, 0.3, 1)
	elif "Health" in item_name:
		icon_label.text = "❤"
		item_icon.color = Color(1, 0.2, 0.2, 1)
	else:
		icon_label.text = "📦"
		item_icon.color = Color(0.5, 0.5, 0.5, 1)
