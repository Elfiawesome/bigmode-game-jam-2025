extends CardAbility

func _initialization() -> void:
	for _card_module in get_neighbours():
		if _card_module.stats.resistance.total() > 0:
			_card_module.stats.resistance.add(-.75, card_module, 0)
