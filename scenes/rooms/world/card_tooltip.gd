class_name CardToolTip extends Control
@onready var tooltip_box: ColorRect = $TooltipBox
@onready var _name_label: Label = $TooltipBox/VBoxContainer/Name
@onready var _description_label: Label = $TooltipBox/VBoxContainer/Description

var tween: Tween

func show_tooltip() -> void:
	if tween: tween.kill()
	
	var box_size:Vector2 = Vector2(
		$TooltipBox/VBoxContainer.get_minimum_size().x,
		$TooltipBox/VBoxContainer.get_minimum_size().y
	)
	
	tooltip_box.size = Vector2.ZERO
	tooltip_box.modulate.a = 0
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "visible", true, 0.0)
	tween.tween_property(tooltip_box, "size", box_size, .15).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(tooltip_box, "modulate:a", 1, .15).set_trans(Tween.TRANS_LINEAR)
func hide_tooltip() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(tooltip_box, "size", Vector2(0,0), .15).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(tooltip_box, "modulate:a", 0, .15).set_trans(Tween.TRANS_LINEAR)
	tween.chain()
	tween.tween_property(self, "visible", false, 0.0)

func _process(delta: float) -> void:
	position = get_global_mouse_position()

func set_description(card_name: String, card_description: String) -> void:
	_name_label.text = card_name
	_description_label.text = card_description
