class_name SimulationManager extends Node

enum State { READY, PHASE_WAITING, COMPLETED }

var _current_state: State = State.READY
var _phases_kickstart: Array[PhaseBase]
var _phases: Array[PhaseBase]
var _phase_index: int = 0
var _module_panel: ModulePanel
func _init(module_panel: ModulePanel) -> void:
	_module_panel = module_panel
	_phases_kickstart = [
		KickStartPhase.new(self, module_panel),
		PowerGenerationPhase.new(self, module_panel)
	]
	_phases = [
		MovingPhase.new(self, module_panel),
		TickPowerOrbPhase.new(self, module_panel),
		TickCardPhase.new(self, module_panel)
	]

func start_simulation() -> void:
	if _current_state == State.READY:
		for phase in _phases_kickstart:
			phase.execute()
		_current_state = State.PHASE_WAITING

func _process(delta: float) -> void:
	if _current_state == State.PHASE_WAITING:
		if !AnimateHandler.is_animating():
			_phase_next()
	if _current_state == State.COMPLETED:
		_module_panel.reset_speed_multiplier()
		_current_state = State.READY

func _phase_next() -> void:
	_phases[_phase_index].execute()
	_current_state = State.PHASE_WAITING
	
	if _phases[_phase_index].check_return():
		_current_state = State.COMPLETED
	_phase_index = wrap(_phase_index + 1, 0, _phases.size())


class PhaseBase extends RefCounted:
	var module_panel: ModulePanel
	func _init(_simulation_manager:SimulationManager, _module_panel: ModulePanel) -> void:
		module_panel = _module_panel
	func execute() -> void: run()
	func run() -> void: pass
	func check_return() -> bool:
		return false

class KickStartPhase extends PhaseBase:
	func run() -> void:
		for card in module_panel.cards:
			card.activate(card.ABILITY_TRIGGER.ON_START)

class PowerGenerationPhase extends PhaseBase:
	func run() -> void:
		for card in module_panel.cards:
			card.activate(card.ABILITY_TRIGGER.ON_POWER_GENERATION)

class MovingPhase extends PhaseBase:
	func run() -> void:
		for card in module_panel.cards:
			card._throw_orbs()
		for card in module_panel.cards:
			card._swallow_orbs()
			module_panel.end_card._swallow_orbs()
		module_panel._arrange_power_orbs()
		
		if !module_panel.power_orbs.is_empty():
			module_panel.tick_speed_multiplier()

class TickPowerOrbPhase extends PhaseBase:
	func run() -> void:
		var destroyed_queue: Array[PowerOrb] = []
		for power_orb in module_panel.power_orbs:
			if power_orb.energy <= 0:
				destroyed_queue.push_back(power_orb)
		for power_orb in destroyed_queue:
			module_panel.destroy_power_orb(power_orb)
		
		for power_orb in module_panel.end_card.power_orbs:
			module_panel.absorb_power_orb(power_orb)
			module_panel.end_card.power_orbs.erase(power_orb)

class TickCardPhase extends PhaseBase:
	func run() -> void:
		for card in module_panel.cards:
			card.activate(card.ABILITY_TRIGGER.ON_TICK)
	func check_return() -> bool:
		if module_panel.power_orbs.is_empty():
			for card in module_panel.cards:
				card.activate(card.ABILITY_TRIGGER.ON_SIM_END_TICK)
			return true
		else:
			return false
