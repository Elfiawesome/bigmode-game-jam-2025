extends CardAbility

func _tick() -> void:
	var to_split: Array[float]
	for item in card_module.storage:
		if item.item_id == "power_orb":
			item.amount = item.amount/2
			to_split.push_back(item.amount)
		
	for item in to_split:
		card_module.generate_power(item)
		card_module.storage[-1].stats.speed.add(1, card_module, 1)
