extends CardAbility

func _on_power_generation() -> void:
	var cards: Array[Card] = [
		parent_card.module_panel.get_card(parent_card.card_pos + 1),
		parent_card.module_panel.get_card(parent_card.card_pos - 1)
	]
	var bonus_power: int = 0
	for card in cards:
		if card.card_id == "solar_panel":
			bonus_power += 1
	var power_orb := parent_card.module_panel.add_power_orb(parent_card, parent_card.power_generation.retrieve() + bonus_power)
