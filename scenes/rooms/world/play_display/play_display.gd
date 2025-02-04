class_name PlayDisplay extends Control

signal card_module_mouse_entered(card_module: CardModule)
signal card_module_mouse_exited(card_module: CardModule)
signal card_module_dragged(card_module: CardModule)
signal power_stored(new_power: float, amount_stored: float)

const _CARD_SPACING_BUFFER := Vector2(30,30)

var card_modules: Array[CardModule]
var total_power: float:
	set(value):
		power_stored.emit(value, value - total_power)
		total_power = value

var _dragged_card_module: CardModule
var _end_power_depot: CardModule
var _void_card_module: CardModule
var simulation_manager := SimulationManager.new(self)

func _ready() -> void:
	_create_end_power_depot()
	resized.connect(
		func()->void:
			arrange_card_modules()
	)
	add_child(simulation_manager)

func _process(_delta: float) -> void:
	pass

func get_card_module(card_pos: int) -> CardModule:
	if (card_pos < card_modules.size()) && (card_pos >= 0):
		return card_modules[card_pos]
	else:
		return _end_power_depot

func add_card_module(card_id: String) -> void:
	# Check if card_id is valid inside registry
	var card_resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, card_id)
	var card_ability_script: GDScript = Registries.get_resource(Registries.CARDABILITY, card_id)
	if !card_ability_script or !card_resource: return
	var card_ability: CardAbility = card_ability_script.new()
	var card_module := _instantiate_card_module(card_id, card_resource, card_ability)
	card_modules.push_back(card_module)
	card_module.card_pos = card_modules.size()-1
	arrange_card_modules()


func arrange_card_modules() -> void:
	var card_space := CardModule.CARD_SIZE+_CARD_SPACING_BUFFER
	var total_columns: int = max(floor(size.x/card_space.x) - 1, 0)
	var total_rows: float = floor((len(card_modules))/(total_columns+1.0))
	var start_pos := Vector2(
		size.x - total_columns * card_space.x, 
		size.y - total_rows * card_space.y
	)/2
	
	var total_card_modules: Array[CardModule] = card_modules.duplicate()
	total_card_modules.push_back(_end_power_depot)
	
	var row_index: int = 0
	var col_index: int = 0
	var index: int = 0
	for card_module in total_card_modules:
		var target_pos := start_pos + Vector2(col_index*card_space.x, row_index*card_space.y)
		var tween := AnimateHandler.create_tween_to_queue()
		tween.tween_property(card_module, "position", target_pos, .5).set_trans(Tween.TRANS_BACK)
		move_child(card_module, index)
		if col_index == total_columns:
			row_index += 1
			col_index = 0
		else:
			col_index +=1
		index += 1

func store_power(value: float) -> void:
	total_power += value

func _instantiate_card_module(card_id: String, card_resource: CardResource, card_ability: CardAbility) -> CardModule:
	var scene: PackedScene = preload("res://scenes/rooms/world/play_display/card_module.tscn")
	var card_module: CardModule = scene.instantiate()
	card_module.card_id = card_id
	card_module.play_display = self
	add_child(card_module)
	card_module.load_from_card_resource(card_resource, card_ability)
	card_module.clicked.connect(_on_card_module_clicked)
	card_module.released.connect(_on_card_module_released)
	card_module.mouse_entered.connect(func(_card_module: CardModule) -> void: card_module_mouse_entered.emit(_card_module))
	card_module.mouse_exited.connect(func(_card_module: CardModule) -> void: card_module_mouse_exited.emit(_card_module))
	return card_module

func _on_card_module_clicked(card_module: CardModule) -> void:
	if simulation_manager._current_state != simulation_manager.State.READY: return
	if !_dragged_card_module:
		if card_module.drag_locked: return
		_dragged_card_module = card_module
		card_module.state = card_module.State.DRAG
		card_module_dragged.emit(card_module)

func _on_card_module_released(card_module: CardModule) -> void:
	if simulation_manager._current_state != simulation_manager.State.READY: return
	if _dragged_card_module == card_module:
		_dragged_card_module.state = _dragged_card_module.State.IDLE
		var released_position := get_global_mouse_position()
		var new_index := _get_grid_index_from_position(released_position)
		move_card_module(card_module, new_index)
		_dragged_card_module = null

func move_card_module(card_module: CardModule, new_index: int) -> void:
	if (new_index >= 0) && (new_index < (card_modules.size())):
		card_modules.erase(card_module)
		card_modules.insert(new_index, card_module)
	for card_index in len(card_modules):
		card_modules[card_index].card_pos = card_index
	arrange_card_modules()

func _get_grid_index_from_position(card_position: Vector2) -> int:
	var index:int = 0
	var card_space := CardModule.CARD_SIZE+_CARD_SPACING_BUFFER
	var total_columns: int = max(floor(size.x/card_space.x) - 1, 0)
	var total_rows: float = floor((len(card_modules))/(total_columns+1.0))
	var start_pos := Vector2(
		size.x - total_columns * card_space.x, 
		size.y - total_rows * card_space.y
	)/2
	var gridpos: Vector2i = Vector2i(floor(((card_position-start_pos + card_space/2)/(card_space))))
	index = gridpos.x + (gridpos.y)*(total_columns+1)
	return index

func _create_end_power_depot() -> void:
	var card_id:= "end_power_depot"
	_end_power_depot = _instantiate_card_module(
		card_id,
		Registries.get_resource(Registries.CARDRESOURCE, card_id),
		Registries.get_resource(Registries.CARDABILITY, card_id).new()
	)
	_end_power_depot.show_storage_display(false)
	_end_power_depot.drag_locked = true
