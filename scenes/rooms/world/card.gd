class_name Card extends Node2D

class StackedDataFloat:
	var _array: Array = []
	func add(value: float, card: Card = null, time: int = -1) -> void:
		_array.push_back([value, card, time])
	func retrieve() -> float:
		var total_value: float
		for value: Array in _array:
			total_value += value[0]
		return total_value
	func tick() -> void:
		var to_remove: Array[Array] = []
		for value: Array in _array:
			if value[2] != -1:
				if value[2] > 0:
					value[2] -=1
				else:
					to_remove.push_back(value)
		for value in to_remove:
			_array.erase(value)


signal mouse_entered(card: Card)
signal mouse_exited(card: Card)
signal clicked(card: Card)
signal released(card: Card)
# References
var card_id: String
var card_pos: int
var module_panel: ModulePanel

var power_orbs: Array[PowerOrb] = []
var _waiting_power_orbs: Array[PowerOrb] = []
var card_ability: CardAbility:
	set(ability):
		card_ability = ability
		card_ability.parent_card = self

var resistance := StackedDataFloat.new()
var power_generation := StackedDataFloat.new()
var transmission_strength := StackedDataFloat.new()

enum CARD_STATE {
	IDLE = 0,
	DRAG
}
var card_state: CARD_STATE = CARD_STATE.IDLE

@onready var _card_collision: Control = $CardBase/Control
@onready var _module_icon: Sprite2D = $CardBase/Control/MarginContainer/VBoxContainer/TopPanel/ModuleIcon
@onready var _name_label: Label = $CardBase/Control/MarginContainer/VBoxContainer/BottomPanel/NameLabel

func _ready() -> void:
	_card_collision.gui_input.connect(
		func(event: InputEvent) -> void:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						z_index = 1
						_animate_bounce(1.1)
						clicked.emit(self)
					else:
						z_index = 0
						_animate_bounce(.9)
						released.emit(self)
	)
	_card_collision.mouse_entered.connect(func()->void:
		mouse_entered.emit(self)
	)
	_card_collision.mouse_exited.connect(func()->void:mouse_exited.emit(self))

func _process(delta: float) -> void:
	$Label.text = str(power_orbs.size())
	match card_state:
		CARD_STATE.DRAG:
			global_position = get_global_mouse_position()

enum ABILITY_TRIGGER {
	ON_START,
	ON_POWER_GENERATION,
	ON_TICK,
	ON_SIM_END_TICK,
}

func activate(trigger: ABILITY_TRIGGER) -> void:
	match trigger:
		ABILITY_TRIGGER.ON_START:
			card_ability._on_start()
		ABILITY_TRIGGER.ON_POWER_GENERATION:
			card_ability._on_power_generation()
			_animate_bounce()
		ABILITY_TRIGGER.ON_TICK:
			card_ability._on_tick()
			if !power_orbs.is_empty():
				_animate_bounce()
		ABILITY_TRIGGER.ON_SIM_END_TICK:
			# Tick all my cooldowns
			resistance.tick()
			power_generation.tick()
			card_ability._on_sim_end_tick()
func _throw_orbs(orbs := power_orbs) -> void:
	var destination_card := module_panel.get_card(card_pos+int(transmission_strength.retrieve()))
	if destination_card:
		for power_orb in orbs:
			power_orb.reduce_energy(resistance.retrieve())
			destination_card._catch_orbs(power_orb)
		power_orbs.clear()
func _catch_orbs(power_orb: PowerOrb) -> void:
	power_orb.parent_card = self
	_waiting_power_orbs.push_back(power_orb)
func _swallow_orbs() -> void:
	power_orbs.append_array(_waiting_power_orbs)
	_waiting_power_orbs.clear()

func _animate_bounce(tgt_scale: float = 1.1) -> void:
	var tween := AnimateHandler.create_tween_to_queue()
	var spd := module_panel.get_speed_multiplier()
	tween.tween_property(self, "scale", Vector2.ONE*tgt_scale, 0.1 * spd).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3 * spd).set_trans(Tween.TRANS_SPRING)

@onready var _arrow: Sprite2D = $Arrow
func show_arrow() -> void:
	if !_arrow.visible:
		_arrow.visible = true
		_arrow.scale = Vector2.ZERO
		var tween := AnimateHandler.create_tween_to_queue()
		tween.tween_property(_arrow, "scale", Vector2(.3,2), 0.3 * module_panel.get_speed_multiplier()).set_trans(Tween.TRANS_SPRING)
func hide_arrow() -> void:
	var tween := AnimateHandler.create_tween_to_queue()
	tween.tween_property(_arrow, "scale", Vector2.ZERO, 0.3 * module_panel.get_speed_multiplier()).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(_arrow, "visible", false, 0)
