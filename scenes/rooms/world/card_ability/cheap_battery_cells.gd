extends CardAbility

func _tick() -> void:
	var total_power_gained: float = 0
	for item:Item in card_module.storage.duplicate():
		if item.item_id == "power_orb":
			card_module.remove_from_storage(item)
			item.animation_absorbed()
			card_module.animate_bounce(1.1,10)
			total_power_gained += item.amount
			StatisticsTracker.card_contribute_power(item.creator_card_module.card_id, item.amount)
	
	if total_power_gained != 0:
		card_module.play_display.store_power(total_power_gained*.5)
		card_module.animate_bounce()
