class_name CardAbility extends RefCounted

var card_module: CardModule
var cooldown: int = 0
var used: bool = false

func _initialization() -> void:
	# When just turn starts
	pass

func get_neighbours() -> Array[CardModule]:
	var arr:Array[CardModule] = [
		card_module.play_display.get_card_module(card_module.card_pos + 1),
		card_module.play_display.get_card_module(card_module.card_pos - 1)
	]
	if arr.has(card_module.play_display._end_power_depot): arr.erase(card_module.play_display._end_power_depot)
	return arr

func _initial_power_generation(_output_power: float) -> float:
	# When just turn starts and used to edit power
	return 0.0

func _tick() -> void:
	# Every time the tick
	pass
