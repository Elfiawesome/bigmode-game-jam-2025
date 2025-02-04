extends CardAbility

func _initialization() -> void:
	for _card_module in get_neighbours():
		if _card_module.card_id == "transmission_tower":
			card_module.stats.resistance.add(-4.5, card_module, 0)
			break

func _initial_power_generation(_power: float) -> float:
	var bonus_power := 0.0
	for _card_module in get_neighbours():
		if _card_module.card_id == "coal_mine":
			bonus_power += 8
			break
	return bonus_power
