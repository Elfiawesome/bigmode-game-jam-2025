class_name CardModule extends Node2D

signal clicked(card_module: CardModule)
signal released(card_module: CardModule)
signal mouse_entered(card_module: CardModule)
signal mouse_exited(card_module: CardModule)

enum State {IDLE, DRAG}

const CARD_SIZE := Vector2(115,115)

var card_id: String
var card_pos: int
var stats: Stats = Stats.new()
var storage: Array[Item] = []
var abilities: Array[CardAbility] = []
var can_generate_power: bool = true
var drag_locked: bool = false
var state: State
# references
var play_display: PlayDisplay

@onready var _card_icon_texture := $NinePatchRect/MarginContainer/VBoxContainer/ItemDisplay/TextureRect
@onready var _card_back_texture := $NinePatchRect
@onready var _storage_display: Control = $NinePatchRect/MarginContainer/VBoxContainer/StorageDisplay
@onready var _true_storage_display: Control = $NinePatchRect/MarginContainer/VBoxContainer/StorageDisplay


func _ready() -> void:
	_card_back_texture.gui_input.connect(
		func(event: InputEvent) -> void:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						SoundManager.play_sound_effect("hover_button", .1, -20)
						z_index = 1
						clicked.emit(self)
						animate_bounce(1.1)
					else:
						SoundManager.play_sound_effect("whoosh", .1, -10)
						z_index = 0
						released.emit(self)
						animate_bounce(.9)
	)
	_card_back_texture.mouse_entered.connect(func() -> void: mouse_entered.emit(self))
	_card_back_texture.mouse_exited.connect(func() -> void: mouse_exited.emit(self))
	_storage_display.resized.connect(func() -> void: _arrange_storage_items())
	_animate_intro()

func _process(_delta: float) -> void:
	match state:
		State.DRAG: global_position = get_global_mouse_position()

func load_from_card_resource(card_resource: CardResource, card_ability: CardAbility = null) -> void:
	_card_icon_texture.texture = card_resource.texture
	stats.resistance.add(card_resource.resistance)
	stats.power_output.add(card_resource.power_output)
	stats.transmission_strength.add(card_resource.transmission_strength)
	can_generate_power = card_resource.can_generate_power
	if card_ability: _add_ability(card_ability)
	_card_back_texture.self_modulate = card_resource.rarity_color[card_resource.rarity]
	if card_resource.custom_card_back != _card_back_texture.texture: _card_back_texture.texture = card_resource.custom_card_back

func generate_power(power_amount: float) -> void:
	var item_id: String = "power_orb"
	var item_resource: ItemResource = Registries.get_resource(Registries.ITEMRESOURCE, item_id)
	if !item_resource: return
	var item := _create_item(item_id, item_resource, power_amount)
	add_to_storage(item)

func add_to_storage(item: Item, update_positions := true) -> void:
	if item in storage: return
	storage.push_back(item)
	item.card_module = self
	var old_global_position := item.global_position
	_storage_display.add_child(item)
	item.global_position = old_global_position
	if update_positions: _arrange_storage_items()

func remove_from_storage(item: Item, update_positions := true) -> void:
	if !(item in storage): return
	storage.erase(item)
	item.card_module = null
	var old_global_position := item.global_position
	_storage_display.remove_child(item)
	play_display.add_child(item)
	item.global_position = old_global_position
	if update_positions: _arrange_storage_items()

func clear_storage() -> void:
	for item in storage:
		_storage_display.remove_child(item)
	storage.clear()

func _arrange_storage_items() -> void:
	if storage.is_empty(): return
	var item_size := storage[0].size
	for index in len(storage):
		var item := storage[index]
		item.position = _get_position_of_item(index, item_size)

func _get_position_of_item(index: int, item_size: Vector2) -> Vector2:
	var startpos := _storage_display.size/2
	if _true_storage_display.visible:
		startpos.x -= ((storage.size()-1) * item_size.x)/2
		startpos.x += index * item_size.x
	startpos -= item_size/2
	return startpos

func show_storage_display(is_show: bool) -> void:
	_true_storage_display.visible = is_show
	if is_show:
		_storage_display = _true_storage_display
	else:
		_storage_display = _card_icon_texture

# Specific Ability
func on_initialization_phase() -> void:
	for ability in abilities:
		ability._initialization()
func on_initial_power_generation_phase() -> void:
	if !can_generate_power: return
	var base_output := stats.power_output.total()
	var additional_output: float = 0.0
	for ability in abilities:
		additional_output += ability._initial_power_generation(base_output)
	var total_output := base_output + additional_output
	StatisticsTracker.card_generated_power(card_id, total_output)
	# add power
	if total_output != 0:
		generate_power(total_output)
		animate_bounce(1.05, 5)
func on_card_tick_phase() -> void:
	for ability in abilities:
		ability._tick()
func on_item_tick_phase() -> void:
	for item in storage:
		item.on_tick_phase()
func on_end_simulation_phase() -> void:
	stats.power_output.tick()
	stats.resistance.tick()
	stats.transmission_strength.tick()
	for ability in abilities:
		ability.cooldown = 0
		ability.used = false


func animate_bounce(tgt_scale: float = 1.1, rotate_variance: float = 10) -> void:
	var tween := AnimateHandler.create_tween_to_queue().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE*tgt_scale, 0.2).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "rotation", deg_to_rad(randf_range(-rotate_variance,rotate_variance)), .2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
	tween.chain()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "rotation", 0, .2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)

func animate_idle_focus() -> void:
	var tween := AnimateHandler.create_tween_to_queue().set_parallel(true)
	tween.tween_property(self, "position:y", position.y-20, .2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", deg_to_rad(randf_range(-5,5)), .2).set_trans(Tween.TRANS_BACK)
	tween.chain()
	tween.tween_property(self, "position:y", position.y, .3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0, .3).set_trans(Tween.TRANS_BACK)

func _create_item(item_id: String, item_resource: ItemResource, amount := 0.0) -> Item:
	var item: Item = preload("res://scenes/rooms/world/play_display/item.tscn").instantiate()
	item.item_id = item_id
	item.creator_card_module = self
	item.load_from_item_resource(item_resource)
	item.amount = amount
	return item

func _add_ability(card_ability: CardAbility) -> void:
	abilities.push_back(card_ability)
	card_ability.card_module = self

func _animate_intro() -> void:
	position = Vector2(0,0)
	scale = Vector2(-1,0)
	var tween := AnimateHandler.create_tween_to_queue()
	tween.tween_property(self, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_ELASTIC)

# Helper Stats class
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
	
	var resistance := StackedFloat.new()
	var power_output := StackedFloat.new()
	var transmission_strength := StackedInt.new()
	var temperature := StackedFloat.new()
	var direction: int = 1
	func _init() -> void:
		resistance.updated.connect(_on_update)
		power_output.updated.connect(_on_update)
		transmission_strength.updated.connect(_on_update)
		temperature.updated.connect(_on_update)
	func _on_update() -> void:
		updated.emit()
	func _to_string() -> String:
		var t: String = "Stats Debug:\n"
		t += "[resistance][x"+str(resistance._arr.size())+"]\n"
		for item: Array in resistance._arr:
			t += "  [" +str(item[0]) + "] - [" + str(item[1]) + "] - [" + str(item[2]) + "]\n"
		t += "  total: " + str(resistance.total()) + "\n"
		
		t += "[output][x"+str(power_output._arr.size())+"]\n"
		for item: Array in power_output._arr:
			t += "  [" +str(item[0]) + "] - [" + str(item[1]) + "] - [" + str(item[2]) + "]\n"
		t += "  total: " + str(power_output.total()) + "\n"
		
		t += "[transmission_strength][x"+str(transmission_strength._arr.size())+"]\n"
		for item: Array in transmission_strength._arr:
			t += "  [" +str(item[0]) + "] - [" + str(item[1]) + "] - [" + str(item[2]) + "]\n"
		t += "  total: " + str(transmission_strength.total()) + "\n"
		return t
