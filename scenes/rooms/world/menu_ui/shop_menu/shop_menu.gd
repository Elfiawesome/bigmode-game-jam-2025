extends MenuUI

signal card_bought(card_id: String)
signal leftover_rerolls(amount: int)

@onready var h_box_container: HBoxContainer = $NinePatchRect/VBoxContainer/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer
var tween: Tween
@onready var skip_button := $NinePatchRect/VBoxContainer/HBoxContainer/MetalPanelButton2
@onready var reroll_button := $NinePatchRect/VBoxContainer/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/MetalPanelButton

var rerolls: int = 4
var max_rerolls: int = rerolls-1

func _ready() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	position = get_viewport_rect().size/2 - Vector2(0, get_viewport_rect().size.y*1.5)
	rotation = deg_to_rad(15)
	var target_position := get_viewport_rect().size/2 - size/2
	tween.tween_property(self, "position", target_position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	reroll_button.clicked.connect(
		func()->void:
			if rerolls<1: return
			SoundManager.play_sound_effect("book_turn", 0.2, -5)
			reroll_shop()
	)
	skip_button.clicked.connect(animate_exit)
	reroll_shop()

func _menu_ready() -> void:
	SoundManager.play_sound_effect("shop_bell")

func reroll_shop() -> void:
	if is_closed: return
	rerolls -= 1
	reroll_button.button_text = "Reroll ["+str(rerolls)+"/"+str(max_rerolls)+"]"
	for children:Control in h_box_container.get_children():
		var old_global_position := children.global_position
		h_box_container.remove_child(children)
		add_child(children)
		children.global_position = old_global_position
		children.animation_destroy()
	for i in 3:
		var item:=preload("res://scenes/rooms/world/menu_ui/shop_menu/shop_item.tscn").instantiate()
		item.clicked.connect(_on_shop_item_clicked)
		h_box_container.add_child(item)
		var cards:Array = Registries.registries[Registries.CARDRESOURCE].resources.keys()
		cards.erase("end_power_depot")
		item.load_card(
			cards.pick_random()
		)

func animate_exit() -> void:
	if tween: tween.kill()
	leftover_rerolls.emit(rerolls)
	emit_close()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	var target_position := get_viewport_rect().size/2 + Vector2(0, get_viewport_rect().size.y) - size/2
	tween.tween_property(self, "position", target_position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", deg_to_rad(-5), 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func()->void:queue_free())
func _on_shop_item_clicked(card_id: String) -> void:
	if is_closed: return
	SoundManager.play_sound_effect("coin_drop")
	card_bought.emit(card_id)
	animate_exit()
