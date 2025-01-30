extends CardAbility

func _on_tick() -> void:
	for power_orb in parent_card.power_orbs:
		pass#power_orb.energy += 10
