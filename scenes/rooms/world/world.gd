class_name World extends Room

@onready var canvas_layer := $CanvasLayer
@onready var play_display: PlayDisplay = $CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/Panel/PlayDisplay
@onready var card_module_tooltip := $CanvasLayer/CardModuleTooltip
@onready var power_button := $CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/MetalPanelButton
@onready var _label_power_quota: Label = $CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Label3
@onready var _label_power_total := $CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var _label_turn_due_label := $CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/Label3

var menus: Array[MenuUI]

var excess_rerolls: int = 0
var speed_toggles := [1,2,4,8,0.5]
var speed_toggle_index := 0
const power_quota_map:Array = [
	[15,10], [40,10], [100,10], [200,10],
	[280,5], [330,5], [390,5],  [460,5],
	[595,10],  [1000,10], [1200,10], [1500,10],
	[1600,5], [1700,5], [1800,5],  [1900,5],
]
var current_item_in_map: int = 0
var power_quota: float
var quota_due: int
var current_turn: int = 0
var bg_stripe_color_dark: Color = Color.BLACK:
	set(value):
		var bg:ColorRect = $CanvasLayer/ColorRect2
		var bg_material: ShaderMaterial = bg.material
		bg_material.set_shader_parameter("color_one", value)
		bg_stripe_color_dark = value
var bg_stripe_color_light: Color = Color.BLACK:
	set(value):
		var bg:ColorRect = $CanvasLayer/ColorRect2
		var bg_material: ShaderMaterial = bg.material
		bg_material.set_shader_parameter("color_two", value)
		bg_stripe_color_light = value
var bg_tween: Tween


func set_power_quota(new_value: float = power_quota, new_due: int = quota_due) -> void:
	power_quota = new_value
	quota_due = new_due
	_label_power_quota.text = str(snapped(power_quota, 0.01))
	_label_turn_due_label.text = str(quota_due)

func run_next_turn() -> void:
	if !is_menu_free(): return
	var played := play_display.simulation_manager.start_simulation()
	if played:
		current_turn += 1
		quota_due -= 1
		_label_turn_due_label.text = str(quota_due)

func _instantiate_menu(menu_id: String) -> MenuUI:
	var scene: PackedScene = Registries.get_resource(Registries.MENUUI, menu_id)
	if !scene: return
	var menu: MenuUI = scene.instantiate()
	return menu
func add_menu_to_queue(menu: MenuUI) -> void:
	menus.push_back(menu)
	if menus.size() <= 1: _menu_queue_update()
func _menu_queue_update() -> void:
	if menus.is_empty(): return
	var menu := menus[0]
	canvas_layer.add_child(menu)
	menu._menu_ready()
	menu.closed.connect(func() -> void:
		menus.remove_at(0)
		_menu_queue_update()
	)
func is_menu_free() -> bool: return menus.is_empty()

func generate_new_color(colors: Array[Color]) -> Array[Color]:
	var new_colors: Array[Color]
	
	for color in colors:
		var variance := 0.1
		var new_color_1 := Color.from_hsv(
			color.h + randf_range(-variance, variance),
			color.s + randf_range(-variance, variance),
			min(color.v + randf_range(-variance, variance), 0.5)
		)
		new_color_1.lightened(randf_range(-variance, variance))
		new_colors.push_back(new_color_1)
	return new_colors



func change_bg_color() -> void:
	if bg_tween: bg_tween.kill()
	
	var new_colors := generate_new_color([bg_stripe_color_light, bg_stripe_color_dark])
	bg_tween = get_tree().create_tween()
	bg_tween.set_parallel(true)
	bg_tween.tween_property(self, "bg_stripe_color_dark", new_colors[1], 3).\
		set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	bg_tween.tween_property(self, "bg_stripe_color_light", new_colors[0], 3).\
		set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	bg_tween.finished.connect(
		change_bg_color
	)
func _ready() -> void:
	Registries.register_resource(Registries.MENUUI, "end_of_quota_menu", load("res://scenes/rooms/world/menu_ui/end_of_quota_menu/end_of_quota_menu.tscn"))
	Registries.register_resource(Registries.MENUUI, "shop_menu", load("res://scenes/rooms/world/menu_ui/shop_menu/shop_menu.tscn"))
	StatisticsTracker.reset_statistics()
	play_display.card_module_mouse_entered.connect(
		func(_card_module: CardModule) -> void:
			card_module_tooltip.set_card_module(_card_module)
			card_module_tooltip.show_tooltip()
	)
	play_display.card_module_mouse_exited.connect(
		func(_card_module: CardModule) -> void:
			card_module_tooltip.hide_tooltip()
	)
	play_display.card_module_dragged.connect(
		func(_card_module: CardModule) -> void:
			card_module_tooltip.hide_tooltip()
	)
	play_display.power_stored.connect(
		func(new_value:float, value_gained: float) -> void:
			var power_stored_effect := preload("res://scenes/rooms/world/power_stored_effect.tscn").instantiate()
			_label_power_total.add_child(power_stored_effect)
			power_stored_effect.position.x = _label_power_total.size.x
			power_stored_effect.set_value(value_gained)
			_label_power_total.text = str(snapped(new_value,0.01))
			if new_value > 0:
				SoundManager.play_sound_effect("electric_buzz")

	)
	power_button.clicked.connect(
		func()->void:
			run_next_turn()
	)
	play_display.simulation_manager.finished_turn.connect(
		func() -> void:
			if quota_due == 0:
				var _menu := _instantiate_menu("end_of_quota_menu")
				if (play_display.total_power >= power_quota):
					_menu.set_values(play_display.total_power, power_quota, 1, StatisticsTracker.generate_leaderboard())
					play_display.total_power -= power_quota
					play_display.total_power = max(play_display.total_power, 0)
					if current_item_in_map > power_quota_map.size()-1:
						set_power_quota(power_quota+power_quota * .7, 10)
					else:
						set_power_quota(power_quota_map[current_item_in_map][0], power_quota_map[current_item_in_map][1])
						current_item_in_map += 1
				else:
					_menu.set_values(play_display.total_power, power_quota, 0, StatisticsTracker.generate_leaderboard())
					_menu.closed.connect(func()->void:
						room_manager.change_room("main_menu", "fade")
					)
				add_menu_to_queue(_menu)
				
			
			if (current_turn % 5) == 0:
				var _shop_menu := _instantiate_menu("shop_menu")
				_shop_menu.rerolls += excess_rerolls
				_shop_menu.max_rerolls += excess_rerolls
				add_menu_to_queue(_shop_menu)
				_shop_menu.card_bought.connect(
					func(card_id: String) -> void:
						play_display.add_card_module(card_id)
				)
				_shop_menu.leftover_rerolls.connect(
					func(amount_left: int) -> void:
						excess_rerolls = amount_left
				)
	)
	
	$CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/SpeedButton.clicked.connect(
		func() -> void:
			speed_toggle_index += 1
			speed_toggle_index = wrap(speed_toggle_index, 0, speed_toggles.size())
			AnimateHandler.default_speed = speed_toggles[speed_toggle_index]
			AnimateHandler.reset_speed()
			$CanvasLayer/Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/SpeedButton.button_text = "x"+str(speed_toggles[speed_toggle_index])
	)
	play_display.add_card_module("hand_crank_generator")
	set_power_quota(power_quota_map[current_item_in_map][0], power_quota_map[current_item_in_map][1])
	current_item_in_map += 1
	change_bg_color()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_SPACE:
			power_button._on_mouse_clicked()
		if event.pressed && event.keycode == KEY_Q:
			for i in 20:
				play_display.add_card_module("solar_panel")
		
