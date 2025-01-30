class_name PowerOrb extends Node2D

var energy: float = 0.0
var _energy_visual: float = 0.0:
	set(value):
		energy_label.text = str(snapped(value,0.01))
		_energy_visual = value
var parent_card: Card

@onready var energy_label: Label = $Node2D/MarginContainer/HBoxContainer/EnergyLabel

func set_energy(value: float) -> void:
	energy = value
func reduce_energy(value: float) -> void:
	energy -= value
	energy = max(energy, 0)
func destroy(exit_style := 0) -> void:
	if exit_style == 0:
		var tween := AnimateHandler.create_tween_to_queue()
		var spd := parent_card.module_panel.get_speed_multiplier() * .3
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(2.0,0), spd).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "modulate:a", 0.0, spd).set_trans(Tween.TRANS_ELASTIC)
		tween.finished.connect(func() -> void:queue_free())
	elif exit_style == 1:
		var tween := AnimateHandler.create_tween_to_queue()
		tween.set_parallel(true)
		var spd := parent_card.module_panel.get_speed_multiplier() * .3
		tween.tween_property(self, "scale", Vector2(2,2), spd).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "modulate:a", 0.0, spd).set_trans(Tween.TRANS_ELASTIC)
		tween.finished.connect(func() -> void:queue_free())

func _update_label() -> void:
	energy_label.text = str(snapped(energy,0.01))
