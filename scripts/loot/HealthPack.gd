extends LootBase

@export var heal_amount = 30.0

func _ready():
	super._ready()
	item_name = "Health Pack"

func pickup(player):
	if player.has_method("heal"):
		player.heal(heal_amount)
		print("Healed for ", heal_amount, " HP")
		queue_free()
