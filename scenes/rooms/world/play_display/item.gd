class_name Item extends Control

var item_id: String
var amount: float = 0.0
var stats := Stats.new()
var card_module: CardModule
var creator_card_module: CardModule

var _texture_icon: Texture2D
var _amount_display: float:
	set(value):
		_amount_display = value
		_amount_label.text = str(snapped(value,0.01))

@onready var _item_icon_texture: TextureRect = $Panel/VBoxContainer/TextureRect
@onready var _amount_label: Label = $Panel/VBoxContainer/Label

func _ready() -> void:
	if !_item_icon_texture.texture: _item_icon_texture.texture = _texture_icon
	set_amount(amount)


func add_amount(new_amount: float) -> void: set_amount(amount + new_amount)
func set_amount(new_amount: float) -> void:
	var tween := AnimateHandler.create_tween_to_queue()
	amount = new_amount
	tween.tween_property(self, "_amount_display", amount, .5).set_trans(Tween.TRANS_LINEAR)

func load_from_item_resource(item_resource: ItemResource) -> void:
	stats.speed.add(item_resource.transmission_speed, null, -1)
	stats.direction = item_resource.default_direction
	_texture_icon = item_resource.texture

func animation_absorbed() -> void:
	var item_flow_effect := preload("res://scenes/rooms/world/play_display/item_flow_effect.tscn").instantiate()
	get_parent().add_child(item_flow_effect)
	item_flow_effect.global_position = global_position + size/2
	
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y-20, .5).set_trans(Tween.TRANS_BACK)
	var color:=Color.YELLOW
	color.a = 0
	tween.tween_property(self, "modulate", color * 2, .5).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func()->void:queue_free())

func animate_destroy() -> void:
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE*1.4, .5)
	tween.tween_property(self, "rotation", deg_to_rad(100 + randf_range(-40,40)), .5)
	tween.tween_property(self, "position", position + Vector2(randf_range(-40,40),70+randf_range(-40,40)), .5).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0, .5).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func()->void:queue_free())

# Specific Ability
func on_tick_phase() -> void:
	stats.speed.tick()

# Helper Class
class Stats:
	signal updated
	class StackedBase:
		signal updated
		var _arr: Array = []
		func tick() -> void:
			updated.emit()
			var to_remove: Array[Array] = []
			for value: Array in _arr:
				if value[2] != -1:
					if value[2] > 0: value[2] -=1
					else: to_remove.push_back(value)
			for value in to_remove:
				_arr.erase(value)
	class StackedFloat extends StackedBase:
		func add(value: float, card: CardModule = null, time: int = -1) -> void:
			_arr.push_back([value, card, time])
			updated.emit()
		func total() -> float: 
			var total_value: float = 0.0
			for value: Array in _arr: total_value += value[0]
			return total_value
	class StackedInt extends StackedBase:
		func add(value: int, card: CardModule = null, time: int = -1) -> void:
			_arr.push_back([value, card, time])
			updated.emit()
		func total() -> int: 
			var total_value: int = 0
			for value: Array in _arr: total_value += value[0]
			return total_value
	
	var speed := StackedFloat.new()
	var direction: int = 0
	func _init() -> void:
		speed.updated.connect(_on_update)
	func _on_update() -> void:
		updated.emit()
