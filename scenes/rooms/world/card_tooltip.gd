class_name CardToolTip extends Control
@onready var tooltip_box: ColorRect = $TooltipBox
@onready var _tooltip_container: VBoxContainer = $TooltipBox/VBoxContainer
@onready var _name_label: Label = $TooltipBox/VBoxContainer/Name
@onready var _description_label: Label = $TooltipBox/VBoxContainer/Description
@onready var _stats_resistance_label: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/Resistance/Value
@onready var _stats_power_generation_label: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/PowerGeneration/Value
@onready var _stats_transmission_strength_label: Label = $TooltipBox/VBoxContainer/MarginContainer/VBoxContainer/TransmissionStrength/Value
var tween: Tween
var is_show := false

func _ready() -> void:
	_tooltip_container.minimum_size_changed.connect(
		_on_expand_box
	)

func _on_expand_box() -> void:
	if is_show:
		if tween: tween.kill()
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(tooltip_box, "visible", true, 1)
		tween.tween_property(tooltip_box, "size", _tooltip_container.get_minimum_size(), .15).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(tooltip_box, "modulate:a", 1, .15).set_trans(Tween.TRANS_LINEAR)

func show_tooltip() -> void:
	if !is_show:
		print("SHOW")
		tooltip_box.size = Vector2.ZERO
		is_show = true
		_on_expand_box()

func hide_tooltip() -> void:
	if is_show:
		print("HIDE")
		is_show = false
		if tween: tween.kill()
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(tooltip_box, "size", Vector2.ZERO, .15).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(tooltip_box, "modulate:a", 0, .15).set_trans(Tween.TRANS_LINEAR)
		tween.chain()
		tween.tween_property(tooltip_box, "visible", false, 1)

func _process(delta: float) -> void:
	position = get_global_mouse_position()

func set_description(card: Card, card_resource:CardResource) -> void:
	_name_label.text = card_resource.name
	_description_label.text = card_resource.description
	_stats_resistance_label.text = str(card.resistance.retrieve())
	_stats_power_generation_label.text = str(card.power_generation.retrieve())
	_stats_transmission_strength_label.text = str(card.transmission_strength.retrieve())
