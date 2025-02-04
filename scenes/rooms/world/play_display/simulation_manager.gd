class_name SimulationManager extends Node

signal finished_turn()

enum State { READY, PHASE_WAITING, COMPLETED }

var _current_state: State = State.READY
var _phases_kickstart: Array[PhaseBase]
var _phases: Array[PhaseBase]
var _phase_index: int = 0

func _init(_play_display: PlayDisplay) -> void:
	PhaseBase.play_display = _play_display
	_phases_kickstart = [
		IntializationPhase.new(),
		InitialPowerGenerationPhase.new()
	]
	_phases = [
		CardTickPhase.new(),
		ItemTickPhase.new(),
		MoveItemsPhase.new(),
		EndTickPhase.new()
	]

func _process(_delta: float) -> void:
	if _current_state == State.PHASE_WAITING:
		if !AnimateHandler.is_animating():
			_phase_next()
	if _current_state == State.COMPLETED:
		AnimateHandler.reset_speed()
		finished_turn.emit()
		_current_state = State.READY

func _phase_next() -> void:
	_phases[_phase_index].execute()
	_current_state = State.PHASE_WAITING
	
	if _phases[_phase_index].check_return():
		_current_state = State.COMPLETED
	_phase_index = wrap(_phase_index + 1, 0, _phases.size())

func start_simulation() -> bool:
	if _current_state == State.READY:
		AnimateHandler.reset_speed()
		_phase_index = 0
		for phase in _phases_kickstart:
			phase.execute()
		_current_state = State.PHASE_WAITING
		return true
	else:
		return false

class PhaseBase extends RefCounted:
	static var play_display: PlayDisplay
	func execute() -> void: run()
	func run() -> void: pass
	func check_return() -> bool: return false

class IntializationPhase extends PhaseBase:
	func run() -> void:
		for card_module in play_display.card_modules:
			card_module.on_initialization_phase()
class InitialPowerGenerationPhase extends PhaseBase:
	func run() -> void:
		for card_module in play_display.card_modules:
			card_module.on_initial_power_generation_phase()

class CardTickPhase extends PhaseBase:
	var is_items_running: bool = false
	func run() -> void:
		is_items_running = false
		for card_module in play_display.card_modules:
			card_module.on_card_tick_phase()
			if card_module.storage.size() > 0:
				is_items_running = true
		play_display._end_power_depot.on_card_tick_phase()
		if play_display._end_power_depot.storage.size() > 0: is_items_running = true
	func check_return() -> bool:
		if !is_items_running:
			for card_module in play_display.card_modules:
				card_module.on_end_simulation_phase()
			return true
		else:
			return false
class ItemTickPhase extends PhaseBase:
	func run() -> void:
		for card_module in play_display.card_modules:
			card_module.on_item_tick_phase()
class MoveItemsPhase extends PhaseBase:
	func run() -> void:
		var item_movements: Array = []
		for card_module in play_display.card_modules:
			var card_module_transmission_strength := card_module.stats.transmission_strength.total()
			var card_module_resistance := card_module.stats.resistance.total()
				
			for item in card_module.storage:
				var movement_direction := card_module.stats.direction * item.stats.direction
				var movement_amount := card_module_transmission_strength + item.stats.speed.total()
				var movement := movement_amount*movement_direction
				item_movements.push_back(
					[item, card_module.card_pos + movement, item.global_position]
				)
				
				if item.item_id == "power_orb":
					if card_module_resistance!=0:
						item.add_amount(-card_module_resistance)
			card_module.clear_storage()
		
		var item_animations: Array = []
		for i: Array in item_movements:
			var item: Item = i[0]
			var item_destination_pos: int = i[1]
			var item_original_position: Vector2 = i[2]
			
			var new_card_module := play_display.get_card_module(item_destination_pos)
			new_card_module.add_to_storage(item, false)
			item.global_position = item_original_position
			
			item_animations.push_back([new_card_module, item])
		
		for i: Array in item_animations:
			var card_module: CardModule = i[0]
			var item: Item = i[1]
			
			var tween := AnimateHandler.create_tween_to_queue()
			tween.set_parallel(true)
			var end_position: Vector2 = card_module._get_position_of_item(card_module.storage.find(item), item.size)
			tween.tween_property(item, "position", end_position, .5).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(item, "scale", Vector2.ONE * 1.3, .25).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(item, "scale", item.scale, .25).set_delay(.25).set_trans(Tween.TRANS_CUBIC)
class EndTickPhase extends PhaseBase:
	func run() -> void:
		var all_modules: Array = play_display.card_modules.duplicate()
		all_modules.push_back(play_display._end_power_depot)
		for card_module:CardModule in all_modules:
			var to_destroy: Array[Item]
			for item in card_module.storage:
				if item.amount <= 0:
					to_destroy.push_back(item)
			for item in to_destroy:
				card_module.remove_from_storage(item)
				item.animate_destroy()
		AnimateHandler.speed_up()
