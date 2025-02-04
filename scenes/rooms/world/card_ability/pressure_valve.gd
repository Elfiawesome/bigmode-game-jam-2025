extends CardAbility

func _tick() -> void:
	var to_combine: Array[Item] = []
	for item in card_module.storage:
		if item.item_id == "power_orb":
			to_combine.push_back(item)
	
	if to_combine.size() > 1:
		var total_power: float = 0
		for item in to_combine:
			item.card_module.remove_from_storage(item)
			item.animate_destroy()
			total_power += item.amount
		card_module.generate_power(total_power * 1.25)
		
		card_module.animate_bounce()
