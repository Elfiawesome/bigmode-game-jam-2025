extends CardAbility


func _tick() -> void:
	if !used:
		card_module.play_display.add_card_module("toasted_bread")
		var toasted_bread := card_module.play_display.card_modules[-1]
		
		for _card_module in card_module.play_display.card_modules:
			_card_module.stats.resistance.add(-0.1, card_module)
			_card_module.stats.power_output.add(+0.1, card_module)
		used = true
