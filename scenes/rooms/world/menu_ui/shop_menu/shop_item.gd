extends Control

signal clicked(card_id: String)


@onready var _name_label: Label = $VBoxContainer/Name
@onready var _rarity_label: Label = $VBoxContainer/Rarity
@onready var _item_icon :=$VBoxContainer/TextureRect
@onready var _description_label: RichTextLabel = $VBoxContainer/ColorRect/MarginContainer/VBoxContainer/Description

@onready var _power_output_label: Label = $VBoxContainer/ColorRect/MarginContainer/VBoxContainer/PowerOutput/Value
@onready var _resistance_label: Label = $VBoxContainer/ColorRect/MarginContainer/VBoxContainer/Resistance/Value
@onready var _transmission_strengh_label: Label = $VBoxContainer/ColorRect/MarginContainer/VBoxContainer/TransmissionStrength/Value

var tween: Tween
var is_exiting: bool = false
var card_id : String
func _ready() -> void:
	_item_icon.mouse_entered.connect(
		func()->void:
			if is_exiting: return
			if tween: tween.kill()
			tween = get_tree().create_tween()
			tween.tween_property(self, "size_flags_stretch_ratio", 2, .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	)
	_item_icon.mouse_exited.connect(
		func()->void:
			if is_exiting: return
			if tween: tween.kill()
			tween = get_tree().create_tween()
			tween.tween_property(self, "size_flags_stretch_ratio", 1, .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	)
	gui_input.connect(
		func(event: InputEvent) -> void:
			if event is InputEventMouseButton:
				if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
					clicked.emit(card_id)
					animate_flash()
	)


func load_card(_card_id: String) -> void:
	card_id = _card_id
	var card_resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, card_id)
	if !card_resource: return
	_name_label.text = card_resource.name
	_name_label.modulate = card_resource.rarity_color[card_resource.rarity]
	_name_label.modulate.darkened(.5)
	_rarity_label.text = card_resource.rarity_name[card_resource.rarity]
	_rarity_label.modulate = card_resource.rarity_color[card_resource.rarity]
	_rarity_label.modulate.darkened(.5)
	_item_icon.texture = card_resource.texture
	_power_output_label.text = str(card_resource.power_output)
	_resistance_label.text = str(card_resource.resistance)
	_transmission_strengh_label.text = str(card_resource.transmission_strength)
	_description_label.text = CardResource.format_card_text(card_resource.ability_description)

func animate_flash() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	var flash := $ColorRect
	tween.tween_property(flash, "color:a", .2, .15).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(flash, "color:a", 0.0, .15).set_ease(Tween.EASE_OUT_IN)

func animation_destroy() -> void:
	if tween: tween.kill()
	is_exiting = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(0,10), .25).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate:a", 0, .25).set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(func()->void:queue_free())
