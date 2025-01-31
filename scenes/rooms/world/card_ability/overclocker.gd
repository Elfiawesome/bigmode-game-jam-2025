extends CardAbility

func _on_start() -> void:
	if cooldown == 0:
		var card := parent_card.module_panel.get_card(parent_card.card_pos + 1)
		if card.card_id: card.power_generation.add(1.5, parent_card, 0)
		card = parent_card.module_panel.get_card(parent_card.card_pos - 1)
		if card.card_id: card.power_generation.add(1.5, parent_card, 0)
		cooldown = 1+1
	else:
		parent_card.resistance.add(2.5, parent_card, 0)
func _on_sim_end_tick() -> void:
	cooldown -= 1
