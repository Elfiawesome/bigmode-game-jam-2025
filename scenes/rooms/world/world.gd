class_name World extends Room

@onready var module_panel: ModulePanel = $CanvasLayer/Panel/MarginContainer/VBoxContainer/HBoxContainer/ModulePanel
@onready var _card_tooltip: CardToolTip = $CanvasLayer/Panel/CardTooltip
@onready var _simulation_start_button: Panel = $CanvasLayer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/PowerOnPanel
@onready var _power_level_label: Label = $CanvasLayer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/QuotaPanel/MarginContainer/VBoxContainer/HBoxContainer/Power
@onready var _quota_level_label: Label = $CanvasLayer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/QuotaPanel/MarginContainer/VBoxContainer/HBoxContainer/Quota

var power_quota: float = 100.0
var turns_to_quota: bool = 5

var simulation_manager: SimulationManager

func register_card(card_id: String) -> void:
	Registries.register_resource(Registries.CARDABILITY, card_id, load("res://scenes/rooms/world/card_ability/"+card_id+".gd"))
	Registries.register_resource(Registries.CARDRESOURCE, card_id, load("res://scenes/rooms/world/card_resource/"+card_id+".tres"))
	

func _ready() -> void:
	register_card("solar_panel")
	register_card("overclocker")
	register_card("coal_mine")
	register_card("water_wheel")
	register_card("water_cooling_pump")
	register_card("hand_crank_generator")
	register_card("coal_plant")
	register_card("transmission_tower")
	simulation_manager = SimulationManager.new(module_panel)
	add_child(simulation_manager)
	
	module_panel.mouse_entered_on_card.connect(
		func(card: Card) -> void:
			if module_panel._dragged_card:
				return
			var card_resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, card.card_id)
			_card_tooltip.set_description(card, card_resource)
			_card_tooltip.show_tooltip()
	)
	module_panel.mouse_exited_on_card.connect(
		func(card: Card) -> void:
			_card_tooltip.hide_tooltip()
	)
	module_panel.card_dragged.connect(
		func(card: Card) -> void:
			_card_tooltip.hide_tooltip()
	)
	module_panel.power_level_changed.connect(
		func(new_power_level: float, changed: float) -> void:
			var _effect := preload("res://scenes/rooms/world/power_level_gain_effect.tscn").instantiate()
			$CanvasLayer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/QuotaPanel/MarginContainer/VBoxContainer/HBoxContainer/Power.add_child(_effect)
			_effect.set_value(changed)
			
			_power_level_label.text = str(new_power_level)
	)
	_simulation_start_button.button_pressed.connect(
		func() -> void: simulation_manager.start_simulation()
	)
	


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_ENTER:
			module_panel.add_card(
				Registries.registries[Registries.CARDRESOURCE].resources.keys().pick_random()
			)
		if event.pressed && event.keycode == KEY_SPACE:
			simulation_manager.start_simulation()
