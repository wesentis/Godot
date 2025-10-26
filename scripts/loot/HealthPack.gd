extends LootBase

@export var heal_amount = 50.0

func _ready():
	super._ready()
	item_name = "Health Pack"

func pickup(player):
	if player.has_method("add_to_inventory"):
		# Add to inventory instead of using immediately
		player.add_to_inventory("Health Pack", "health", {"heal_amount": heal_amount})
		print("Added Health Pack to inventory")
		queue_free()
