extends CardAbility

func _initialization() -> void:
	for _card_module in get_neighbours():
		_card_module.stats.power_output.add(+1.2, card_module, 0)
