extends Control

var tween: Tween
var is_show := false
var hovered_card_module: CardModule
var timer_staring: float = 0.0


@onready var _tooltip_box: ColorRect = $TooltipBox
@onready var _name_label: Label = $TooltipBox/VBoxContainer/Name
@onready var _description_label: RichTextLabel = $TooltipBox/VBoxContainer/Description
@onready var _tooltip_container:=$TooltipBox/VBoxContainer

@onready var _stats_resistance_label: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/Resistance/Value
@onready var _stats_power_output_label: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/PowerOutput/Value
@onready var _stats_transmission_strength_label: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/TransmissionStrength/Value

func _ready() -> void:
	_tooltip_container.minimum_size_changed.connect(
		_on_expand_box
	)

func _on_expand_box() -> void:
	if is_show:
		if tween: tween.kill()
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(_tooltip_box, "visible", true, 1)
		tween.tween_property(_tooltip_box, "size", _tooltip_container.get_minimum_size(), .15).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(_tooltip_box, "modulate:a", 1, .15).set_trans(Tween.TRANS_LINEAR)

func show_tooltip() -> void:
	if !is_show:
		_power_output_meaning.visible = false
		_resistance_meaning.visible = false
		_transmission_strength_meaning.visible = false
		timer_staring = 0
		is_show = true
		_tooltip_box.size = Vector2.ZERO
		_on_expand_box()

func hide_tooltip() -> void:
	if is_show:
		if tween: tween.kill()
		is_show = false
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(_tooltip_box, "size", Vector2.ZERO, .15).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(_tooltip_box, "modulate:a", 0, .15).set_trans(Tween.TRANS_LINEAR)
		tween.chain()
		tween.tween_property(_tooltip_box, "visible", false, 1)

func _process(_delta: float) -> void:
	if is_show:
		position = get_global_mouse_position()
		position.x = min(position.x, get_viewport_rect().size.x - _tooltip_container.size.x)
		position.x = max(position.x, Vector2.ZERO.x)
		position.y = min(position.y, get_viewport_rect().size.y - _tooltip_container.size.y)
		position.y = max(position.y, Vector2.ZERO.y)
		timer_staring += _delta
		if timer_staring > 1.5:
			_power_output_meaning.visible = true
			_resistance_meaning.visible = true
			_transmission_strength_meaning.visible = true
		
func set_card_module(card_module: CardModule) -> void:
	if hovered_card_module:
		hovered_card_module.stats.updated.disconnect(update_stats)
	hovered_card_module = card_module
	hovered_card_module.stats.updated.connect(update_stats)
	update_values()

func update_values() -> void:
	var resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, hovered_card_module.card_id)
	if !resource: return
	_name_label.text = resource.name
	_description_label.text = CardResource.format_card_text(resource.ability_description)
	update_stats()

func update_stats() -> void:
	var resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, hovered_card_module.card_id)
	if !resource: return
	var step:float = 0.01
	var resistance := hovered_card_module.stats.resistance.total()
	_stats_resistance_label.text = str(snapped(resistance, step))
	if resistance > resource.resistance: _stats_resistance_label.modulate = Color.RED
	elif resistance < resource.resistance: _stats_resistance_label.modulate = Color.GREEN
	elif resistance == resource.resistance: _stats_resistance_label.modulate = Color.WHITE
	
	var power_output := hovered_card_module.stats.power_output.total()
	_stats_power_output_label.text = str(snapped(power_output, step))
	if power_output > resource.power_output: _stats_power_output_label.modulate = Color.GREEN
	elif power_output < resource.power_output: _stats_power_output_label.modulate = Color.RED
	elif power_output == resource.power_output: _stats_power_output_label.modulate = Color.WHITE
	
	var transmission_strength := hovered_card_module.stats.transmission_strength.total()
	_stats_transmission_strength_label.text = str(snapped(transmission_strength, step))
	if transmission_strength > resource.transmission_strength: _stats_transmission_strength_label.modulate = Color.GREEN
	elif transmission_strength < resource.transmission_strength: _stats_transmission_strength_label.modulate = Color.RED
	elif transmission_strength == resource.transmission_strength: _stats_transmission_strength_label.modulate = Color.WHITE

@onready var _power_output_meaning: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/PowerOutput/Meaning
@onready var _resistance_meaning: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/Resistance/Meaning
@onready var _transmission_strength_meaning: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/TransmissionStrength/Meaning
