extends CardAbility

func _tick() -> void:
	card_module.play_display.move_card_module(
		card_module, 
		randi_range(0, card_module.play_display.card_modules.size()-1)
	)
