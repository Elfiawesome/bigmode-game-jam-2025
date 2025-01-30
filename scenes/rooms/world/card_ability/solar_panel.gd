extends CardAbility

func _on_start() -> void:
	var power_orb := parent_card.module_panel.add_power_orb(parent_card, 0.5)
