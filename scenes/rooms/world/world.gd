class_name World extends Room

@onready var module_panel: ModulePanel = $CanvasLayer/Panel/MarginContainer/VBoxContainer/ModulePanel
@onready var _power_level_label: Label = $CanvasLayer/Panel/MarginContainer/VBoxContainer/Control/LabelContainer/PowerLevel
@onready var _quota_label: Label = $CanvasLayer/Panel/MarginContainer/VBoxContainer/Control/LabelContainer/Quota
@onready var _card_tooltip: CardToolTip = $CanvasLayer/Panel/CardTooltip
var power_quota: float = 100.0
var turns_to_quota: bool = 5

var simulation_manager: SimulationManager

func _ready() -> void:
	Registries.register_resource(Registries.CARDABILITY, "solar_panel", load("res://scenes/rooms/world/card_ability/solar_panel.gd"))
	Registries.register_resource(Registries.CARDRESOURCE, "solar_panel", load("res://scenes/rooms/world/card_resource/solar_panel.tres"))
	Registries.register_resource(Registries.CARDABILITY, "overclocker", load("res://scenes/rooms/world/card_ability/overclocker.gd"))
	Registries.register_resource(Registries.CARDRESOURCE, "overclocker", load("res://scenes/rooms/world/card_resource/overclocker.tres"))
	Registries.register_resource(Registries.CARDABILITY, "coal_mine", load("res://scenes/rooms/world/card_ability/coal_mine.gd"))
	Registries.register_resource(Registries.CARDRESOURCE, "coal_mine", load("res://scenes/rooms/world/card_resource/coal_mine.tres"))
	Registries.register_resource(Registries.CARDABILITY, "water_wheel", load("res://scenes/rooms/world/card_ability/water_wheel.gd"))
	Registries.register_resource(Registries.CARDRESOURCE, "water_wheel", load("res://scenes/rooms/world/card_resource/water_wheel.tres"))
	Registries.register_resource(Registries.CARDABILITY, "water_cooling_pump", load("res://scenes/rooms/world/card_ability/water_cooling_pump.gd"))
	Registries.register_resource(Registries.CARDRESOURCE, "water_cooling_pump", load("res://scenes/rooms/world/card_resource/water_cooling_pump.tres"))
	Registries.register_resource(Registries.CARDABILITY, "hand_crank_generator", load("res://scenes/rooms/world/card_ability/hand_crank_generator.gd"))
	Registries.register_resource(Registries.CARDRESOURCE, "hand_crank_generator", load("res://scenes/rooms/world/card_resource/hand_crank_generator.tres"))
	simulation_manager = SimulationManager.new(module_panel)
	add_child(simulation_manager)
	
	module_panel.mouse_entered_on_card.connect(
		func(card: Card) -> void:
			print("Entered!")
			var card_resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, card.card_id)
			_card_tooltip.set_description(
				card_resource.name,
				"card_resource.description",
			)
			_card_tooltip.show_tooltip()
			
	)
	module_panel.mouse_exited_on_card.connect(
		func(card: Card) -> void:
			_card_tooltip.hide_tooltip()
	)

func _process(delta: float) -> void:
	_update_control_labels()

func _update_control_labels() -> void:
	_quota_label.text = str(power_quota)
	_power_level_label.text = str(module_panel.power_stored)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_ENTER:
			module_panel.add_card(["solar_panel","overclocker","coal_mine","water_wheel","water_cooling_pump","hand_crank_generator"].pick_random())
		if event.pressed && event.keycode == KEY_BACKSPACE:
			module_panel.cards.shuffle()
			module_panel._arrange_cards()
		if event.pressed && event.keycode == KEY_SPACE:
			simulation_manager.start_simulation()
