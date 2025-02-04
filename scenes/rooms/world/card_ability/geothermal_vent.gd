extends CardAbility

func _initialization() -> void:
	for _card_module in get_neighbours():
		if _card_module.card_id == "water_wheel":
			_card_module.stats.power_output.add(_card_module.stats.power_output.total() * 0.05, card_module, 4)
	card_module.stats.transmission_strength.add(randi_range(0,5), card_module, 0)
	card_module.stats.resistance.add(snapped(randf_range(0,2), 0.1), card_module, 0)
