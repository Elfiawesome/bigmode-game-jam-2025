class_name ModulePanel extends Panel

signal mouse_entered_on_card(card: Card)
signal mouse_exited_on_card(card: Card)

var cards: Array[Card] = []
var power_stored: float = 0.0
var power_orbs: Array[PowerOrb] = []
var _dragged_card: Card
var _speed_multiplier: float = 1.0

const CARD_SIZE := Vector2(100,128) + Vector2(15,15)
var end_card: EndCard = EndCard.new()

func _ready() -> void:
	resized.connect(func()->void: _arrange_cards())
	reset_speed_multiplier()
	end_card.module_panel = self

func _instantiate_card(card_id: String, card_ability: GDScript, card_resource: CardResource) -> Card:
	# Instancing Card
	var scene: PackedScene = preload("res://scenes/rooms/world/card.tscn")
	var card: Card = scene.instantiate()
	card.card_id = card_id
	card.module_panel = self
	add_child(card)
	card._name_label.text = card_resource.name
	card._module_icon.texture = card_resource.texture
	card.card_ability = card_ability.new()
	card.resistance = card_resource.resistance
	
	card.mouse_entered.connect(func(card: Card)->void:mouse_entered_on_card.emit(card))
	card.mouse_exited.connect(func(card: Card)->void:mouse_exited_on_card.emit(card))
	card.clicked.connect(
		func(card: Card) -> void:
			if !_dragged_card:
				card.card_state = card.CARD_STATE.DRAG
				_dragged_card = card
	)
	card.released.connect(
		func(card: Card) -> void:
			if _dragged_card == card:
				_dragged_card.card_state = _dragged_card.CARD_STATE.IDLE
				card.card_state = card.CARD_STATE.IDLE
				var released_position := _dragged_card.position
				var new_index := _get_grid_index_from_position(released_position)
				
				if (new_index >= 0) && (new_index < (cards.size())):
					cards.erase(card)
					cards.insert(new_index, card)
				for card_index in len(cards):
					cards[card_index].card_pos = card_index
				_dragged_card = null
				_arrange_cards()
	)
	
	return card

func add_card(card_id: String) -> void:
	# Load Resource and Ability
	var card_ability: GDScript = Registries.get_resource(Registries.CARDABILITY, card_id)
	var card_resource: CardResource = Registries.get_resource(Registries.CARDRESOURCE, card_id)
	if !card_ability or !card_resource:
		return
	var card := _instantiate_card(card_id, card_ability, card_resource)
	cards.push_back(card)
	card.card_pos = cards.size()-1
	
	# Animation
	card.position = Vector2(100,200)
	card.scale = Vector2(-1,0)
	var tween := AnimateHandler.create_tween_to_queue()
	tween.tween_property(card, "scale", Vector2(1,1), .75 * get_speed_multiplier()).set_trans(Tween.TRANS_ELASTIC)
	_arrange_cards()

func _get_grid_index_from_position(card_position: Vector2) -> int:
	var index := 0
	var total_columns: int = floor(size.x/CARD_SIZE.x) - 1
	var total_rows: float = ceil((len(cards)-1)/(total_columns+1))
	var start_pos := Vector2(
		size.x - total_columns * CARD_SIZE.x, 
		size.y - total_rows * CARD_SIZE.y
	)/2
	var gridpos:Vector2 = floor(((card_position-start_pos + CARD_SIZE/2)/(CARD_SIZE)))
	index = gridpos.x + (gridpos.y)*(total_columns+1)
	return index

func _arrange_cards() -> void:
	var total_columns: int = floor(size.x/CARD_SIZE.x) - 1
	var total_rows: float = ceil((len(cards)-1)/(total_columns+1))
	var start_pos := Vector2(
		size.x - total_columns * CARD_SIZE.x, 
		size.y - total_rows * CARD_SIZE.y
	)/2
	
	var row_index: int = 0
	var col_index: int = 0
	var index: int = 0
	for card in cards:
		if card.card_state == card.CARD_STATE.IDLE:
			var target_pos := start_pos + Vector2(col_index*CARD_SIZE.x, row_index*CARD_SIZE.y)
			var tween := AnimateHandler.create_tween_to_queue()
			tween.tween_property(card, "position", target_pos, 0.5 * get_speed_multiplier()).set_trans(Tween.TRANS_BACK)
		
		if index < cards.size()-1:
			card.show_arrow()
		else:
			card.hide_arrow()
			
		move_child(card, index)
		if col_index == total_columns:
			row_index += 1
			col_index = 0
		else:
			col_index +=1
		index += 1

func add_power_orb(card: Card, energy: float = 0.0) -> PowerOrb:
	var power_orb: PowerOrb = load("res://scenes/rooms/world/power_orb.tscn").instantiate()
	power_orb.position = card.position
	power_orb.scale = Vector2.ZERO
	power_orb.energy = energy
	add_child(power_orb)
	card._catch_orbs(power_orb)
	card._swallow_orbs()
	power_orbs.push_back(power_orb)
	_arrange_power_orbs()
	return power_orb

func _arrange_power_orbs() -> void:
	for power_orb in power_orbs:
		if !power_orb.parent_card: continue
		if !(power_orb.parent_card is EndCard):
			var tween := AnimateHandler.create_tween_to_queue()
			tween.set_parallel(true)
			var spd := 0.3 * get_speed_multiplier()
			tween.tween_property(power_orb, "scale", Vector2(.9,.9), spd).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(power_orb, "position", power_orb.parent_card.position, spd).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(power_orb, "_energy_visual", power_orb.energy, spd).set_trans(Tween.TRANS_LINEAR)
			tween.chain()
			tween.tween_property(power_orb, "scale", Vector2(1,1), spd/2).set_trans(Tween.TRANS_CUBIC)

func destroy_power_orb(power_orb: PowerOrb) -> void:
	if power_orb in power_orbs:
		power_orbs.erase(power_orb)
		power_orb.parent_card.power_orbs.erase(power_orb)
		power_orb.destroy(0)

func absorb_power_orb(power_orb: PowerOrb) -> void:
	if power_orb in power_orbs:
		power_stored += power_orb.energy
		print(power_stored)
		power_orbs.erase(power_orb)
		power_orb.parent_card.power_orbs.erase(power_orb)
		power_orb.destroy(1)

func reset_speed_multiplier() -> void: _speed_multiplier = 1.0
func tick_speed_multiplier() -> void: _speed_multiplier = max(_speed_multiplier-0.05, 0.2)
func get_speed_multiplier() -> float: return _speed_multiplier

func get_card(card_pos: int) -> Card:
	if (card_pos < cards.size()) && (card_pos >= 0):
		return cards[card_pos]
	else:
		return end_card

class EndCard extends Card:
	func _throw_orbs(orbs := power_orbs) -> void: pass
	#func _swallow_orbs() -> void: super._swallow_orbs()
