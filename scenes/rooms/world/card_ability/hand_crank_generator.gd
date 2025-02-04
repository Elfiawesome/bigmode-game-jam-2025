extends CardAbility

func _initial_power_generation(_power: float) -> float:
	var bonus_power := 0.0
	for _card_module in get_neighbours():
		if _card_module.card_id != "end_power_depot":
			bonus_power -= 1.25
	return bonus_power
