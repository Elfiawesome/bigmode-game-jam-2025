extends CardAbility


func _tick() -> void:
	if !used:
		for _card_module in card_module.play_display.card_modules:
			if _card_module.stats.resistance.total() > 0:
				_card_module.stats.resistance.add(-min(1, _card_module.stats.resistance.total()), card_module, 3)
		used = true
