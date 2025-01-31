extends CardAbility

func _on_power_generation() -> void:
	var cards: Array[Card] = [
		parent_card.module_panel.get_card(parent_card.card_pos + 1),
		parent_card.module_panel.get_card(parent_card.card_pos - 1)
	]
	var bonus_power: int = 0
	var resistance_bonus: bool = false
	for card in cards:
		if card.card_id == "coal_mine":
			if bonus_power==0:
				bonus_power += 8
		if card.card_id == "transmission_tower":
			if !resistance_bonus:
				parent_card.resistance.add(-3, parent_card, 0)
				resistance_bonus = true
	var power_orb := parent_card.module_panel.add_power_orb(parent_card, parent_card.power_generation.retrieve() + bonus_power)
