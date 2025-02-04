extends CardAbility

func _tick() -> void:
	if !used:
		var to_combine: Array[Item] = []
		for _card_module in get_neighbours():
			for item in _card_module.storage:
				if item.item_id == "power_orb":
					to_combine.push_back(item)
		
		if !to_combine.is_empty():
			var total_power: float = 0.0
			for item in to_combine:
				item.card_module.remove_from_storage(item)
				item.z_index = 1
				
				var end_position: Vector2 = card_module.to_global(Vector2(0,0) - item.size/2)
				var tween := AnimateHandler.create_tween_to_queue()
				tween.set_parallel(true)
				tween.tween_property(item, "global_position", end_position, .25).set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(item, "scale", Vector2.ONE * 1.3, .25/2).set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(item, "scale", item.scale, .25).set_delay(.25/2).set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(item, "scale", item.scale*0, .25).set_delay(.25).set_trans(Tween.TRANS_CUBIC)
				tween.finished.connect(func()->void:item.animate_destroy())
				
				total_power += item.amount
			card_module.generate_power(total_power)
			
			card_module.animate_bounce()
			used = true
