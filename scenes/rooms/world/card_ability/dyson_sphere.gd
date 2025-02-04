extends CardAbility

func _initialization() -> void:
	for _card_module in card_module.play_display.card_modules:
		if _card_module.card_id != "solar_panel":
			_card_module.stats.resistance.add(1.2, card_module, 0)
	

func _initial_power_generation(_power: float) -> float:
	var bonus_power := 0.0
	for _card_module in card_module.play_display.card_modules:
		if _card_module.card_id == "solar_panel":
			bonus_power += 2.5
		else:
			bonus_power -= 2
	bonus_power = max(bonus_power, 0)
	return bonus_power
