extends CardAbility

func _initial_power_generation(_power: float) -> float:
	var bonus_power := 0.0
	for _card_module in get_neighbours():
		if card_module.card_id == _card_module.card_id:
			bonus_power -= 2.75
			break
	return bonus_power
