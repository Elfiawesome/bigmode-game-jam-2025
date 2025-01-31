extends CardAbility

func _on_start() -> void:
	var card := parent_card.module_panel.get_card(parent_card.card_pos + 1)
	if card.card_id: card.resistance.add(-0.5, parent_card, 0)
	card = parent_card.module_panel.get_card(parent_card.card_pos - 1)
	if card.card_id: card.resistance.add(-0.5, parent_card, 0)
func _on_sim_end_tick() -> void:
	cooldown -= 1
