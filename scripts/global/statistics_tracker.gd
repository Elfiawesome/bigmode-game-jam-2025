extends Node

var statistics: Dictionary = {}

func _ready() -> void:
	reset_statistics()

func reset_statistics() -> void:
	statistics = {
		"card_stats": {
			
		}
	}

func get_card_statistics(card_id: String) -> Dictionary:
	if !(card_id in statistics["card_stats"]):
		statistics["card_stats"][card_id] = {
			"most_power_generated": 0.0,
			"total_power_generated": 0.0,
			"cards_played": 0.0,
			"times_ticked": 0,
			"times_appeared_on_shop": 0,
			"power_contributed": 0.0,
		}
	return statistics["card_stats"][card_id]
func calculate_card_score(card_statistics: Dictionary) -> float:
	return (
		card_statistics["power_contributed"]
	)
func card_generated_power(card_id: String, power_generated: float) -> void:
	var card_statistics := get_card_statistics(card_id)
	card_statistics["total_power_generated"] += power_generated
	if power_generated > card_statistics["most_power_generated"]:
		card_statistics["most_power_generated"] = power_generated

func card_contribute_power(card_id: String, power_contributed: float) -> void:
	var card_statistics := get_card_statistics(card_id)
	card_statistics["power_contributed"] += power_contributed

func generate_leaderboard() -> Array[Dictionary]:
	var leaderboard: Array[Dictionary] = []
	for card_id: String in statistics["card_stats"]:
		var card_statistics: Dictionary = get_card_statistics(card_id)
		var score := calculate_card_score(card_statistics)
		leaderboard.push_back({
			"score": score,
			"card_id":card_id,
			"card_statistics": card_statistics,
		})
	
	leaderboard.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			if a["score"] > b["score"]:
				return true
			else:
				return false
	)
	return leaderboard
	
