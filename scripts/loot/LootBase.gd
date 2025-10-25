extends StaticBody3D

class_name LootBase

@export var item_name = "Item"
@export var rotate_speed = 1.0

@onready var mesh = $MeshInstance3D

func _ready():
	add_to_group("loot")

func _process(delta):
	# Rotate the item slowly for visual effect
	rotate_y(rotate_speed * delta)

func pickup(player):
	# Override this in child classes
	pass
